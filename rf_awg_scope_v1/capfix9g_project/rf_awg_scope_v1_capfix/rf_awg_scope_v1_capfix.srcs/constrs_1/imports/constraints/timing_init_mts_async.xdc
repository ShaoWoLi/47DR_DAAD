# PS/JTAG, converter fabric clocks and board SYSREF capture use explicit CDC.
# DAC fabric uses its RFDC clock output; ADC fabric uses the board LMK PL
# reference so ADC PLL MTS scanning cannot stop its PL SYSREF counter.
# HDIO has no local MMCM. Keep the pin-to-BUFG dedicated connection and
# permit the BUFG output to use global clock routing to another CMT column.
# This retains dedicated clock routing (not CLOCK_DEDICATED_ROUTE FALSE).
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets pl_clk]
set_clock_groups -asynchronous \
    -group [get_clocks {clk_pl_0}] \
    -group [get_clocks {clk_out1_system_clk_wiz_0_0 awg_ram_clk}] \
    -group [get_clocks -quiet {clk_out2_system_clk_wiz_0_0 clk_out1_system_clk_wiz_adc_0 adc_capture_ram_clk}] \
    -group [get_clocks pl_clk_p]
