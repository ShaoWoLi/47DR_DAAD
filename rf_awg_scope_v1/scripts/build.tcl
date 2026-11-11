# vivado -mode batch -source scripts/build.tcl -tclargs create|synth|bit ?build_dir?
set root [file normalize [file join [file dirname [info script]] ..]]
set mode [expr {[llength $argv] ? [lindex $argv 0] : "create"}]
if {$mode ni {create synth bit}} {error "Mode must be create, synth or bit"}
set build_name [expr {[llength $argv] > 1 ? [lindex $argv 1] : "build_10g5g_fix3"}]
if {![regexp {^[A-Za-z0-9_-]+$} $build_name]} {error "Invalid build directory name: $build_name"}
set release_name [expr {[llength $argv] > 2 ? [lindex $argv 2] : "output_10g5g"}]
if {![regexp {^[A-Za-z0-9_-]+$} $release_name]} {error "Invalid release directory name: $release_name"}
set impl_strategy ""
set dac_rate_gsps 10.0
if {[llength $argv] > 3} {
    if {[string is double -strict [lindex $argv 3]]} {
        set dac_rate_gsps [lindex $argv 3]
    } else {
        set impl_strategy [lindex $argv 3]
        if {[llength $argv] > 4} {set dac_rate_gsps [lindex $argv 4]}
    }
}
if {![string is double -strict $dac_rate_gsps] || $dac_rate_gsps < 0.5 || $dac_rate_gsps > 10.0} {
    error "DAC rate must be between 0.5 and 10.0 GS/s"
}
set dac_axis_mhz [expr {$dac_rate_gsps * 1000.0 / 16.0}]
set dac_axis_hz [expr {round($dac_axis_mhz * 1000000.0)}]
set jobs [expr {[info exists ::env(RF_AWG_VIVADO_JOBS)] ? $::env(RF_AWG_VIVADO_JOBS) : 4}]
if {![string is integer -strict $jobs] || $jobs < 1} {error "RF_AWG_VIVADO_JOBS must be a positive integer"}
proc ensure_bd_connection {source sink} {
    set source_net [get_bd_nets -quiet -of_objects $source]
    set sink_net [get_bd_nets -quiet -of_objects $sink]
    if {[llength $source_net] && $source_net eq $sink_net} {return}
    if {[llength $sink_net]} {disconnect_bd_net $sink_net $sink}
    connect_bd_net $source $sink
}
set build [file join $root $build_name]
set reports [file join $build reports]
set release [file join $root $release_name]
set xpr [file join $build rf_awg_scope_v1.xpr]
file mkdir $reports
file mkdir [file join $root logs]
if {![file exists $xpr]} {
    create_project rf_awg_scope_v1 $build -part xczu47dr-fsve1156-2-i
    set_property target_language Verilog [current_project]
    add_files [glob [file join $root rtl *.v] [file join $root rtl *.sv]]
    import_files -norecurse [file join $root reference system system.bd]
    set bd [get_files */system.bd]
    open_bd_design $bd
    foreach {name source} {
        rf_resetn rst_rf_clk/peripheral_aresetn
        host_resetn rst_ps8_0_99M/peripheral_aresetn
    } {
        set port [create_bd_port -dir O -type rst $name]
        set_property CONFIG.POLARITY ACTIVE_LOW $port
        connect_bd_net [get_bd_pins $source] $port
    }
    validate_bd_design
    save_bd_design
    # Keep the RFDC/PS configuration of the supplied reference project.
    set_property synth_checkpoint_mode Hierarchical $bd
    create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name jtag_awg_axi
    set_property -dict [list CONFIG.PROTOCOL 2 CONFIG.M_AXI_DATA_WIDTH 32] [get_ips jtag_awg_axi]
    create_ip -name ila -vendor xilinx.com -library ip -module_name ila_awg_scope
    set_property -dict [list CONFIG.C_NUM_OF_PROBES 5 CONFIG.C_DATA_DEPTH 8192 \
        CONFIG.C_PROBE0_WIDTH 16 CONFIG.C_PROBE1_WIDTH 8 \
        CONFIG.C_PROBE2_WIDTH 32 CONFIG.C_PROBE3_WIDTH 1 \
        CONFIG.C_PROBE4_WIDTH 1 \
        CONFIG.C_EN_STRG_QUAL 1 CONFIG.C_ADV_TRIGGER false] [get_ips ila_awg_scope]
    add_files -fileset constrs_1 [glob [file join $root constraints *.xdc]]
    set_property top adaloop_top [current_fileset]
    update_compile_order -fileset sources_1
} else {
    open_project $xpr
}
set bd [get_files */system.bd]
open_bd_design $bd
set rf [get_bd_cells usp_rf_data_converter_0]
set ila [get_ips ila_awg_scope]
set_property -dict [list CONFIG.C_NUM_OF_PROBES 5 CONFIG.C_DATA_DEPTH 8192 \
    CONFIG.C_PROBE0_WIDTH 16 CONFIG.C_PROBE1_WIDTH 8 \
    CONFIG.C_PROBE2_WIDTH 32 CONFIG.C_PROBE3_WIDTH 1 \
    CONFIG.C_PROBE4_WIDTH 1 \
    CONFIG.C_EN_STRG_QUAL 1 CONFIG.C_ADV_TRIGGER false] $ila
