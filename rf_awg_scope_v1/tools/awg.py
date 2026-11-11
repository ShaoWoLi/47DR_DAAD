"""47DR V1 waveform packing, strict ILA decoding, HTML scope and QPSK demo."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
import re

import numpy as np

FS = 625_000_000
NCO = 1_500_000_000


def write_bundle(iq: np.ndarray, out: Path, meta: dict, **extra) -> None:
    """iq: complex normalized data [8,N], quantized without silently clipping."""
    iq = np.asarray(iq)
    if iq.ndim != 2 or iq.shape[0] != 8 or not 4 <= iq.shape[1] <= 32768 or iq.shape[1] % 4:
        raise ValueError("Expected iq[8,N], 4 <= N <= 32768, N a multiple of four")
    if not np.isfinite(iq).all() or max(np.abs(iq.real).max(), np.abs(iq.imag).max()) > 1:
        raise ValueError("I/Q must be finite and normalized to [-1,1]")
    i = np.rint(iq.real * 32767).astype(np.int16)
    q = np.rint(iq.imag * 32767).astype(np.int16)
    words = (q.astype(np.int32).astype(np.uint32) & 65535) << 16
    words |= i.astype(np.int32).astype(np.uint32) & 65535
    out.mkdir(parents=True, exist_ok=True)
    meta = dict(meta, format="47dr-waveform-v1", samples=iq.shape[1], fs_hz=FS,
                nco_hz=NCO, word_order="Q15:0_I15:0", channel_mask=meta.get("channel_mask", 255))
    if not 1 <= meta["channel_mask"] <= 255:
        raise ValueError("Channel mask must be 1..255")
    meta["sha256"] = {}
    for ch, row in enumerate(words):
        text = "".join(f"{int(w):08X}\n" for w in row)
        (out / f"ch{ch}.hex").write_text(text, encoding="ascii")
        meta["sha256"][f"ch{ch}.hex"] = hashlib.sha256(text.encode("ascii")).hexdigest()
    (out / "manifest.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    (out / "waveform.meta").write_text("".join(f"{k} {meta[k]}\n" for k in
        ("samples", "fs_hz", "nco_hz", "channel_mask")), encoding="ascii")
    np.savez_compressed(out / "waveform.npz", iq=i.astype(float) + 1j*q.astype(float),
                        metadata=json.dumps(meta), **extra)


def generate(args) -> None:
    n, a = args.samples, args.amplitude
    if not 0 < a <= 1 or not 1 <= args.mask <= 255:
        raise ValueError("Amplitude must be (0,1], channel mask 1..255")
    t = np.arange(n) / FS
    iq = np.zeros((8, n), dtype=complex)
    meta = dict(kind=args.kind, channel_mask=args.mask, amplitude=a)
    extra = {}
    if args.kind == "tone":
        # Integer FFT bins make loop boundaries periodic; report actual frequency.
        bins = np.arange(1, 9) * args.tone_bin
        if np.any(np.abs(bins) >= n/2):
            raise ValueError("Tone bins exceed complex Nyquist range")
        for ch in range(8):
            iq[ch] = a * np.exp(2j*np.pi*bins[ch]*np.arange(n)/n)
        meta["tone_hz"] = (bins * FS / n).tolist()
    elif args.kind == "chirp":
        # The phase accumulation is periodic for this symmetric, discrete chirp.
        width = args.bandwidth
        if not 0 < width < FS:
            raise ValueError("Chirp bandwidth must be inside the complex sample bandwidth")
        freq = np.linspace(-width/2, width/2, n)
        phase = np.r_[0.0, np.cumsum(freq[:-1])] * (2*np.pi/FS)
        for ch in range(8):
            iq[ch] = a * np.exp(1j*(phase + ch*np.pi/8))
        meta["bandwidth_hz"] = width
    else:
        if args.sps < 2 or n % args.sps or n // args.sps < 128:
            raise ValueError("QPSK needs integer samples/symbol >=2 and at least 128 symbols")
        symbols = np.empty((8, n // args.sps), dtype=complex)
        pilot_rng = np.random.default_rng(12345)
        pilot_bits = pilot_rng.integers(0, 2, (64, 2))
        for ch in range(8):
            bits = np.random.default_rng(args.seed+ch).integers(0, 2, (n // args.sps, 2))
            bits[:64] = pilot_bits
            symbols[ch] = ((1-2*bits[:, 0]) + 1j*(1-2*bits[:, 1])) / np.sqrt(2)
            iq[ch] = a * np.repeat(symbols[ch], args.sps)
        meta.update(sps=args.sps, symbol_rate_hz=FS/args.sps, preamble_symbols=64, seed=args.seed,
                    pulse_shape="rectangular", demodulation="known-preamble QPSK demo")
        extra["symbols"] = symbols
    iq[[ch for ch in range(8) if not args.mask & (1 << ch)]] = 0
    write_bundle(iq, args.out, meta, **extra)
    print(f"Generated {args.out}: 8 channels, {n} complex samples/channel, Fs={FS}")


def pack(args) -> None:
    # User-provided NumPy archive must contain normalized complex iq[8,N].
    with np.load(args.input, allow_pickle=False) as archive:
        iq = archive["iq"]
    write_bundle(iq, args.out, dict(kind="user", channel_mask=args.mask))
    print(f"Packed arbitrary waveform: {args.out}")


def parse_integer(value: str, radix: str) -> int:
    value = value.strip().replace("_", "")
    if not value or re.search(r"[xz]", value.replace("0x", ""), re.I):
        raise ValueError(f"Invalid or unknown ILA value: {value!r}")
    radix = radix.upper()
    if "HEX" in radix or value.lower().startswith("0x"):
        return int(value, 16)
    if "BIN" in radix or value.lower().startswith("0b"):
        return int(value, 2)
    if "DEC" in radix or "UNSIGNED" in radix or "SIGNED" in radix:
        return int(value, 10)
    raise ValueError(f"Unsupported ILA radix {radix!r}; export with an explicit Radix row")


def decode_ila(path: Path, mask: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    with path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.reader(stream))
    header_index = next((i for i, row in enumerate(rows) if any("scope_adc_i" in x for x in row)), None)
    if header_index is None:
        raise ValueError("CSV has no scope_adc_i column. Use the matching V1 bit/LTX and export the full ILA")
    header = rows[header_index]
    def column(name, width):
        matches = [i for i, x in enumerate(header) if name in x]
        if len(matches) > 1:
            # Vivado may name scalar marker aliases scope_metadata[_N]. Select
            # the complete vector by its declared width, never a scalar alias.
            matches = [i for i in matches if re.search(rf"\[{width-1}:0\]", header[i])]
        if len(matches) != 1:
            raise ValueError(f"Expected one column containing {name}; found {len(matches)}")
        return matches[0]
    columns = [column(n, w) for n, w in (("scope_adc_i", 512), ("scope_adc_q", 512),
                                       ("scope_metadata", 64), ("scope_beat_counter", 32))]
    body = rows[header_index+1:]
    if not body or not body[0] or body[0][0].strip().lower() != "radix":
        raise ValueError("CSV needs Vivado's Radix row; ambiguous numeric bases are rejected")
    radix, body = body[0], body[1:]
    values = []
    for line_number, row in enumerate(body, header_index+3):
        if not row or not any(x.strip() for x in row):
            continue
        if len(row) != len(header):
            raise ValueError(f"CSV line {line_number}: wrong column count")
        try:
            values.append([parse_integer(row[col], radix[col]) for col in columns])
        except ValueError as exc:
            raise ValueError(f"CSV line {line_number}: {exc}") from exc
    if len(values) < 2:
        raise ValueError("Capture needs at least two beats")
    if any(not (0 <= i < 1 << 512 and 0 <= q < 1 << 512 and 0 <= m < 1 << 64 and 0 <= s < 1 << 32)
           for i, q, m, s in values):
        raise ValueError("ILA word exceeds its declared width")
    sequence = np.array([v[3] for v in values], dtype=np.uint32)
    if not np.all((sequence[1:].astype(np.uint64)-sequence[:-1].astype(np.uint64)) & 0xffffffff == 1):
        raise ValueError("Non-contiguous capture: beat counter has a gap/reorder. FFT was refused")
    metadata = np.array([v[2] for v in values], dtype=np.uint64)
    valid_mask = sum(3 << (2*ch) for ch in range(8) if mask & (1 << ch))
    if np.any((metadata & valid_mask) != valid_mask):
        raise ValueError("ADC I/Q valid dropped in a selected channel. Capture again in steady state")
    if np.any(((metadata >> 42) & 1) == 0):
        raise ValueError("Capture includes samples before PS initialization completed")
    if np.any((metadata >> 32) & 255):
        raise ValueError("Capture reports a DAC handshake fault; multi-channel timing is invalid")
    iq = np.empty((8, len(values)*4), dtype=complex)
    for ch in range(8):
        for component in range(2):
            packed = [(v[component] >> (64*ch)) & ((1 << 64)-1) for v in values]
            lanes = np.array([[(w >> (16*j)) & 65535 for j in range(4)] for w in packed], dtype=np.int32)
            lanes[lanes >= 32768] -= 65536
            if component == 0:
                iq[ch] = lanes.reshape(-1)
            else:
                iq[ch] += 1j*lanes.reshape(-1)
    return iq, sequence, metadata


def analyze(args) -> None:
    meta_path = args.metadata or args.input.with_suffix(".json")
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    fs = float(meta["fs_hz"])
    nco = float(meta["nco_hz"])
    mask = args.mask if args.mask is not None else int(meta["channel_mask"])
    if not math.isfinite(fs) or fs <= 0 or not math.isfinite(nco) or not 1 <= mask <= 255:
        raise ValueError("Invalid capture sample rate, NCO or channel mask")
    iq, sequence, status = decode_ila(args.input, mask)
    if "capture_beats" in meta and len(sequence) != int(meta["capture_beats"]):
        raise ValueError("Capture depth does not match armed ILA; partial data was refused")
    args.out.mkdir(parents=True, exist_ok=True)
    meta.update(channel_mask=mask, samples=iq.shape[1], record_seconds=iq.shape[1]/fs,
                fft_bin_hz=fs/iq.shape[1], source_csv=str(args.input.resolve()))
    np.savez_compressed(args.out / "capture.npz", iq=iq, beat_counter=sequence,
                        status=status, metadata=json.dumps(meta))
    summary = []
    spectra = []
    window = np.hanning(iq.shape[1])
    freq = np.fft.fftshift(np.fft.fftfreq(iq.shape[1], 1/fs))
    for ch, row in enumerate(iq):
        spectrum = np.fft.fftshift(np.fft.fft(row*window)) / window.sum()
        db = 20*np.log10(np.maximum(np.abs(spectrum)/32768, 1e-15))
        spectra.append(db)
        summary.append(dict(channel=ch, enabled=bool(mask & (1 << ch)),
                            peak_baseband_hz=float(freq[np.argmax(db)]),
                            rms_code=float(np.sqrt(np.mean(np.abs(row)**2))),
                            component_peak_code=float(max(abs(row.real).max(), abs(row.imag).max()))))
    meta["channels"] = summary
    (args.out / "summary.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    render_scope(args.out / "scope.html", iq, np.array(spectra), meta)
    print(f"Validated {len(sequence)} consecutive beats ({iq.shape[1]} complex samples/channel).")
    print(f"Open {args.out / 'scope.html'}; offline I/Q: {args.out / 'capture.npz'}")


def render_scope(path: Path, iq: np.ndarray, db: np.ndarray, meta: dict) -> None:
    data = dict(meta=meta, i=iq.real.astype(int).tolist(), q=iq.imag.astype(int).tolist(),
                spectrum=np.round(db, 2).tolist())
    template = Path(__file__).with_name("scope_template.html").read_text(encoding="utf-8")
    path.write_text(template.replace("/*CAPTURE_DATA*/null", json.dumps(data, separators=(",", ":"))), encoding="utf-8")


def demod_qpsk(args) -> None:
    with np.load(args.capture, allow_pickle=False) as a:
        iq = a["iq"]
        capture_meta = json.loads(str(a["metadata"]))
    with np.load(args.reference, allow_pickle=False) as a:
        symbols = a["symbols"][args.channel]
        reference_meta = json.loads(str(a["metadata"]))
    if reference_meta.get("kind") != "qpsk":
        raise ValueError("Reference must be generated with --kind qpsk")
    fs = float(capture_meta["fs_hz"])
    if fs != reference_meta["fs_hz"]:
        raise ValueError("Reference and capture Fs differ")
    sps = reference_meta["sps"]
    y = iq[args.channel].copy()
    if np.mean(abs(y)**2) == 0:
        raise ValueError("No received signal")
    # Fourth-power CFO estimate, unambiguous only for |CFO| < Fs/8.
    fourth = (y / max(abs(y).max(), 1))**4
    cfo = np.angle(np.vdot(fourth[:-1], fourth[1:])) * fs/(8*np.pi)
    t = np.arange(len(y))/fs
    y *= np.exp(-2j*np.pi*cfo*t)
    pilot = symbols[:reference_meta["preamble_symbols"]]
    def synchronize(samples):
        best = None
        for offset in range(sps):
            end = offset + ((len(samples)-offset)//sps)*sps
            sampled = samples[offset:end].reshape(-1, sps).mean(axis=1)
            if len(sampled) < len(pilot):
                continue
            correlation = np.correlate(sampled, pilot, "valid")
            energy = np.convolve(abs(sampled)**2, np.ones(len(pilot)), "valid")
            score = abs(correlation)**2 / np.maximum(energy * np.vdot(pilot,pilot).real, 1e-30)
            position = int(np.argmax(score))
            candidate = (float(score[position]), offset, position, sampled)
            if best is None or candidate[0] > best[0]:
                best = candidate
        if best is None or best[0] < 0.5:
            raise ValueError("Known QPSK preamble was not found reliably")
        return best
    score, offset, pos, sampled = synchronize(y)
    phase = np.unwrap(np.angle(sampled[pos:pos+len(pilot)] * np.conj(pilot)))
    residual = np.polyfit(np.arange(len(pilot)), phase, 1)[0] * (fs/sps)/(2*np.pi)
    y *= np.exp(-2j*np.pi*residual*t)
    score, offset, pos, sampled = synchronize(y)
    gain = np.vdot(pilot, sampled[pos:pos+len(pilot)]) / np.vdot(pilot,pilot)
    if abs(gain) < 1e-12:
        raise ValueError("Estimated channel gain is zero")
    count = min(len(symbols), len(sampled)-pos)
    received = sampled[pos:pos+count]/gain
    expected = symbols[:count]
    errors = int(np.count_nonzero((received.real < 0) != (expected.real < 0)) +
                 np.count_nonzero((received.imag < 0) != (expected.imag < 0)))
    result = dict(mode="known-preamble rectangular-QPSK demo; no multipath equalizer",
                  channel=args.channel, coarse_cfo_hz=float(cfo), residual_cfo_hz=float(residual),
                  preamble_score=score, timing_sample=int(offset+pos*sps),
                  compared_symbols=count, compared_bits=2*count, bit_errors=errors,
                  ber=errors/(2*count), evm_rms_percent=float(100*np.sqrt(np.mean(abs(received-expected)**2))))
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out/"qpsk.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    np.savez_compressed(args.out/"qpsk_symbols.npz", received=received, expected=expected)
    print(json.dumps(result, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("generate")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--kind", choices=["tone", "chirp", "qpsk"], default="tone")
    p.add_argument("--samples", type=int, default=32768)
    p.add_argument("--amplitude", type=float, default=0.25)
    p.add_argument("--mask", type=lambda x:int(x,0), default=255)
    p.add_argument("--tone-bin", type=int, default=128)
    p.add_argument("--bandwidth", type=float, default=20e6)
    p.add_argument("--sps", type=int, default=8)
    p.add_argument("--seed", type=int, default=47)
    p.set_defaults(func=generate)
    p = sub.add_parser("pack")
    p.add_argument("--input", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--mask", type=lambda x:int(x,0), default=255)
    p.set_defaults(func=pack)
    p = sub.add_parser("analyze")
    p.add_argument("--input", type=Path, required=True)
    p.add_argument("--metadata", type=Path)
    p.add_argument("--mask", type=lambda x:int(x,0))
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=analyze)
    p = sub.add_parser("demod-qpsk")
    p.add_argument("--capture", type=Path, required=True)
    p.add_argument("--reference", type=Path, required=True)
    p.add_argument("--channel", type=int, choices=range(8), default=0)
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=demod_qpsk)
    args = parser.parse_args()
    try:
        args.func(args)
    except (ValueError, KeyError, OSError) as exc:
        parser.exit(2, f"Error: {exc}\n")


if __name__ == "__main__":
    main()
