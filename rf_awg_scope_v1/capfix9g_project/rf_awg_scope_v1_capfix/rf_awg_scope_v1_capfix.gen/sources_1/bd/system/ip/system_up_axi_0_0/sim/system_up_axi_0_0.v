// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:up_axi:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module system_up_axi_0_0 (
  up_rstn,
  up_clk,
  up_axi_awvalid,
  up_axi_awaddr,
  up_axi_awready,
  up_axi_wvalid,
  up_axi_wdata,
  up_axi_wstrb,
  up_axi_wready,
  up_axi_bvalid,
  up_axi_bresp,
  up_axi_bready,
  up_axi_arvalid,
  up_axi_araddr,
  up_axi_arready,
  up_axi_rvalid,
  up_axi_rresp,
  up_axi_rdata,
  up_axi_rready,
  up_wreq,
  up_waddr,
  up_wdata,
  up_wack,
  up_rreq,
  up_raddr,
  up_rdata,
  up_rack
);

(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 up_rstn RST" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
input wire up_rstn;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 up_clk CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_clk, ASSOCIATED_RESET up_rstn, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, ASSOCIATED_BUSIF up_axi, INSERT_VIP 0" *)
input wire up_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWVALID" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_\
WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
input wire up_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWADDR" *)
input wire [15 : 0] up_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi AWREADY" *)
output wire up_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WVALID" *)
input wire up_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WDATA" *)
input wire [31 : 0] up_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WSTRB" *)
input wire [3 : 0] up_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi WREADY" *)
output wire up_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BVALID" *)
output wire up_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BRESP" *)
output wire [1 : 0] up_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi BREADY" *)
input wire up_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARVALID" *)
input wire up_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARADDR" *)
input wire [15 : 0] up_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi ARREADY" *)
output wire up_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RVALID" *)
output wire up_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RRESP" *)
output wire [1 : 0] up_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RDATA" *)
output wire [31 : 0] up_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 up_axi RREADY" *)
input wire up_axi_rready;
output wire up_wreq;
output wire [15 : 0] up_waddr;
output wire [31 : 0] up_wdata;
input wire up_wack;
output wire up_rreq;
output wire [15 : 0] up_raddr;
input wire [31 : 0] up_rdata;
input wire up_rack;

  up_axi #(
    .AXI_ADDRESS_WIDTH(16)
  ) inst (
    .up_rstn(up_rstn),
    .up_clk(up_clk),
    .up_axi_awvalid(up_axi_awvalid),
    .up_axi_awaddr(up_axi_awaddr),
    .up_axi_awready(up_axi_awready),
    .up_axi_wvalid(up_axi_wvalid),
    .up_axi_wdata(up_axi_wdata),
    .up_axi_wstrb(up_axi_wstrb),
    .up_axi_wready(up_axi_wready),
    .up_axi_bvalid(up_axi_bvalid),
    .up_axi_bresp(up_axi_bresp),
    .up_axi_bready(up_axi_bready),
    .up_axi_arvalid(up_axi_arvalid),
    .up_axi_araddr(up_axi_araddr),
    .up_axi_arready(up_axi_arready),
    .up_axi_rvalid(up_axi_rvalid),
    .up_axi_rresp(up_axi_rresp),
    .up_axi_rdata(up_axi_rdata),
    .up_axi_rready(up_axi_rready),
    .up_wreq(up_wreq),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack),
    .up_rreq(up_rreq),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata),
    .up_rack(up_rack)
  );
endmodule
