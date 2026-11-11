set source_project {E:/s9_dac9000/b512s9g_opt1/rf_awg_scope_v1.xpr}
set repository_root [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv] > 1} {
    set source_project [file normalize [lindex $argv 1]]
}
if {[llength $argv] > 0} {
    set project_dir [file normalize [lindex $argv 0]]
} else {
    # Keep Windows implementation/checkpoint paths below 260 characters.
    set project_dir [file normalize [file join $repository_root .. .. .. dac9g_mts_hw]]
}
set out_dir [file join $project_dir artifacts]

if {![file exists $source_project]} {
    error "Missing baseline 9 GS/s project: $source_project"
}
set copied_project [file join $project_dir rf_awg_scope_v1_mts.xpr]
if {![file exists $copied_project]} {
    file mkdir $project_dir
    open_project $source_project
    save_project_as -force -dir $project_dir rf_awg_scope_v1_mts
} else {
    open_project $copied_project
}
file mkdir $out_dir
set bd_file [get_files -quiet */system.bd]
if {[llength $bd_file] != 1} {
    error "Expected one system.bd in copied project, found [llength $bd_file]"
}
open_bd_design $bd_file
set rfdc [get_bd_cells -quiet usp_rf_data_converter_0]
if {[llength $rfdc] != 1} {
    error "Cannot find RFDC block design cell usp_rf_data_converter_0"
}
set mts_properties [list]
foreach kind {ADC DAC} {
    for {set tile 0} {$tile < 4} {incr tile} {
        lappend mts_properties CONFIG.${kind}${tile}_Multi_Tile_Sync true
    }
}
set_property -dict $mts_properties $rfdc
# The board's LMK table supplies 200 MHz. Do not inherit the former
# 180 MHz DAC reference, which would make configured rates misleading.
set_property CONFIG.DAC2_Refclk_Freq 200.000 $rfdc
# MTS requires clocks coherent with the converters. The former PS-fed
# dual-output MMCM also produced 421.875 MHz instead of ADC 416.666667 MHz.
set_property CONFIG.ADC1_Outclk_Freq 312.500 $rfdc
set dac_wiz [get_bd_cells clk_wiz_0]
set old_input [get_bd_nets -of_objects [get_bd_pins clk_wiz_0/clk_in1]]
disconnect_bd_net $old_input [get_bd_pins clk_wiz_0/clk_in1]
set_property -dict [list CONFIG.PRIM_SOURCE No_buffer CONFIG.PRIM_IN_FREQ 562.500 \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 562.500] $dac_wiz
connect_bd_net [get_bd_pins usp_rf_data_converter_0/clk_dac2] [get_bd_pins clk_wiz_0/clk_in1]
set adc_wiz [get_bd_cells -quiet clk_wiz_adc]
if {![llength $adc_wiz]} {
    set adc_wiz [create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_adc]
}
# ADC PLL MTS scans can stop the RFDC clk_adc1 output. The PL SYSREF
# counter must remain clocked during those scans, so use the independent
# board LMK PL_CLK output (same 200 MHz reference as both converter PLLs).
set_property -dict [list CONFIG.PRIM_SOURCE No_buffer CONFIG.PRIM_IN_FREQ 200.000 \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 416.666667 CONFIG.USE_RESET false] $adc_wiz
set adc_input_net [get_bd_nets -quiet -of_objects [get_bd_pins clk_wiz_adc/clk_in1]]
if {[llength $adc_input_net]} {
    disconnect_bd_net $adc_input_net [get_bd_pins clk_wiz_adc/clk_in1]
}
set adc_reference [get_bd_ports -quiet adc_fabric_ref]
if {![llength $adc_reference]} {set adc_reference [create_bd_port -dir I -type clk adc_fabric_ref]}
set_property CONFIG.FREQ_HZ 200000000 $adc_reference
connect_bd_net $adc_reference [get_bd_pins clk_wiz_adc/clk_in1]
set old_adc_net [get_bd_nets -of_objects [get_bd_ports adc_capture_clk]]
foreach endpoint [list [get_bd_ports adc_capture_clk] [get_bd_pins rst_adc_clk/slowest_sync_clk] \
    [get_bd_pins usp_rf_data_converter_0/m0_axis_aclk] [get_bd_pins usp_rf_data_converter_0/m1_axis_aclk] \
    [get_bd_pins usp_rf_data_converter_0/m2_axis_aclk] [get_bd_pins usp_rf_data_converter_0/m3_axis_aclk]] {
    disconnect_bd_net $old_adc_net $endpoint
    connect_bd_net [get_bd_pins clk_wiz_adc/clk_out1] $endpoint
}
set old_adc_lock [get_bd_nets -of_objects [get_bd_pins rst_adc_clk/dcm_locked]]
disconnect_bd_net $old_adc_lock [get_bd_pins rst_adc_clk/dcm_locked]
connect_bd_net [get_bd_pins clk_wiz_adc/locked] [get_bd_pins rst_adc_clk/dcm_locked]
set_property -dict [list CONFIG.NUM_OUT_CLKS 1 CONFIG.CLKOUT2_USED false] $dac_wiz
set_property CONFIG.FREQ_HZ 562500000 [get_bd_ports data_clk]
set_property CONFIG.FREQ_HZ 416666666 [get_bd_ports adc_capture_clk]
foreach kind {ADC DAC} {
    for {set tile 0} {$tile < 4} {incr tile} {
        set key CONFIG.${kind}${tile}_Multi_Tile_Sync
        set value [get_property $key $rfdc]
        puts "MTS_CONFIG $key=$value"
        if {$value ne "true"} {
            error "RFDC property did not enable MTS: $key=$value"
        }
    }
}
# Disabling MTS removes these RFDC pins and Vivado drops their net
# endpoints. Re-enabling the tile properties alone does not reconnect them.
foreach kind {adc dac} {
    set external [get_bd_ports user_sysref_${kind}_0]
    set input_pin [get_bd_pins usp_rf_data_converter_0/user_sysref_${kind}]
    set net [get_bd_nets -quiet -of_objects $external]
    set pin_net [get_bd_nets -quiet -of_objects $input_pin]
    if {[llength $pin_net] && $pin_net ne $net} {
        error "RFDC SYSREF pin is connected to an unexpected net: $input_pin $pin_net"
    }
    if {![llength $pin_net]} {
        connect_bd_net $external $input_pin
    }
    set verified_net [get_bd_nets -of_objects $input_pin]
    set connected_ports [get_bd_ports -quiet -of_objects $verified_net]
    if {[lsearch -exact $connected_ports $external] < 0} {
        error "RFDC SYSREF connection verification failed for $kind"
    }
    puts "SYSREF_CONNECTED $external -> $input_pin"
}
validate_bd_design
save_bd_design
# Use the scoped top/constraints snapshot; never alter the archived baseline.
set old_top [get_files -quiet */adaloop_top.v]
remove_files $old_top
add_files -norecurse [file join $repository_root rtl candidates dac9g_mts adaloop_top.v]
set old_async [get_files -quiet */timing_async.xdc]
if {[llength $old_async]} {remove_files $old_async}
set async_file [file join $repository_root constraints timing_init_mts_async.xdc]
if {![llength [get_files -quiet $async_file]]} {add_files -fileset constrs_1 -norecurse $async_file}
set_property USED_IN_SYNTHESIS false [get_files $async_file]
set_property PROCESSING_ORDER LATE [get_files $async_file]
reset_target all $bd_file
generate_target all -force $bd_file
set generated_system [file join $project_dir rf_awg_scope_v1_mts.gen sources_1 bd system synth system.v]
set generated_file [open $generated_system r]
set generated_text [read $generated_file]
close $generated_file
foreach kind {adc dac} {
    if {[string first ".user_sysref_${kind}(user_sysref_${kind}_0)" $generated_text] < 0} {
        error "Generated RFDC user_sysref_${kind} is not connected to the external SYSREF input"
    }
}
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
puts "SYNTH_STATUS $synth_status"
if {![string match "*Complete!*" $synth_status]} {
    error "Synthesis did not complete: $synth_status"
}
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
set run_status [get_property STATUS [get_runs impl_1]]
puts "IMPL_STATUS $run_status"
if {![string match "*Complete!*" $run_status]} {
    error "Implementation did not complete: $run_status"
}

open_run impl_1
write_hw_platform -fixed -include_bit -force -file [file join $out_dir rf_awg_scope_v1.xsa]
set run_dir [get_property DIRECTORY [get_runs impl_1]]
file copy -force [file join $run_dir adaloop_top.bit] [file join $out_dir rf_awg_scope_v1.bit]
file copy -force [file join $run_dir adaloop_top.ltx] [file join $out_dir rf_awg_scope_v1.ltx]
report_timing_summary -file [file join $out_dir timing_summary.rpt]
puts "MTS_CANDIDATE_ARTIFACTS $out_dir"
close_project
