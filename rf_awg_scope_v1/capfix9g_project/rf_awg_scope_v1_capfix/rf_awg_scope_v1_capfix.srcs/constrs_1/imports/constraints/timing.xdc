create_clock -period 5.000 -name pl_clk_p -waveform {0.000 2.500} [get_ports pl_clk_p]
# Cross-domain clock groups are in timing_async.xdc (implementation only).

# Debug/JTAG must remain clocked while software reconfigures the RF clock.
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets fclk_100m]