set cfg [list CONFIG.ADC_RTS false CONFIG.Calibration_Freeze false]
for {set t 0} {$t < 4} {incr t} {
    lappend cfg CONFIG.ADC${t}_Sampling_Rate 5.0 \
        CONFIG.ADC${t}_PLL_Enable [expr {$t == 1 ? "true" : "false"}] \
        CONFIG.ADC${t}_Clock_Source 1 \
        CONFIG.ADC${t}_Clock_Dist [expr {$t == 1 ? 2 : 0}] \
        CONFIG.ADC${t}_Refclk_Freq [format %.3f [expr {$t == 1 ? 200.0 : 5000.0}]]
    lappend cfg CONFIG.DAC${t}_Sampling_Rate $dac_rate_gsps \
        CONFIG.DAC${t}_PLL_Enable [expr {$t == 2 ? "true" : "false"}] \
        CONFIG.DAC${t}_Clock_Source 6 \
        CONFIG.DAC${t}_Clock_Dist [expr {$t == 2 ? 2 : 0}] \
        CONFIG.DAC${t}_Refclk_Freq [format %.3f [expr {$t == 2 ? $dac_rate_gsps * 1000.0 / 50.0 : $dac_rate_gsps * 1000.0}]] \
        CONFIG.DAC${t}_Outclk_Freq [format %.3f $dac_axis_mhz]
    foreach b {0 2} {
        lappend cfg CONFIG.ADC_Slice${t}${b}_Enable true \
            CONFIG.ADC_Decimation_Mode${t}${b} 1 \
            CONFIG.ADC_Mixer_Mode${t}${b} 2 \
            CONFIG.ADC_Mixer_Type${t}${b} 1 \
            CONFIG.ADC_Data_Type${t}${b} 0 \
            CONFIG.ADC_Data_Width${t}${b} 12 \
            CONFIG.DAC_Slice${t}${b}_Enable true \
            CONFIG.DAC_Mode${t}${b} 3 \
            CONFIG.DAC_Data_Type${t}${b} 0 \
            CONFIG.DAC_Interpolation_Mode${t}${b} 1 \
            CONFIG.DAC_Data_Width${t}${b} 16
    }
}
set_property -dict $cfg $rf
set clk [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_IN_FREQ 99.999001 \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [format %.6f $dac_axis_mhz] \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ 416.667 \
    CONFIG.CLKOUT2_USED true] $clk
