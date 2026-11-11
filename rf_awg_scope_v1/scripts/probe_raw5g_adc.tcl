# Isolated parameter check for one 5 GS/s raw-real ADC block.
# Usage: vivado -mode batch -source scripts/probe_raw5g_adc.tcl -tclargs tile block
# This creates a disposable project and does not edit the production BD.
set root [file normalize [file join [file dirname [info script]] ..]]
set stamp [clock format [clock seconds] -format %Y%m%d_%H%M%S]
set probe_dir [file join $root build raw5g_adc_probe_$stamp]
file mkdir $probe_dir
set tile [expr {[llength $argv] > 0 ? [lindex $argv 0] : 1}]
set block [expr {[llength $argv] > 1 ? [lindex $argv 1] : 0}]
set decimation [expr {[llength $argv] > 2 ? [lindex $argv 2] : 1}]
if {$tile ni {0 1 2 3} || $block ni {0 2} || $decimation ni {1 2 4 8}} {
    error "Select tile 0..3, ADC block 0 or 2, and decimation 1, 2, 4 or 8"
}
create_project raw5g_adc_probe $probe_dir -part xczu47dr-fsve1156-2-i
import_files -norecurse [file join $root reference system system.bd]
open_bd_design [get_files */system.bd]
set rf [get_bd_cells usp_rf_data_converter_0]
set cfg [list CONFIG.ADC_RTS false CONFIG.Calibration_Freeze false]
set peer [expr {$block == 0 ? 2 : 0}]
for {set t 0} {$t < 4} {incr t} {
    lappend cfg CONFIG.ADC${t}_Sampling_Rate 5.0 CONFIG.ADC${t}_Clock_Source 1
}
lappend cfg CONFIG.ADC1_PLL_Enable true CONFIG.ADC1_Clock_Dist 2 \
    CONFIG.ADC1_Refclk_Freq 200.000 \
    CONFIG.ADC_Slice${tile}${block}_Enable true \
    CONFIG.ADC_Slice${tile}${peer}_Enable true \
    CONFIG.ADC_Decimation_Mode${tile}${block} $decimation \
    CONFIG.ADC_Decimation_Mode${tile}${peer} $decimation \
    CONFIG.ADC_Mixer_Mode${tile}${block} 2 \
    CONFIG.ADC_Mixer_Mode${tile}${peer} 2 \
    CONFIG.ADC_Mixer_Type${tile}${block} 1 \
    CONFIG.ADC_Mixer_Type${tile}${peer} 1 \
    CONFIG.ADC_Data_Type${tile}${block} 0 \
    CONFIG.ADC_Data_Type${tile}${peer} 0 \
    CONFIG.ADC_Data_Width${tile}${block} 12 \
    CONFIG.ADC_Data_Width${tile}${peer} 12
set report [open [file join $probe_dir effective_parameters.txt] w]
puts $report "TARGET=tile${tile}_block${block}"
puts $report "DECIMATION=$decimation"
if {[catch {set_property -dict $cfg $rf} error_text]} {
    puts $report "PARAMETER APPLICATION FAILED: $error_text"
    close $report
    close_project
    error $error_text
}
if {[catch {validate_bd_design} error_text]} {
    puts $report "BD VALIDATION FAILED: $error_text"
    puts "BD VALIDATION FAILED: $error_text"
} else {
    puts $report "BD_VALIDATION=PASS"
}
foreach property [lsort [list_property $rf]] {
    if {[regexp {^CONFIG\.(ADC[0-3]_(Sampling|PLL|Clock|Refclk|Outclk|Fabric)|ADC_(Decimation_Mode|Mixer_Mode|Data_Type|Data_Width))} $property]} {
        puts $report "$property=[get_property $property $rf]"
    }
}
set fabric_hz [expr {1000000.0 * [get_property CONFIG.ADC${tile}_Fabric_Freq $rf]}]
set output_fs [expr {5000000000.0 / $decimation}]
puts $report "EXPECTED_OUTPUT_FS_HZ=$output_fs"
puts $report "ADC_FABRIC_CLOCK_HZ=$fabric_hz"
puts $report "RFDC_FABRIC_CLOCK_LIMIT=NOT_HARD_CODED; verify against generated IP constraints and implementation timing"
set pin [get_bd_pins -quiet ${rf}/m${tile}${block}_axis_tdata]
if {[llength $pin]} {
    puts $report "m${tile}${block}_axis_tdata=[get_property LEFT $pin]:[get_property RIGHT $pin]"
}
set pin [get_bd_pins -quiet ${rf}/m${tile}${block}_axis_aclk]
if {[llength $pin]} {
    puts $report "m${tile}${block}_axis_aclk=[get_property CONFIG.FREQ_HZ $pin]"
}
foreach tile_id {0 1 2 3} {
    if {$tile_id != $tile} {
        foreach adc_block {0 2} {
            set peer_pin [get_bd_pins -quiet ${rf}/m${tile_id}${adc_block}_axis_tdata]
            if {[llength $peer_pin]} {
                puts $report "m${tile_id}${adc_block}_axis_tdata=[get_property LEFT $peer_pin]:[get_property RIGHT $peer_pin]"
            }
        }
    }
}
puts $report "Probe only: no generated bitstream or board clock validation."
close $report
if {[catch {save_bd_design; generate_target all [get_files */system.bd]} error_text]} {
    set report [open [file join $probe_dir effective_parameters.txt] a]
    puts $report "IP_GENERATION=FAIL: $error_text"
    close $report
    puts "RFDC IP generation failed: $error_text"
} else {
    set report [open [file join $probe_dir effective_parameters.txt] a]
    puts $report "IP_GENERATION=PASS"
    close $report
}
puts "Probe result: [file join $probe_dir effective_parameters.txt]"
close_project
exit
