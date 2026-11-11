# Re-run implementation on a completed synthesis checkpoint with an explicit strategy.
# vivado -mode batch -source scripts/run_impl_strategy.tcl -tclargs <build_dir> <strategy>
set root [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv] != 2} {error "Usage: <build_dir> <strategy>"}
set build_name [lindex $argv 0]
set strategy [lindex $argv 1]
if {![regexp {^[A-Za-z0-9_-]+$} $build_name] || ![regexp {^[A-Za-z0-9_]+$} $strategy]} {
    error "Invalid build directory or strategy name"
}
set xpr [file join $root $build_name rf_awg_scope_v1.xpr]
if {![file exists $xpr]} {error "Project not found: $xpr"}
open_project $xpr
set synth [get_runs synth_1]
if {[get_property PROGRESS $synth] ne "100%"} {error "Synthesis is not complete"}
set run [get_runs impl_1]
set_property STRATEGY $strategy $run
reset_run $run
launch_runs $run -to_step write_bitstream -jobs 4
wait_on_run $run
if {[get_property PROGRESS $run] ne "100%"} {error "Implementation failed: [get_property STATUS $run]"}
open_run $run
set reports [file join $root $build_name reports]
file mkdir $reports
report_timing_summary -file [file join $reports timing_summary_${strategy}.rpt]
report_drc -file [file join $reports drc_${strategy}.rpt]
puts "Implementation strategy $strategy completed. Timing report: [file join $reports timing_summary_${strategy}.rpt]"
close_project
exit
