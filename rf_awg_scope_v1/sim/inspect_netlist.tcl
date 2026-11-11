open_checkpoint build/rf_awg_scope_v1.runs/impl_1/adaloop_top_opt.dcp
report_cdc -details -file logs/cdc_details.rpt
write_debug_probes -force logs/probes_check.ltx
puts "CLOCKS: [get_clocks]"
close_design
exit
