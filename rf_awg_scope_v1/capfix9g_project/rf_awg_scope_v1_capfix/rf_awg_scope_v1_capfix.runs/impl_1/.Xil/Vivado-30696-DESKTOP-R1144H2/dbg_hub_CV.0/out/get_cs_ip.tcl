#
#Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
#Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
#
set_param power.BramSDPPropagationFix 1
set_param project.singleFileAddWarning.threshold 0
set_param runs.launchOptions { -jobs 8  }
set_param general.usePosixSpawnForFork 1
set_param chipscope.maxJobs 6
set_param physdb.placeDBImplUsesPlaceStorage 0
set_param logicopt.enableAutoBUFGtoMBUFGXform 1
set_param power.enableUnconnectedCarry8PinPower 1
set_param logicopt.enablePowerLopt 0
set_param logicopt.controlSetOpt 1
set_param power.enableCarry8RouteBelPower 1
set_param synth.enableIncremental 0
set_param power.enableLutRouteBelPower 1
set_param chipscope.flow 0
set part xczu47dr-fsve1156-2-i
set board_part_repo_paths {}
set board_part {}
set board_connections {}
set tool_flow Vivado
set ip_vlnv xilinx.com:ip:xsdbm:3.0
set ip_module_name dbg_hub
set params {{{PARAM_VALUE.C_BSCAN_MODE} {false} {PARAM_VALUE.C_BSCAN_MODE_WITH_CORE} {false} {PARAM_VALUE.C_CLK_INPUT_FREQ_HZ} {100000000} {PARAM_VALUE.C_ENABLE_CLK_DIVIDER} {false} {PARAM_VALUE.C_EN_BSCANID_VEC} {false} {PARAM_VALUE.C_NUM_BSCAN_MASTER_PORTS} {0} {PARAM_VALUE.C_TWO_PRIM_MODE} {false} {PARAM_VALUE.C_USER_SCAN_CHAIN} {1} {PARAM_VALUE.C_USE_EXT_BSCAN} {false} {PARAM_VALUE.C_XSDB_NUM_SLAVES} {2}}}
set intf_params {}
set connectivity {}
set output_xci e:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.runs/impl_1/.Xil/Vivado-30696-DESKTOP-R1144H2/dbg_hub_CV.0/out/result.xci
set output_dcp e:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.runs/impl_1/.Xil/Vivado-30696-DESKTOP-R1144H2/dbg_hub_CV.0/out/result.dcp
set output_dir e:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.runs/impl_1/.Xil/Vivado-30696-DESKTOP-R1144H2/dbg_hub_CV.0/out
set ip_repo_paths {}
set ip_output_repo E:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.cache/ip
set ip_cache_permissions {read write}

set oopbus_ip_repo_paths [get_param chipscope.oopbus_ip_repo_paths]

set synth_opts {}
set xdc_files {}
