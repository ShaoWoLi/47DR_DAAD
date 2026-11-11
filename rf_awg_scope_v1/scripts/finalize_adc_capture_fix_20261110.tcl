# Reuse the completed candidate implementation, adding the reviewed FIFO
# constraints without changing any logic or discarding completed routing.
set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 8
set candidate E:/47dr_ADDA/capfix9g
open_project [file join $candidate rf_awg_scope_v1_capfix.xpr]
if {[llength $argv] == 1} {
    open_checkpoint [file normalize [lindex $argv 0]]
} elseif {[llength $argv] == 0} {
    open_run impl_1
} else {error "Expected optional routed checkpoint"}
set cdc [file join $root constraints adc_capture_fifo_cdc.xdc]
if {![llength [get_cells -quiet adc_capture_i]]} {error "ADC capture instance missing"}
source $cdc
set out [file join $candidate artifacts]
file mkdir $out
report_timing_summary -max_paths 5 -report_unconstrained -file [file join $out timing_before_cdc_physopt.rpt]
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
puts "CAPFIX_CDC_ROUTED setup=$setup hold=$hold"
if {$setup < 0 || $hold < 0} {
    phys_opt_design -directive AggressiveExplore
}
if {[get_property SLACK [get_timing_paths -delay_type min -max_paths 1]] < 0} {
    phys_opt_design -hold_fix -aggressive_hold_fix
}
report_timing_summary -max_paths 5 -report_unconstrained -file [file join $out timing_summary.rpt]
report_bus_skew -file [file join $out bus_skew.rpt]
report_drc -file [file join $out drc.rpt]
report_clock_utilization -file [file join $out clock_utilization.rpt]
report_exceptions -coverage -file [file join $out exceptions.rpt]
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
if {$setup < 0 || $hold < 0} {error "Correctly constrained candidate still fails setup/hold; do not publish"}
write_checkpoint -force [file join $candidate adc_capture_fixed_routed.dcp]
set bit_out [file join $out rf_awg_scope_v1.bit]
set ltx_out [file join $out rf_awg_scope_v1.ltx]
write_bitstream -force $bit_out
write_debug_probes -force $ltx_out
write_hw_platform -fixed -include_bit -force -file [file join $out rf_awg_scope_v1.xsa]
# Retain the constraint in the project for reproducible future rebuilds.
if {![llength [get_files -quiet $cdc]]} {add_files -fileset constrs_1 -norecurse $cdc}
set_property USED_IN_SYNTHESIS false [get_files $cdc]
puts "ADC_READBACK_FIX_ARTIFACTS $out"
close_project
exit
