# Read-only signoff reports for a completed candidate checkpoint.
if {[llength $argv] != 2} {error "Usage: <routed-checkpoint> <report-directory>"}
lassign $argv checkpoint output
file mkdir $output
open_checkpoint $checkpoint
report_timing_summary -max_paths 5 -report_unconstrained -warn_on_violation -file [file join $output timing_audit.rpt]
report_bus_skew -file [file join $output bus_skew.rpt]
report_drc -file [file join $output drc.rpt]
report_clock_utilization -file [file join $output clock_utilization.rpt]
set setup [get_timing_paths -delay_type max -max_paths 1]
set hold [get_timing_paths -delay_type min -max_paths 1]
puts "CANDIDATE_TIMING WNS=[get_property SLACK $setup] WHS=[get_property SLACK $hold]"
close_design
