# Isolated RFDC parameter probe. Does not edit or program the AWG project.
# vivado -mode batch -source scripts/probe_dac10g_bypass.tcl
set root [file normalize [file join [file dirname [info script]] ..]]
set stamp [clock format [clock seconds] -format %Y%m%d_%H%M%S]
set probe_dir [file join $root build dac10g_bypass_probe_$stamp]
file mkdir $probe_dir
create_project dac10g_bypass_probe $probe_dir -part xczu47dr-fsve1156-2-i
add_files [file join $root rtl up_axi.v]
import_files -norecurse [file join $root reference system system.bd]
open_bd_design [get_files */system.bd]
set rf [get_bd_cells usp_rf_data_converter_0]
set modes [list]
for {set tile 0} {$tile < 4} {incr tile} {
    foreach block {0 2} {
        lappend modes CONFIG.DAC_Mode${tile}${block} 3
    }
}
set_property -dict $modes $rf
set cfg [list CONFIG.ADC_RTS false CONFIG.Calibration_Freeze false]
for {set tile 0} {$tile < 4} {incr tile} {
    lappend cfg CONFIG.ADC${tile}_Sampling_Rate 5.0 \
        CONFIG.ADC${tile}_PLL_Enable [expr {$tile == 1 ? "true" : "false"}] \
        CONFIG.ADC${tile}_Clock_Source 1 \
        CONFIG.ADC${tile}_Clock_Dist [expr {$tile == 1 ? 2 : 0}] \
        CONFIG.ADC${tile}_Refclk_Freq [format %.3f [expr {$tile == 1 ? 200.0 : 5000.0}]] \
        CONFIG.ADC${tile}_Outclk_Freq 156.250 \
        CONFIG.DAC${tile}_Sampling_Rate 10.0 \
        CONFIG.DAC${tile}_PLL_Enable [expr {$tile == 2 ? "true" : "false"}] \
        CONFIG.DAC${tile}_Clock_Source 6 \
        CONFIG.DAC${tile}_Clock_Dist [expr {$tile == 2 ? 2 : 0}] \
        CONFIG.DAC${tile}_Refclk_Freq [format %.3f [expr {$tile == 2 ? 200.0 : 10000.0}]] \
        CONFIG.DAC${tile}_Outclk_Freq 625.000
    foreach block {0 2} {
        lappend cfg CONFIG.DAC_Slice${tile}${block}_Enable true \
            CONFIG.DAC_Mode${tile}${block} 3 \
            CONFIG.DAC_Data_Type${tile}${block} 0 \
            CONFIG.DAC_Interpolation_Mode${tile}${block} 1 \
            CONFIG.DAC_Data_Width${tile}${block} 16 \
            CONFIG.ADC_Decimation_Mode${tile}${block} 8
    }
}
set fh [open [file join $probe_dir effective_parameters.txt] w]
set application_ok true
if {[catch {set_property -dict $cfg $rf} message]} {
    set application_ok false
    puts $fh "PARAMETER APPLICATION FAILED: $message"
    puts "PARAMETER APPLICATION FAILED: $message"
}
foreach property [lsort [list_property $rf]] {
    if {[regexp {^CONFIG\.(DAC[0-3]_|DAC_(Mode|Data_|Mixer_|Interpolation_|Slice)|ADC[0-3]_(Sampling|PLL|Clock|Refclk|Outclk|Fabric))} $property]} {
        set line "$property=[get_property $property $rf]"
        puts $fh $line
        puts $line
    }
}
foreach tile {0 1 2 3} {
    foreach block {0 2} {
        set pin [get_bd_pins -quiet ${rf}/s${tile}${block}_axis_tdata]
        if {[llength $pin]} {
            set line "s${tile}${block}_axis_tdata=[get_property LEFT $pin]:[get_property RIGHT $pin]"
            puts $fh $line
            puts $line
        }
    }
}
puts $fh "PARAMETER PROBE ONLY: no board wiring, clock tree, timing or hardware validation."
puts $fh "PARAMETER_APPLICATION_OK=$application_ok"
close $fh
puts "Probe result: [file join $probe_dir effective_parameters.txt]"
close_project
if {!$application_ok} {error "RFDC parameter application failed; inspect effective_parameters.txt"}
exit
