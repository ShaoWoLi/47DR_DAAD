# Implementation Status

## Current 9 GS/s Candidate Host Integration (2026-11-09)

## ADC Capture Fix Release (2026-11-10)

- The default `hardware/dac9g_opt1` package now contains the capfix9g bitstream, matching XSA and rebuilt `rf_awg_init.elf`; the package hashes and artifact sizes are recorded in `hardware/dac9g_opt1/build_manifest.json`.
- The ADC capture status interpretation is fixed: `state=2` means `done=1, busy=0` and is a successful capture. The host no longer reports this state as a timeout.
- ADC RAM transfer progress now reports the channels selected by the receive mask (for example, decimal mask `16` reports `CH4` instead of the former hardcoded `CH0`).
- ADC capture length remains the FPGA's fixed maximum of 65,520 samples per selected channel. It is independent of the 9,216-sample DAC playback buffer; playback loops while the ADC capture fills its own RAM.
- ADC RAM JTAG addressing is fixed for the 768-bit entries: one entry occupies 24 32-bit words. The ABI is now `0x00020001`, so an old bitstream is rejected instead of being decoded with the wrong stride.
- The new candidate was programmed to the laboratory board. Initialization reached stage 99 with `CONFIG_DONE=1`, `ps_ready=1`, `fault=0`, and `fault_channels=0`.
- A real CH2 to ADC CH2 loopback captured 65,520 samples (`channel_mask=4`, `state=2`). MATLAB imported the CSV/MAT and verified the waveform and spectrum at 5 GS/s; FFT peak was 99.587912 MHz and zero fraction was 0%.
- Timing for this candidate is closed: WNS +0.001 ns, WHS +0.003 ns, WPWS +0.089 ns, TNS/THS 0, zero setup/hold/pulse-width endpoints, zero bus-skew violations and zero DRC errors (13 warnings remain).
- Evidence is retained in `logs/adc_capture_fix_20261110.md`, `logs/verify_adc_capture_fix_20261110.log`, `app_data/captures/adc_ch2_capfix_20261110.csv`, and `app_data/captures/adc_ch2_capfix_20261110.mat`.

- The selected host package is `hardware/dac9g_opt1`: DAC 9 GS/s, ADC 5 GS/s, No-DUC transmit, 256-bit DAC AXI at 562.5 MHz.
- The 562.5 MHz value is the FPGA AXI beat clock (9 GS/s / 16 samples per beat), not a required MATLAB source rate.
- The published bitstream uses 512-bit playback RAM words at 281.25 MHz, each split into two 256-bit RFDC beats. Final records must contain complete 32-sample RAM words; the host programs length as sample_count/32. On 2026-11-10 the host's stale 16-sample validation and 64-sample length conversion were corrected. Resampling evaluates the exact 9 GS/s time grid. Final lengths must be integers divisible by 32 in [32,65536]; invalid records are rejected without truncation, padding or retiming. Imports select the full record by default; users may explicitly select a valid interval.
- MATLAB TX now accepts real source samples with a user-supplied source rate, periodically resamples them to 9 GS/s, and exports signed 16-bit samples. No MATLAB carrier insertion or IQ-to-real upconversion is performed; RFDC DUC/mixer remains bypassed.
- The MATLAB receive path now uses the candidate ADC capture RAM/JTAG map: command 8 arms capture, `0x90200028` reports busy/done, `0x9020002c` reports the sample count, and `0x91000000` is the 1 MiB ADC RAM window. Each lane returns signed 16-bit real ADC samples at 5 GS/s, up to 65,520 samples.
- Capture CSV plus JSON metadata is loaded into the MATLAB viewer and saved as MAT. The viewer presents one raw ADC trace and a 5 GS/s spectrum; the legacy I/Q ILA importer remains available for old records.
- Tcl host mocks cover capture command/status, channel RAM strides, 48-sample RAM entry ordering, signed sample unpacking, metadata and MATLAB-facing capture. MATLAB GUI tests use only mocked board APIs.
- The final 2026-11-09 initialization fix restores PL SYSREF connections, matches the DAC reference to 200 MHz, and gives the ADC fabric an independent 416.666667 MHz MMCM clock derived from stable LMK PL_CLK. DAC AXI remains 562.5 MHz.
- Initialization now runs PS/LMK preparation before PL programming, then resumes the A53 for RFDC setup and MTS. The host clears stale ready/ack words before each run; ELF cache maintenance covers full 64-byte lines. `init_protocol.txt` is generated from the matching ELF symbols and is required by the GUI/script.
- The final script passed two consecutive full board initializations (run3/run4): all four DAC and all four ADC tiles completed MTS, `AWG READY` was printed, RAM stage was 99, CONFIG_DONE=1, and JTAG reported ps_ready=1, fault=0, fault_channels=0. No MTS bypass or forced-ready logic was used.
- The default `hardware/dac9g_opt1` package contains the tested matched bit/LTX/XSA/ELF, PS init and protocol. `board_tested=true` is scoped to initialization plus the CH2 loopback capture; complete GUI traffic, power-cycle cold boot, and external analog measurements were not tested in this session.
- Final routed timing: WNS 0.000 ns, TNS 0, WHS +0.008 ns, THS 0, WPWS +0.089 ns, no setup/hold/pulse-width failing endpoints. DRC: 0 errors and 13 warnings; bus-skew audit passed. Full reports and hashes accompany the package. See `logs/initialization_fix_20261109.md` for failure history, evidence, and exact artifact hashes.

