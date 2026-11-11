# Disposable RFDC legality/port-width probe. Does not edit or program the production design.
set root [file normalize [file join [file dirname [info script]] ..]]
set stamp [clock format [clock seconds] -format %Y%m%d_%H%M%S]
set probe_dir [file join $root build target_10g_5g_probe_$stamp]
file mkdir $probe_dir
create_project target_10g_5g_probe $probe_dir -part xczu47dr-fsve1156-2-i
add_files [list [file join $root rtl up_axi.v] [file join $root rtl reset_sync.v]]
import_files -norecurse [file join $root reference system system.bd]
open_bd_design [get_files */system.bd]
set rf [get_bd_cells usp_rf_data_converter_0]
set cfg [list CONFIG.ADC_RTS false CONFIG.Calibration_Freeze false]
for {set t 0} {$t < 4} {incr t} {
    lappend cfg CONFIG.ADC${t}_Sampling_Rate 5.0 \
        CONFIG.ADC${t}_PLL_Enable [expr {$t == 1 ? "true" : "false"}] \
        CONFIG.ADC${t}_Clock_Source 1 \
        CONFIG.ADC${t}_Clock_Dist [expr {$t == 1 ? 2 : 0}] \
        CONFIG.ADC${t}_Refclk_Freq [format %.3f [expr {$t == 1 ? 200.0 : 5000.0}]]
    lappend cfg CONFIG.DAC${t}_Sampling_Rate 10.0 \
        CONFIG.DAC${t}_PLL_Enable [expr {$t == 2 ? "true" : "false"}] \
        CONFIG.DAC${t}_Clock_Source 6 \
        CONFIG.DAC${t}_Clock_Dist [expr {$t == 2 ? 2 : 0}] \
        CONFIG.DAC${t}_Refclk_Freq [format %.3f [expr {$t == 2 ? 200.0 : 10000.0}]]
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
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 625.000 \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ 416.667 \
    CONFIG.CLKOUT2_USED true] $clk
set adc_clk_pin [get_bd_pins -quiet $clk/clk_out2]
if {[llength $adc_clk_pin] != 1} {error "Clock Wizard clk_out2 was not generated"}
set adc_clk_hz [get_property CONFIG.FREQ_HZ $adc_clk_pin]
set dac_clk_pin [get_bd_pins $clk/clk_out1]
set dac_clk_hz [get_property CONFIG.FREQ_HZ $dac_clk_pin]
delete_bd_objs [get_bd_nets -of_objects [get_bd_pins $clk/clk_in1]]
connect_bd_net [get_bd_ports fclk_100m] [get_bd_pins $clk/clk_in1]
set adc_clock [create_bd_port -dir O -type clk adc_capture_clk]
set_property CONFIG.FREQ_HZ $adc_clk_hz $adc_clock
connect_bd_net [get_bd_pins $clk/clk_out2] $adc_clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_adc_clk
connect_bd_net [get_bd_pins $clk/clk_out2] [get_bd_pins rst_adc_clk/slowest_sync_clk]
connect_bd_net [get_bd_ports pl_resetn0] [get_bd_pins rst_adc_clk/ext_reset_in]
connect_bd_net [get_bd_pins $clk/locked] [get_bd_pins rst_adc_clk/dcm_locked]
set adc_reset [create_bd_port -dir O -type rst adc_axis_resetn]
set_property CONFIG.POLARITY ACTIVE_LOW $adc_reset
connect_bd_net [get_bd_pins rst_adc_clk/peripheral_aresetn] $adc_reset
foreach tile {0 1 2 3} {
    delete_bd_objs [get_bd_nets -of_objects [get_bd_pins $rf/m${tile}_axis_aclk]]
    connect_bd_net [get_bd_pins $clk/clk_out2] [get_bd_pins $rf/m${tile}_axis_aclk]
    delete_bd_objs [get_bd_nets -of_objects [get_bd_pins $rf/s${tile}_axis_aclk]]
    connect_bd_net [get_bd_pins $clk/clk_out1] [get_bd_pins $rf/s${tile}_axis_aclk]
}
connect_bd_net [get_bd_pins $clk/clk_out1] [get_bd_ports data_clk]
set_property CONFIG.FREQ_HZ $dac_clk_hz [get_bd_ports data_clk]
connect_bd_net [get_bd_pins $clk/clk_out1] [get_bd_pins rst_rf_clk/slowest_sync_clk]
foreach tile {0 1 2 3} {
    delete_bd_objs [get_bd_nets -of_objects [get_bd_pins $rf/m${tile}_axis_aresetn]]
    connect_bd_net $adc_reset [get_bd_pins $rf/m${tile}_axis_aresetn]
}
foreach tile {0 1 2 3} {
    foreach block {0 1 2 3} {
        set bus [get_bd_intf_ports -quiet m${tile}${block}_axis]
        if {[llength $bus]} {delete_bd_objs $bus}
    }
    foreach block {0 2} {
        set bus [get_bd_intf_ports -quiet s${tile}${block}_axis]
        if {[llength $bus]} {delete_bd_objs $bus}
    }
}
foreach tile {0 1 2 3} {
    foreach block {0 2} {
        foreach name [list m${tile}${block}_axis s${tile}${block}_axis] {
            set pin [get_bd_intf_pins -quiet ${rf}/$name]
            if {[llength $pin]} {make_bd_intf_pins_external -name $name $pin}
        }
    }
}
set fh [open [file join $probe_dir probe_report.txt] w]
if {[catch {set_property -dict $cfg $rf; validate_bd_design} err]} {
    puts $fh "VALIDATION=FAIL: $err"
    close $fh
    close_project
    error $err
}
puts $fh "VALIDATION=PASS"
foreach property {CONFIG.ADC0_Fabric_Freq CONFIG.ADC1_Fabric_Freq CONFIG.ADC2_Fabric_Freq CONFIG.ADC3_Fabric_Freq CONFIG.DAC2_Outclk_Freq} {
    puts $fh "$property=[get_property $property $rf]"
}
foreach t {0 1 2 3} {
    foreach b {0 2} {
        foreach pin [list m${t}${b}_axis_tdata s${t}${b}_axis_tdata] {
            set p [get_bd_pins -quiet ${rf}/$pin]
            if {[llength $p]} {puts $fh "$pin=[get_property LEFT $p]:[get_property RIGHT $p]"} else {puts $fh "$pin=MISSING"}
        }
    }
}
foreach pin {clk_adc1 clk_dac2 m0_axis_aclk m1_axis_aclk m2_axis_aclk m3_axis_aclk s0_axis_aclk s1_axis_aclk s2_axis_aclk s3_axis_aclk} {
    set p [get_bd_pins -quiet ${rf}/$pin]
    if {[llength $p]} {puts $fh "$pin direction=[get_property DIR $p] freq=[get_property CONFIG.FREQ_HZ $p]"}
}
puts $fh "clk_wiz_clk_out1_freq=$dac_clk_hz"
puts $fh "clk_wiz_clk_out2_freq=$adc_clk_hz"
close $fh
save_bd_design
generate_target all [get_files */system.bd]
puts "Probe result: [file join $probe_dir probe_report.txt]"
close_project
exit
