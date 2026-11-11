"""Check generated release files, timing and probes; write their SHA256 manifest.

Uses only the Python standard library. This checks a local build, not a board.
"""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    output = ROOT / "output"
    artifacts = [output / f"rf_awg_scope_v1.{ext}" for ext in ("bit", "ltx", "xsa")]
    artifacts.append(output / "rf_awg_init.elf")
    for path in artifacts:
        if not path.is_file() or path.stat().st_size == 0:
            raise ValueError(f"Missing artifact: {path}")
    hardware_sources = [p for folder in ("rtl", "constraints", "reference")
                        for p in (ROOT / folder).rglob("*")
                        if p.is_file() and p.suffix in (".v", ".sv", ".xdc", ".bd", ".xci")]
    software_sources = [p for p in (ROOT / "software/src").rglob("*")
                        if p.suffix in (".c", ".h", ".ld")]
    if any(p.stat().st_mtime > artifacts[0].stat().st_mtime for p in hardware_sources):
        raise ValueError("Hardware source is newer than bitstream: rebuild before release")
    if any(p.stat().st_mtime > artifacts[3].stat().st_mtime for p in software_sources):
        raise ValueError("Software source is newer than ELF: rebuild before release")
    with zipfile.ZipFile(output / "rf_awg_scope_v1.xsa") as archive:
        bit_names = [n for n in archive.namelist() if n.endswith(".bit")]
        if len(bit_names) != 1 or hashlib.sha256(archive.read(bit_names[0])).hexdigest() != sha256(artifacts[0]):
            raise ValueError("XSA does not contain the delivered bitstream")
    ltx = json.loads((output / "rf_awg_scope_v1.ltx").read_text())
    probes = {}

    def walk(value):
        if isinstance(value, dict):
            if "portIndex" in value and "nets" in value:
                probes[value["portIndex"]] = value
            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(ltx)
    expected = [(512, "scope_adc_i"), (512, "scope_adc_q"), (64, "scope_metadata"),
                (32, "scope_beat_counter"), (1, "scope_capture_trigger"), (1, "scope_start_trigger")]
    for index, (width, name) in enumerate(expected):
        probe = probes[index]
        net = probe["nets"]
        actual_width = abs(probe["rightIndex"] - probe["leftIndex"]) + 1
        if actual_width != width or len(net) != 1 or net[0]["name"] != name:
            raise ValueError(f"Probe {index} is incompatible with host tools: {probe}")
    timing = (ROOT / "logs/timing_summary.rpt").read_text()
    row = re.search(r"WNS\(ns\).*?\n\s*[- ]+\n\s*([^\n]+)", timing, re.S)
    if row is None:
        raise ValueError("Missing timing summary")
    fields = row.group(1).split()
    wns, whs, wpws = (float(fields[i]) for i in (0, 4, 8))
    if min(wns, whs, wpws) < 0:
        raise ValueError("Setup, hold or pulse-width timing failed")
    drc = (ROOT / "logs/drc.rpt").read_text()
    if re.search(r"\|\s*(?:Error|Critical Warning)\s*\|", drc, re.I):
        raise ValueError("DRC contains an error or critical warning")
    tests = {
        "rtl": "PASS: All eight channels" in (ROOT / "logs/rtl_tests.log").read_text(encoding="utf-8-sig"),
        "host": bool(re.search(r"^OK$", (ROOT / "logs/host_tests.log").read_text(encoding="utf-8-sig"), re.M)),
        "jtag_mock": "PASS: Mock JTAG" in (ROOT / "logs/hw_mock_console.log").read_text(encoding="utf-8-sig"),
        "matlab_app": "PASS: MATLAB GUI" in (ROOT / "logs/matlab_app_tests.log").read_text(encoding="utf-8-sig"),
    }
    if not all(tests.values()):
        raise ValueError(f"Incomplete regression tests: {tests}")
    host_sources = [p for folder in ("matlab", "scripts", "tools")
                    for p in (ROOT / folder).rglob("*")
                    if p.is_file() and p.suffix in (".m", ".tcl", ".py", ".ps1", ".html")]
    host_sources.append(ROOT / "Start_AWG_Scope.cmd")
    manifest = dict(format="47dr-release-v1", checked_utc=datetime.now(timezone.utc).isoformat(),
                    target="xczu47dr-fsve1156-2-i", vivado="2025.2", board_tested=False,
                    timing_ns=dict(wns=wns, whs=whs, wpws=wpws), tests=tests,
                    sources={p.relative_to(ROOT).as_posix(): sha256(p)
                             for p in sorted(hardware_sources + software_sources)},
                    host_sources={p.relative_to(ROOT).as_posix(): sha256(p) for p in sorted(host_sources)},
                    artifacts={p.name: dict(bytes=p.stat().st_size, sha256=sha256(p)) for p in artifacts})
    (output / "release.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
