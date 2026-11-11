set_property   -dict {PACKAGE_PIN E12  IOSTANDARD LVPECL } [get_ports pl_clk_p]
#set_property   -dict {PACKAGE_PIN D12  IOSTANDARD LVPECL } [get_ports pl_clk_n]
set_property   -dict {PACKAGE_PIN E14  IOSTANDARD LVPECL } [get_ports pl_sysref_p]
#set_property   -dict {PACKAGE_PIN D14  IOSTANDARD LVPECL } [get_ports pl_sysref_n]

set_property   -dict {PACKAGE_PIN B12   IOSTANDARD LVCMOS18 }  [get_ports led[0]]
set_property   -dict {PACKAGE_PIN A12   IOSTANDARD LVCMOS18 }  [get_ports led[1]]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
