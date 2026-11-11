"""Host regression tests use synthetic captures, never claim board measurements."""
import argparse
import csv
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("awg", ROOT / "tools/awg.py")
awg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(awg)


def fake_csv(path, iq, gap=False, invalid=False):
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Sample in Buffer", "scope_adc_i[511:0]", "scope_adc_q[511:0]",
                    "scope_metadata[63:0]", "scope_beat_counter[31:0]"])
        w.writerow(["Radix", "HEX", "HEX", "HEX", "UNSIGNED"])
        for beat in range(iq.shape[1] // 4):
            packed = [0, 0]
            for ch in range(8):
                for lane in range(4):
                    z = iq[ch, 4*beat+lane]
                    packed[0] |= (int(z.real) & 65535) << (64*ch+16*lane)
                    packed[1] |= (int(z.imag) & 65535) << (64*ch+16*lane)
            meta = 65535 | (255 << 16) | (1 << 42)
            if invalid and beat == 1:
                meta &= ~1
            # Include uint32 wraparound in otherwise valid captures.
            seq = (0xfffffffc+beat+(1 if gap and beat >= 1 else 0)) & 0xffffffff
            w.writerow([beat, f"{packed[0]:0128X}", f"{packed[1]:0128X}", f"{meta:016X}", seq])


class ToolsTest(unittest.TestCase):
    def test_signed_lane_order_and_continuity(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td)/"capture.csv"
            rng = np.random.default_rng(47)
            iq = rng.integers(-32768,32768,(8,32)) + 1j*rng.integers(-32768,32768,(8,32))
            fake_csv(path, iq)
            recovered, seq, _ = awg.decode_ila(path,255)
            np.testing.assert_array_equal(iq,recovered)
            self.assertEqual(int(seq[4]),0)
            # Actual synthesized LTX may alias marker probes to metadata bits.
            with path.open(newline="",encoding="utf-8") as stream:
                rows=list(csv.reader(stream))
            rows[0][3]="scope_metadata_1[63:0]"
            for index,row in enumerate(rows):
                row.extend(["scope_metadata[40]", "scope_metadata_2[41]"] if index==0 else
                           ["HEX", "HEX"] if index==1 else ["0", "0"])
            with path.open("w",newline="",encoding="utf-8") as f:
                csv.writer(f).writerows(rows)
            np.testing.assert_array_equal(iq,awg.decode_ila(path,255)[0])
            fake_csv(path,iq,gap=True)
            with self.assertRaisesRegex(ValueError,"Non-contiguous"):
                awg.decode_ila(path,255)
            fake_csv(path,iq,invalid=True)
            with self.assertRaisesRegex(ValueError,"valid dropped"):
                awg.decode_ila(path,255)

    def test_waveform_files_and_scope(self):
        with tempfile.TemporaryDirectory() as td:
            out=Path(td)
            args=argparse.Namespace(samples=1024,amplitude=.25,mask=255,kind="tone",tone_bin=4,out=out)
            awg.generate(args)
            words=[int(x,16) for x in (out/"ch0.hex").read_text().splitlines()]
            self.assertEqual(words[0],8192)
            with np.load(out/"waveform.npz",allow_pickle=False) as a:
                iq=a["iq"]
            fake_csv(out/"capture.csv",iq)
            (out/"capture.json").write_text(json.dumps(dict(fs_hz=awg.FS,nco_hz=awg.NCO,channel_mask=255)))
            awg.analyze(argparse.Namespace(input=out/"capture.csv",metadata=None,mask=None,out=out/"result"))
            meta=json.loads((out/"result/summary.json").read_text())
            self.assertEqual(meta["channels"][0]["peak_baseband_hz"],4*awg.FS/1024)
            self.assertNotIn("/*CAPTURE_DATA*/null",(out/"result/scope.html").read_text(encoding="utf-8"))
            (out/"capture.json").write_text(json.dumps(dict(fs_hz=awg.FS,nco_hz=awg.NCO,
                                                           channel_mask=255,capture_beats=4096)))
            with self.assertRaisesRegex(ValueError,"partial data"):
                awg.analyze(argparse.Namespace(input=out/"capture.csv",metadata=None,mask=None,out=out/"partial"))
            with self.assertRaisesRegex(ValueError,"normalized"):
                awg.write_bundle(iq,out,{})

    def test_qpsk_frequency_phase_and_timing_recovery(self):
        with tempfile.TemporaryDirectory() as td:
            out=Path(td)
            args=argparse.Namespace(samples=16384,amplitude=.25,mask=255,kind="qpsk",sps=8,seed=47,out=out)
            awg.generate(args)
            with np.load(out/"waveform.npz",allow_pickle=False) as a:
                iq=a["iq"]
            # Loopback model: cyclic delay, amplitude/phase offset and 100 kHz CFO.
            t=np.arange(iq.shape[1])/awg.FS
            rx=.4*np.roll(iq,131,axis=1)*np.exp(1j*(.7+2*np.pi*100000*t))
            np.savez_compressed(out/"capture.npz",iq=rx,metadata=json.dumps(dict(fs_hz=awg.FS)))
            awg.demod_qpsk(argparse.Namespace(capture=out/"capture.npz",reference=out/"waveform.npz",channel=0,out=out/"demod"))
            result=json.loads((out/"demod/qpsk.json").read_text())
            self.assertEqual(result["bit_errors"],0)
            self.assertGreater(result["compared_bits"],1000)
            self.assertAlmostEqual(result["coarse_cfo_hz"]+result["residual_cfo_hz"],100000,delta=10)


if __name__=="__main__":
    unittest.main()
