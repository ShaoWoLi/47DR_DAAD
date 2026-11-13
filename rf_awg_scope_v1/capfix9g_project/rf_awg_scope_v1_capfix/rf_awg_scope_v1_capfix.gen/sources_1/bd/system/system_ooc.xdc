################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name adc_fabric_ref -period 5 [get_ports adc_fabric_ref]
create_clock -name adc1_clk_clk_p -period 10 [get_ports adc1_clk_clk_p]
create_clock -name dac2_clk_clk_p -period 10 [get_ports dac2_clk_clk_p]

################################################################################