The historical notes below describe earlier 10 GS/s/5 GS/s probes and are retained as development history; they do not describe the current 9 GS/s host package.

Date: 2026-11-05. Project: `xczu47dr-fsve1156-2-i`, Vivado 2025.2.

## Implemented in source

- TX sample RAM is configured for 128 KiB per physical DAC channel, 8 channels total. The 8-bank layout stores 65536 signed 16-bit real samples/channel (1 MiB total).
- The player presents 16 consecutive real samples in a 256-bit AXI4-Stream beat. At 10 GS/s this requires a 625 MHz sample clock and an RFDC datapath with interpolation disabled and DAC mode `No DUC 0 to Fs/2`.
- MATLAB accepts 625 MS/s complex input, periodically interpolates x16, and forms `real(z*exp(j*2*pi*1.5GHz*t))` at 10 GS/s. The maximum baseband frame is 4096 complex samples, yielding 65536 stored real samples (6.5536 us). The selected baseband length must be a multiple of four; the resulting real sample count is a multiple of 16.
- Each `chN.hex` line packs two signed int16 real samples, earlier time sample in bits [15:0], next sample in [31:16]. JTAG writes the packed words to `0x90000000 + CH*0x20000`. Control/status registers start at `0x90200000`.
- Host Tcl validates No-DUC metadata and length before writing, stops playback, downloads, reads back, then configures the number of 16-sample beats and channel mask.
- MATLAB TX preview treats the stored waveform as real DAC samples: it plots one trace, uses normalized DAC amplitude, and labels the spectrum as the real DAC output spectrum. RX preview retains its separate complex I/Q and ADC-code scale.

## ADC 5 GS/s raw-path validation

The requested receive behavior is 5 GS/s physical ADC sampling with RFDC mixer/DDC bypassed and decimation disabled, capturing all 8 channels and transferring records to MATLAB over JTAG. This is not implemented in the production BD or RTL. The unintegrated `adc_capture.sv` buffer is configured to stay within 128 KiB/channel: the 192-bit input beat contains twelve 16-bit container samples, so its maximum beat-aligned length is 65,520 samples (131,040 bytes/channel). The planned eight-channel read window is 1 MiB.

The earlier 312.5 MHz threshold was a hard-coded check in the probe script, not an RFDC rejection or a device limit. In the isolated one-channel probe, Vivado 2025.2 accepted the no-decimation configuration, validated the BD, generated the IP, and completed RFDC out-of-context synthesis with zero errors. It derived `ADC1_Fabric_Freq=416.667 MHz`, a 2.4 ns AXIS clock constraint, and a 192-bit `m10_axis_tdata` bus (12 packed 16-bit words per beat). The generated IP OOC constraints explicitly contain `create_clock -period 2.400` for this output. This verifies parameter legality and RFDC synthesis only; it does not establish top-level PL timing closure, multi-tile clock/MTS operation, full design implementation, or board operation. The old statement that this configuration was rejected was incorrect.

The RFDC ADC data width is limited to supported converter formats; the probe uses 12-bit ADC data and the RFDC presents each sample in its 16-bit AXIS container. The full 8-channel capture design is still pending. The configured at-most-128-KiB-per-channel capture buffer needs integrated synthesis/resource validation and a working JTAG readback path. The generated RFDC probe and scripts are isolated from the production design.

