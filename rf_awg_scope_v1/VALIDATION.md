# Validation Summary

## Current 9 GS/s / 5 GS/s package

The current package is `hardware/dac9g_opt1`. `hardware_validation.json` records matching artifacts, hashes, timing, and the board-test scope.

- Two consecutive full initialization runs completed with all ADC/DAC tiles synchronized, `ps_ready=1`, and no reported RF fault.
- A CH2-to-ADC-CH2 loopback captured 65,520 samples. MATLAB imported the capture and checked its waveform and spectrum.
- Routed timing: WNS +0.001 ns, TNS 0, WHS +0.003 ns, WPWS +0.089 ns; 13 DRC warnings remain.
- The test scope does not include power-cycle cold boot, end-to-end GUI operation on the board, external RF measurements, or full analog calibration.

## Historical timing candidates

The 10 GS/s and 9.85 GS/s candidates are retained under the repository-level `versions/` directory. Both have negative WNS and remain timing-unclosed. Their reports are preserved with their matching project sources and BIT/LTX artifacts.

Simulation fixtures use synthetic data and do not constitute board measurements.
