# OOC clock names are available after checkpoint linking. Read this file late
# and only during implementation, as configured in scripts/build.tcl.
set_clock_groups -asynchronous \
    -group [get_clocks {clk_pl_0}] \
    -group [get_clocks {clk_out1_system_clk_wiz_0_0 awg_ram_clk}] \
    -group [get_clocks {clk_out2_system_clk_wiz_0_0 adc_capture_ram_clk}] \
    -group [get_clocks pl_clk_p]
