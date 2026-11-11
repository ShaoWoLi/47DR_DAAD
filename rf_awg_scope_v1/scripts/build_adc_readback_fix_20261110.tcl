# Isolate the two small RTL fixes from the timing-passing published baseline.
set root [file normalize [file join [file dirname [info script]] ..]]
set baseline E:/47dr_ADDA/stable9g
set candidate E:/47dr_ADDA/capfix9g
if {[file exists [file join $candidate rf_awg_scope_v1_capfix.xpr]]} {
    open_project [file join $candidate rf_awg_scope_v1_capfix.xpr]
} else {
    open_project [file join $baseline rf_awg_scope_v1_mts.xpr]
    save_project_as -force -dir $candidate rf_awg_scope_v1_capfix
}
foreach name {adc_capture.sv awg_control.sv} {
    set old [get_files -quiet */$name]
    if {[llength $old]!=1} {error "Expected exactly one $name"}
    remove_files $old
    add_files -norecurse [file join $root rtl candidates dac9g_capture_fix $name]
}
update_compile_order -fileset sources_1
set cdc [file join $root constraints adc_capture_fifo_cdc.xdc]
if {![llength [get_files -quiet $cdc]]} {add_files -fileset constrs_1 -norecurse $cdc}
set_property USED_IN_SYNTHESIS false [get_files $cdc]
set reference [file join $baseline rf_awg_scope_v1_mts.runs impl_1 adaloop_top_postroute_physopt.dcp]
set_property INCREMENTAL_CHECKPOINT $reference [get_runs impl_1]
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
if {![string match {*Complete!*} [get_property STATUS [get_runs synth_1]]]} {error "Synthesis failed"}
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
if {![string match {*Complete!*} [get_property STATUS [get_runs impl_1]]]} {error "Implementation failed"}
open_run impl_1
set out [file join $candidate artifacts]
file mkdir $out
report_timing_summary -max_paths 5 -report_unconstrained -file [file join $out timing_summary.rpt]
report_drc -file [file join $out drc.rpt]
report_bus_skew -file [file join $out bus_skew.rpt]
report_clock_utilization -file [file join $out clock_utilization.rpt]
set setup [get_timing_paths -delay_type max -max_paths 1]
set hold [get_timing_paths -delay_type min -max_paths 1]
if {[get_property SLACK $setup]<0 || [get_property SLACK $hold]<0} {error "Candidate has a setup/hold violation; do not publish"}
write_hw_platform -fixed -include_bit -force -file [file join $out rf_awg_scope_v1.xsa]
set run [get_property DIRECTORY [get_runs impl_1]]
foreach ext {bit ltx} {file copy -force [file join $run adaloop_top.$ext] [file join $out rf_awg_scope_v1.$ext]}
puts "ADC_READBACK_FIX_ARTIFACTS $out"
close_project
exit
