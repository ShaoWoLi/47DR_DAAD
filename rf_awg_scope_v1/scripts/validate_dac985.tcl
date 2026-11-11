set root [file normalize [file join [file dirname [info script]] ..]]
set xpr [file join $root build rf_awg_scope_v1.xpr]
open_project $xpr
set bd_file [get_files -quiet */system.bd]
if {![llength $bd_file]} {error "Block design system.bd is missing from the project"}
open_bd_design $bd_file
set rfdc [get_bd_cells -quiet -filter {VLNV =~ "xilinx.com:ip:usp_rf_data_converter:*"}]
if {[llength $rfdc] != 1} {error "Expected one RFDC cell, found: $rfdc"}
puts "RFDC cell: $rfdc"
set_property -dict [list \
    CONFIG.DAC0_Sampling_Rate 10.0 CONFIG.DAC1_Sampling_Rate 10.0 \
    CONFIG.DAC2_Sampling_Rate 10.0 CONFIG.DAC3_Sampling_Rate 10.0 \
    CONFIG.DAC_Mode00 3 CONFIG.DAC_Mode02 3 \
    CONFIG.DAC_Mode10 3 CONFIG.DAC_Mode12 3 \
    CONFIG.DAC_Mode20 3 CONFIG.DAC_Mode22 3 \
    CONFIG.DAC_Mode30 3 CONFIG.DAC_Mode32 3] $rfdc
puts "Testing 10.0 GS/s with RF-DAC mode 3; no project files are saved."
if {[catch {validate_bd_design} validation_message]} {
    puts "BD validation error: $validation_message"
} else {
    puts "BD validation completed."
}
foreach problem [get_drc_violations -quiet] {
    puts "DRC: [get_property SEVERITY $problem] [get_property MSG $problem]"
}
foreach property [list CONFIG.DAC0_Sampling_Rate CONFIG.DAC1_Sampling_Rate CONFIG.DAC2_Sampling_Rate CONFIG.DAC3_Sampling_Rate CONFIG.DAC_Mode00 CONFIG.DAC_Mode02 CONFIG.DAC_Interpolation_Mode00 CONFIG.DAC_Interpolation_Mode02] {
    if {[catch {set value [get_property $property $rfdc]} message]} {
        puts "$property unavailable: $message"
    } else {
        puts "$property=$value"
    }
}
puts "No configuration was changed or saved by this diagnostic."
close_project
exit
