# 47DR AWG and Scope

Current host and FPGA package: `hardware/dac9g_opt1`, configured for a 9 GS/s DAC and 5 GS/s ADC. MATLAB prepares the waveform; the UI downloads the selected real-valued DAC samples, controls playback, captures ADC RAM through JTAG, and displays time-domain and spectrum views.

## Start the host UI

Run `Start_AWG_Scope.cmd`, or open MATLAB and run `matlab/launch_awg_scope.m`. MATLAB and Vivado/Vitis 2025.2 are required. The launcher searches common MATLAB installation locations; adjust the launcher for a nonstandard installation if needed.

## Current hardware package

Use all files in `hardware/dac9g_opt1` together: BIT, LTX, XSA, `rf_awg_init.elf`, `psu_init.tcl`, and `init_protocol.txt`. Their hashes and validation scope are recorded in `build_manifest.json` and `hardware_validation.json`. Do not mix files from different builds.

The package was programmed to the lab board. Validation covered two successful initializations and a CH2-to-ADC-CH2 loopback capture of 65,520 samples. It did not cover power-cycle cold boot, complete GUI traffic on hardware, external RF measurements, or all channel combinations. The routed timing report records WNS +0.001 ns, TNS 0, and 13 DRC warnings.

## Data path

- Transmit: MATLAB resamples real input data to 9 GS/s. Each selected channel supports 32 to 65,536 samples, in multiples of 32. The FPGA loops the programmed waveform.
- Receive: raw real ADC samples are captured at 5 GS/s, up to 65,520 samples per selected channel, then returned to MATLAB through JTAG.
- The RFDC DUC/mixer and ADC decimation are bypassed in this package.

See `matlab/GUI_README.md` for UI operation, `matlab/README.md` for MATLAB functions, and `REMOTE_LOCAL_MODES.md` for local and remote hardware-server setup.

## Build and tests

The maintainable sources are in `rtl`, `constraints`, `reference`, `scripts`, and `software/src`. `scripts/build.tcl` builds the Vivado design; `scripts/build_software.ps1` builds the RF initialization application when the matching BSP is available. Run `scripts/test_rtl.ps1`, `sim/test_hw_mock.tcl`, and the MATLAB tests for host-side regression.

Vivado-generated caches and runs are omitted from this repository. The current deployment artifacts and final reports remain in `hardware/dac9g_opt1`.
