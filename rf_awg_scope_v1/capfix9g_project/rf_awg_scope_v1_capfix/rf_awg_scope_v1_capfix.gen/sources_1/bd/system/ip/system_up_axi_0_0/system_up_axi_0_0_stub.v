// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Mon Nov  9 18:33:33 2026
// Host        : DESKTOP-R1144H2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/47dr_ADDA/stable9g/rf_awg_scope_v1_mts.gen/sources_1/bd/system/ip/system_up_axi_0_0/system_up_axi_0_0_stub.v
// Design      : system_up_axi_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu47dr-fsve1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "system_up_axi_0_0,up_axi,{}" *) (* CORE_GENERATION_INFO = "system_up_axi_0_0,up_axi,{x_ipProduct=Vivado 2025.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=up_axi,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,AXI_ADDRESS_WIDTH=16}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) 
(* IP_DEFINITION_SOURCE = "module_ref" *) (* X_CORE_INFO = "up_axi,Vivado 2025.2" *) 
module system_up_axi_0_0(up_rstn, up_clk, up_axi_awvalid, up_axi_awaddr, 
  up_axi_awready, up_axi_wvalid, up_axi_wdata, up_axi_wstrb, up_axi_wready, up_axi_bvalid, 
  up_axi_bresp, up_axi_bready, up_axi_arvalid, up_axi_araddr, up_axi_arready, up_axi_rvalid, 
  up_axi_rresp, up_axi_rdata, up_axi_rready, up_wreq, up_waddr, up_wdata, up_wack, up_rreq, 
  up_raddr, up_rdata, up_rack)
/* synthesis syn_black_box black_box_pad_pin="up_rstn,up_axi_awvalid,up_axi_awaddr[15:0],up_axi_awready,up_axi_wvalid,up_axi_wdata[31:0],up_axi_wstrb[3:0],up_axi_wready,up_axi_bvalid,up_axi_bresp[1:0],up_axi_bready,up_axi_arvalid,up_axi_araddr[15:0],up_axi_arready,up_axi_rvalid,up_axi_rresp[1:0],up_axi_rdata[31:0],up_axi_rready,up_wreq,up_waddr[15:0],up_wdata[31:0],up_wack,up_rreq,up_raddr[15:0],up_rdata[31:0],up_rack" */
/* synthesis syn_force_seq_prim="up_clk" */;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 up_rstn RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input up_rstn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 up_clk CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_clk, ASSOCIATED_RESET up_rstn, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, ASSOCIATED_BUSIF up_axi, INSERT_VIP 0" *) input up_clk /* synthesis syn_isclock = 1 */;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWVALID" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input up_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWADDR" *) input [15:0]up_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWREADY" *) output up_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WVALID" *) input up_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WDATA" *) input [31:0]up_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WSTRB" *) input [3:0]up_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WREADY" *) output up_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BVALID" *) output up_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BRESP" *) output [1:0]up_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BREADY" *) input up_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARVALID" *) input up_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARADDR" *) input [15:0]up_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARREADY" *) output up_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RVALID" *) output up_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RRESP" *) output [1:0]up_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RDATA" *) output [31:0]up_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RREADY" *) input up_axi_rready;
  output up_wreq;
  output [15:0]up_waddr;
  output [31:0]up_wdata;
  input up_wack;
  output up_rreq;
  output [15:0]up_raddr;
  input [31:0]up_rdata;
  input up_rack;
endmodule
