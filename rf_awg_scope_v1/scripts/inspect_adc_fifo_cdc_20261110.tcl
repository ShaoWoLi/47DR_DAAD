set root [file normalize [file join [file dirname [info script]] ..]]
open_checkpoint E:/47dr_ADDA/capfix9g/rf_awg_scope_v1_capfix.runs/impl_1/adaloop_top_physopt.dcp
source [file join $root constraints adc_capture_fifo_cdc.xdc]
report_timing_summary -max_paths 5 -file E:/47dr_ADDA/capfix9g/timing_fifo_cdc_check.rpt
report_bus_skew -file E:/47dr_ADDA/capfix9g/skew_fifo_cdc_check.rpt
report_exceptions -coverage -file E:/47dr_ADDA/capfix9g/exceptions_fifo_cdc_check.rpt
close_design
exit
