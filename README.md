# 47DR DAAD AWG and Scope

This repository contains the MATLAB host application and FPGA project for the 47DR RFSoC AWG/oscilloscope workflow.

## Contents

- `rf_awg_scope_v1/`: current source, MATLAB application, RTL, build/program scripts, simulation tests, and the matched 9 GS/s DAC / 5 GS/s ADC release package.

The 9 GS/s package is the board-tested package; the documented board-test scope is initialization and a CH2-to-ADC-CH2 loopback capture.

Start the MATLAB host UI with `rf_awg_scope_v1/Start_AWG_Scope.cmd`. See that project's README and `hardware/dac9g_opt1/README.md` for requirements and operating details.

Vivado-generated caches/runs, machine-local settings, session logs, user captures, and obsolete timing candidates are intentionally excluded. The main RTL and scripts are the maintainable source.