The RF-DAC 10 GS/s parameter-only probe succeeded for the DAC datapath settings, but it did not validate clocks, user SYSREF/MTS, PL timing, the formal BD, bitstream generation or hardware operation. ADC raw capture storage, JTAG readback, the MATLAB raw-ADC parser/display, software initialization changes for independent ADC/DAC clocks, and a new matching release are still pending.

## Verification performed

- 2026-11-05 follow-up: the all-tile 10 GS/s DAC / 5 GS/s ADC probe is still not valid for production integration. The first run exposed stale 245.76 MHz metadata on the BD `data_clk` port; after correcting that metadata, Vivado 2025.2 still rejects the ADC reset domain because `rst_adc_clk/slowest_sync_clk` has no valid clock source. The second clock output from the reference Clock Wizard is not recognized as a valid BD clock source in this probe, so its generation and association need to be resolved before treating the 416.667 MHz domain or full interface widths as verified. No production source, BD, or release artifact was changed by these probe runs.

- 2026-11-05 follow-up: Vivado 2025.2 `scripts/build.tcl synth` passes for the currently checked-in legacy BD/top (0 synthesis errors). The 8-channel TX RAM maps to 256 RAMB36; total utilization is 383.5/1080 BRAM tiles including the RFDC and other existing logic. This is not the requested raw-ADC design: the generated RFDC fabric clocks remain 245.76 MHz, ADC AXIS ports remain 64-bit I/Q, and no ADC capture RAM is instantiated.
- 2026-11-05 follow-up: `scripts/test_rtl.ps1` passes for the existing AWG testbench. Elaboration warns that `capture_read_req` in `awg_subsystem` is unconnected, confirming the in-progress capture register path is not integrated.
- 2026-11-05 follow-up: `scripts/check_release.py` rejects the existing release because hardware source is newer than `output/rf_awg_scope_v1.bit`. Existing output artifacts were not overwritten; their timestamps remain 2026-11-03 for bit/LTX/XSA and 2026-11-04 for ELF.
- 2026-11-05 follow-up: TX address decode, channel stride, RAM/player depth, host validation and MATLAB maximum frame are set to 128 KiB/channel. The unintegrated ADC capture module is capped at 65,520 16-bit samples/channel (131,040 bytes, beat-aligned and within 128 KiB); its host address mapping reserves 128 KiB/channel. The AWG and ADC RTL simulations pass, and the existing top-level synthesis passes with 256 TX RAMB36. ADC storage is not instantiated in that top-level synthesis.

- `matlab/test_awg_matlab.m` and `matlab/test_awg_app.m`: direct arbitrary-rate real-to-9 GS/s resampling, 16-bit paired-word packing and legacy ADC-IQ importer checks.
- `matlab/test_awg_app.m`: PASS, using the production MATLAB/Vivado process protocol with all board hardware APIs mocked. It does not program hardware.
- The GUI regression also asserts that TX input is real-valued, uses 10 GS/s metadata, and renders one DAC trace with the DAC amplitude and frequency labels.
- `scripts/test_rtl.ps1`: PASS, including 8-lane data, RAM access, control CDC, loop playback, fault handling and stop behavior.
- `sim/test_hw_mock.tcl`: PASS for JTAG register/RAM transactions, readback verification, command handling and capture mock.
- Host mock capture metadata was adjusted to describe its 4096-beat synthetic fixture; this is test-only and does not change the 8192-beat legacy hardware ILA.
- `scripts/probe_raw5g_adc.tcl 1 0 1`: single ADC block, 5 GS/s, mixer bypass, no decimation; BD validation and RFDC IP generation passed, and `scripts/validate_raw5g_adc_ooc.tcl` completed the RFDC OOC synthesis run successfully. This is not full-system timing or hardware validation.
- No production BD validation/synthesis/implementation or board testing was completed for the new target. `output/rf_awg_scope_v1.bit`, `.ltx`, `.xsa` and `rf_awg_init.elf` remain old release artifacts; `board_tested` remains false. Do not use those artifacts to test the new TX format.

## Historical blocker before the capfix9g release

The following paragraph records the pre-capfix9g state for traceability. It is superseded by the ADC capture fix release above and must not be used as the current deployment status: the raw ADC path had not yet been integrated, the production RFDC configuration was still the legacy shared-clock design, and no matching board package had been validated. The capfix9g package now contains the integrated ADC capture path, matching artifacts, closed timing, and the documented CH2 loopback board evidence.
