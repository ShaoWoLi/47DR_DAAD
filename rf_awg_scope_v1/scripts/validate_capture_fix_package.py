"""Validate the 9G ADC-readback candidate before replacing the default bundle."""
import hashlib
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET
import zipfile


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    package = Path(sys.argv[1]).resolve()
    required = [f"rf_awg_scope_v1.{ext}" for ext in ("bit", "ltx", "xsa")]
    required += ["rf_awg_init.elf", "init_protocol.txt", "timing_summary.rpt", "drc.rpt", "bus_skew.rpt"]
    for name in required:
        if not (package / name).is_file() or (package / name).stat().st_size == 0:
            raise ValueError(f"Missing candidate output: {name}")
    timing = (package / "timing_summary.rpt").read_text()
    row = re.search(r"WNS\(ns\).*?\n\s*[- ]+\n\s*([^\n]+)", timing, re.S)
    if row is None:
        raise ValueError("Missing timing summary")
    fields = row[1].split()
    margins = dict(zip(("wns_ns", "whs_ns", "wpws_ns"), (float(fields[i]) for i in (0, 4, 8))))
    if min(margins.values()) < 0 or any(int(fields[i]) for i in (2, 6, 10)):
        raise ValueError(f"Timing violations: {fields}")
    drc = (package / "drc.rpt").read_text()
    if re.search(r"\|\s*(?:Error|Critical Warning)\s*\||^\S+#\d+\s+(?:Error|Critical Warning)\s*$", drc, re.I | re.M):
        raise ValueError("DRC error/critical warning")
    if "Slack (VIOLATED)" in (package / "bus_skew.rpt").read_text():
        raise ValueError("Bus-skew violation")
    bit_hash = sha(package / "rf_awg_scope_v1.bit")
    with zipfile.ZipFile(package / "rf_awg_scope_v1.xsa") as archive:
        bits = [name for name in archive.namelist() if name.endswith(".bit")]
        if len(bits) != 1 or hashlib.sha256(archive.read(bits[0])).hexdigest() != bit_hash:
            raise ValueError("XSA does not contain the candidate bit")
        hwh = ET.fromstring(archive.read("system.hwh"))
        converters = [m for m in hwh.iter("MODULE") if "usp_rf_data_converter" in m.get("MODTYPE", "")]
        if len(converters) != 1:
            raise ValueError("Expected one RFDC")
        params = {p.get("NAME"): p.get("VALUE") for p in converters[0].iter("PARAMETER")}
        for kind, rate in (("ADC", "5.0"), ("DAC", "9.0")):
            for tile in range(4):
                for key, value in ((f"C_{kind}{tile}_Sampling_Rate", rate),
                                   (f"C_{kind}{tile}_Multi_Tile_Sync", "true")):
                    if params.get(key) != value:
                        raise ValueError(f"Unexpected RFDC configuration: {key}={params.get(key)}")
        (package / "psu_init.tcl").write_bytes(archive.read("psu_init.tcl"))
    elf = (package / "rf_awg_init.elf").read_bytes()
    if elf[:4] != b"\x7fELF" or elf[4] != 2 or int.from_bytes(elf[18:20], "little") != 183:
        raise ValueError("Initializer is not AArch64 ELF")
    # Keep independently collected board evidence when the package is rechecked.
    # A package validator must not erase a successful hardware validation record.
    prior = {}
    evidence_path = package / "hardware_validation.json"
    if evidence_path.is_file():
        try:
            loaded = json.loads(evidence_path.read_text(encoding="utf-8"))
            if isinstance(loaded, dict):
                prior = loaded
        except (OSError, ValueError):
            prior = {}
    result = dict(bit_sha256=bit_hash, xsa_sha256=sha(package / "rf_awg_scope_v1.xsa"),
                  elf_sha256=sha(package / "rf_awg_init.elf"), embedded_bit_matches=True,
                  adc_ram_layout="0x00020001", timing=margins,
                  board_tested=bool(prior.get("board_tested", False)),
                  test_scope=prior.get("test_scope", "build_and_simulation_only"))
    for key in ("initialization", "capture_test", "board_tests"):
        if key in prior:
            result[key] = prior[key]
    (package / "hardware_validation.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
