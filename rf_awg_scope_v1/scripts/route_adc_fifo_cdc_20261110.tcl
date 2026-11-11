# Isolated alternate route from the same placed candidate, with FIFO CDC
# constraints present before routing rather than added after completion.
set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 8
open_checkpoint E:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.runs/impl_1/adaloop_top_physopt.dcp
source [file join $root constraints adc_capture_fifo_cdc.xdc]
set directive Explore
if {[llength $argv] == 1} {set directive [lindex $argv 0]}
if {$directive ni {Quick Explore}} {error "Expected Quick or Explore route directive"}
set tag [string tolower $directive]
route_design -directive $directive
write_checkpoint -force E:/47dr_ADDA/capfix9g/adc_cdc_${tag}_routed.dcp
report_timing_summary -max_paths 5 -report_unconstrained -file E:/47dr_ADDA/capfix9g/timing_cdc_${tag}_routed.rpt
report_bus_skew -file E:/47dr_ADDA/capfix9g/skew_cdc_${tag}_routed.rpt
close_design
exit