ensure_bd_connection [get_bd_ports fclk_100m] [get_bd_pins $clk/clk_in1]
set dac_clk_hz [get_property CONFIG.FREQ_HZ [get_bd_pins $clk/clk_out1]]
if {abs($dac_clk_hz - $dac_axis_hz) > 10000} {
    error "Clock Wizard DAC clock mismatch: got $dac_clk_hz Hz, expected $dac_axis_hz Hz"
}
set adc_clk_hz [get_property CONFIG.FREQ_HZ [get_bd_pins $clk/clk_out2]]
set adc_clock [get_bd_ports -quiet adc_capture_clk]
if {![llength $adc_clock]} {set adc_clock [create_bd_port -dir O -type clk adc_capture_clk]}
set_property CONFIG.FREQ_HZ $adc_clk_hz $adc_clock
set adc_reset [get_bd_ports -quiet adc_axis_resetn]
if {![llength $adc_reset]} {set adc_reset [create_bd_port -dir O -type rst adc_axis_resetn]}
set_property CONFIG.POLARITY ACTIVE_LOW $adc_reset
if {![llength [get_bd_cells -quiet rst_adc_clk]]} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_adc_clk
}
ensure_bd_connection [get_bd_pins $clk/clk_out2] [get_bd_ports $adc_clock]
ensure_bd_connection [get_bd_pins $clk/clk_out2] [get_bd_pins rst_adc_clk/slowest_sync_clk]
ensure_bd_connection [get_bd_ports pl_resetn0] [get_bd_pins rst_adc_clk/ext_reset_in]
ensure_bd_connection [get_bd_pins $clk/locked] [get_bd_pins rst_adc_clk/dcm_locked]
ensure_bd_connection [get_bd_pins rst_adc_clk/peripheral_aresetn] [get_bd_ports $adc_reset]
foreach t {0 1 2 3} {
    ensure_bd_connection [get_bd_pins $clk/clk_out2] [get_bd_pins $rf/m${t}_axis_aclk]
    ensure_bd_connection [get_bd_pins $clk/clk_out1] [get_bd_pins $rf/s${t}_axis_aclk]
    ensure_bd_connection [get_bd_ports $adc_reset] [get_bd_pins $rf/m${t}_axis_aresetn]
}
ensure_bd_connection [get_bd_pins $clk/clk_out1] [get_bd_ports data_clk]
set_property CONFIG.FREQ_HZ $dac_clk_hz [get_bd_ports data_clk]
ensure_bd_connection [get_bd_pins $clk/clk_out1] [get_bd_pins rst_rf_clk/slowest_sync_clk]
foreach {prefix lanes} {
    m {00 02 10 12 20 22 30 32}
    s {00 02 10 12 20 22 30 32}
} {
    foreach lane $lanes {
        set name ${prefix}${lane}_axis
        set port [get_bd_intf_ports -quiet $name]
        if {[llength $port]} {delete_bd_objs $port}
        foreach signal {tdata tvalid tready} {
            set pin [get_bd_pins -quiet $rf/${name}_${signal}]
            if {![llength $pin]} {error "RFDC pin is missing: $rf/${name}_${signal}"}
            make_bd_pins_external -name ${name}_${signal} $pin
        }
    }
}
validate_bd_design
save_bd_design
set async_xdc [file join $root constraints timing_async.xdc]
if {![llength [get_files -quiet $async_xdc]]} {add_files -fileset constrs_1 $async_xdc}
set_property USED_IN_SYNTHESIS false [get_files $async_xdc]
set_property PROCESSING_ORDER LATE [get_files $async_xdc]
report_ip_status -file [file join $root logs ip_status.rpt]
set locked [get_ips -quiet -filter {IS_LOCKED == 1}]
if {[llength $locked]} {error "Locked IP requires review before build: $locked"}
generate_target all [get_files */system.bd]
generate_target all [get_ips {jtag_awg_axi ila_awg_scope}]
update_compile_order -fileset sources_1
if {$mode eq "create"} {
    puts "AWG project created: $xpr"
    close_project
    exit
}
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    reset_run synth_1
    launch_runs synth_1 -jobs $jobs
    wait_on_run synth_1
}
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Synthesis failed"}
open_run synth_1
report_utilization -file [file join $reports utilization_synth.rpt]
report_cdc -file [file join $reports cdc_synth.rpt]
if {$mode eq "bit"} {
    close_design
    if {$impl_strategy ne ""} {
        set_property STRATEGY $impl_strategy [get_runs impl_1]
    }
    if {[get_property STATUS [get_runs impl_1]] ne "write_bitstream Complete!"} {
        reset_run impl_1
        launch_runs impl_1 -to_step write_bitstream -jobs $jobs
        wait_on_run impl_1
    }
    if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Implementation failed"}
    open_run impl_1
    foreach clock {clk_pl_0 clk_out1_system_clk_wiz_0_0 pl_clk_p} {
        if {![llength [get_clocks -quiet $clock]]} {error "Missing required clock: $clock"}
    }
    report_timing_summary -file [file join $reports timing_summary.rpt]
    report_drc -file [file join $reports drc.rpt]
    report_cdc -file [file join $reports cdc_impl.rpt]
    report_utilization -hierarchical -file [file join $reports utilization_impl.rpt]
    if {[get_property SLACK [get_timing_paths -delay_type max -max_paths 1]] < 0 ||
        [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]] < 0} {
        error "Timing failed: do not use this bitstream"
    }
    file mkdir $release
    write_debug_probes -force [file join $release rf_awg_scope_v1.ltx]
    write_hw_platform -fixed -include_bit -force -file [file join $release rf_awg_scope_v1.xsa]
    file copy -force [file join $build rf_awg_scope_v1.runs impl_1 adaloop_top.bit] \
        [file join $release rf_awg_scope_v1.bit]
    puts "Bitstream, matching probes and XSA: $release"
}
close_project
