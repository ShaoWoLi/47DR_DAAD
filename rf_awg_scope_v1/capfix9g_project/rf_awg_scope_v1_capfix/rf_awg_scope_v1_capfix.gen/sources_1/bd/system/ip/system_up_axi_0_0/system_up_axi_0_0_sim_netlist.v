// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Mon Nov  9 18:33:33 2026
// Host        : DESKTOP-R1144H2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/47dr_ADDA/stable9g/rf_awg_scope_v1_mts.gen/sources_1/bd/system/ip/system_up_axi_0_0/system_up_axi_0_0_sim_netlist.v
// Design      : system_up_axi_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu47dr-fsve1156-2-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_up_axi_0_0,up_axi,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "up_axi,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module system_up_axi_0_0
   (up_rstn,
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
    up_rack);
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 up_rstn RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input up_rstn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 up_clk CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME up_clk, ASSOCIATED_RESET up_rstn, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, ASSOCIATED_BUSIF up_axi, INSERT_VIP 0" *) input up_clk;
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

  wire \<const0> ;
  wire [15:0]up_axi_araddr;
  wire up_axi_arready;
  wire up_axi_arvalid;
  wire [15:0]up_axi_awaddr;
  wire up_axi_awready;
  wire up_axi_awvalid;
  wire up_axi_bready;
  wire up_axi_bvalid;
  wire [31:0]up_axi_rdata;
  wire up_axi_rready;
  wire up_axi_rvalid;
  wire [31:0]up_axi_wdata;
  wire up_axi_wready;
  wire up_axi_wvalid;
  wire up_clk;
  wire up_rack;
  wire [15:0]up_raddr;
  wire [31:0]up_rdata;
  wire up_rreq;
  wire up_rstn;
  wire up_wack;
  wire [15:0]up_waddr;
  wire [31:0]up_wdata;
  wire up_wreq;

  assign up_axi_bresp[1] = \<const0> ;
  assign up_axi_bresp[0] = \<const0> ;
  assign up_axi_rresp[1] = \<const0> ;
  assign up_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  system_up_axi_0_0_up_axi inst
       (.up_axi_araddr(up_axi_araddr),
        .up_axi_arready(up_axi_arready),
        .up_axi_arvalid(up_axi_arvalid),
        .up_axi_awaddr(up_axi_awaddr),
        .up_axi_awready(up_axi_awready),
        .up_axi_awvalid(up_axi_awvalid),
        .up_axi_bready(up_axi_bready),
        .up_axi_bvalid(up_axi_bvalid),
        .up_axi_rdata(up_axi_rdata),
        .up_axi_rready(up_axi_rready),
        .up_axi_rvalid_int_reg_0(up_axi_rvalid),
        .up_axi_wdata(up_axi_wdata),
        .up_axi_wready(up_axi_wready),
        .up_axi_wvalid(up_axi_wvalid),
        .up_clk(up_clk),
        .up_rack(up_rack),
        .up_raddr(up_raddr),
        .up_rdata(up_rdata),
        .up_rreq(up_rreq),
        .up_rstn(up_rstn),
        .up_wack(up_wack),
        .up_waddr(up_waddr),
        .up_wdata(up_wdata),
        .up_wreq(up_wreq));
endmodule

(* ORIG_REF_NAME = "up_axi" *) 
module system_up_axi_0_0_up_axi
   (up_axi_rvalid_int_reg_0,
    up_axi_rdata,
    up_waddr,
    up_wdata,
    up_raddr,
    up_wreq,
    up_axi_bvalid,
    up_rreq,
    up_axi_awready,
    up_axi_wready,
    up_axi_arready,
    up_wack,
    up_axi_wvalid,
    up_axi_awvalid,
    up_rstn,
    up_axi_arvalid,
    up_rdata,
    up_axi_rready,
    up_clk,
    up_axi_awaddr,
    up_axi_wdata,
    up_axi_araddr,
    up_rack,
    up_axi_bready);
  output up_axi_rvalid_int_reg_0;
  output [31:0]up_axi_rdata;
  output [15:0]up_waddr;
  output [31:0]up_wdata;
  output [15:0]up_raddr;
  output up_wreq;
  output up_axi_bvalid;
  output up_rreq;
  output up_axi_awready;
  output up_axi_wready;
  output up_axi_arready;
  input up_wack;
  input up_axi_wvalid;
  input up_axi_awvalid;
  input up_rstn;
  input up_axi_arvalid;
  input [31:0]up_rdata;
  input up_axi_rready;
  input up_clk;
  input [15:0]up_axi_awaddr;
  input [31:0]up_axi_wdata;
  input [15:0]up_axi_araddr;
  input up_rack;
  input up_axi_bready;

  wire p_0_in;
  wire p_0_in6_in;
  wire p_0_in7_in;
  wire p_1_in;
  wire p_1_in_0;
  wire [4:1]p_2_in;
  wire p_5_in;
  wire [15:0]up_axi_araddr;
  wire up_axi_arready;
  wire up_axi_arready_int_i_1_n_0;
  wire up_axi_arready_int_i_2_n_0;
  wire up_axi_arvalid;
  wire [15:0]up_axi_awaddr;
  wire up_axi_awready;
  wire up_axi_awready_int_i_2_n_0;
  wire up_axi_awvalid;
  wire up_axi_bready;
  wire up_axi_bvalid;
  wire up_axi_bvalid_int_i_1_n_0;
  wire [31:0]up_axi_rdata;
  wire \up_axi_rdata_int[31]_i_1_n_0 ;
  wire up_axi_rready;
  wire up_axi_rvalid_int_i_1_n_0;
  wire up_axi_rvalid_int_reg_0;
  wire [31:0]up_axi_wdata;
  wire up_axi_wready;
  wire up_axi_wready_int_i_1_n_0;
  wire up_axi_wvalid;
  wire up_clk;
  wire up_rack;
  wire up_rack_d;
  wire up_rack_s;
  wire [15:0]up_raddr;
  wire \up_rcount[0]_i_1_n_0 ;
  wire \up_rcount[1]_i_1_n_0 ;
  wire \up_rcount[2]_i_1_n_0 ;
  wire \up_rcount[3]_i_1_n_0 ;
  wire \up_rcount[4]_i_1_n_0 ;
  wire \up_rcount[4]_i_2_n_0 ;
  wire \up_rcount_reg_n_0_[0] ;
  wire \up_rcount_reg_n_0_[1] ;
  wire \up_rcount_reg_n_0_[2] ;
  wire \up_rcount_reg_n_0_[3] ;
  wire [31:0]up_rdata;
  wire [31:0]up_rdata_d;
  wire \up_rdata_d[0]_i_1_n_0 ;
  wire \up_rdata_d[10]_i_1_n_0 ;
  wire \up_rdata_d[11]_i_1_n_0 ;
  wire \up_rdata_d[12]_i_1_n_0 ;
  wire \up_rdata_d[14]_i_1_n_0 ;
  wire \up_rdata_d[15]_i_1_n_0 ;
  wire \up_rdata_d[16]_i_1_n_0 ;
  wire \up_rdata_d[18]_i_1_n_0 ;
  wire \up_rdata_d[19]_i_1_n_0 ;
  wire \up_rdata_d[21]_i_1_n_0 ;
  wire \up_rdata_d[23]_i_1_n_0 ;
  wire \up_rdata_d[25]_i_1_n_0 ;
  wire \up_rdata_d[26]_i_1_n_0 ;
  wire \up_rdata_d[27]_i_1_n_0 ;
  wire \up_rdata_d[28]_i_1_n_0 ;
  wire \up_rdata_d[29]_i_1_n_0 ;
  wire \up_rdata_d[2]_i_1_n_0 ;
  wire \up_rdata_d[30]_i_1_n_0 ;
  wire \up_rdata_d[31]_i_1_n_0 ;
  wire \up_rdata_d[3]_i_1_n_0 ;
  wire \up_rdata_d[5]_i_1_n_0 ;
  wire \up_rdata_d[7]_i_1_n_0 ;
  wire \up_rdata_d[9]_i_1_n_0 ;
  wire up_rreq;
  wire up_rreq_int_i_1_n_0;
  wire up_rsel_inv_i_1_n_0;
  wire up_rstn;
  wire up_wack;
  wire up_wack_d;
  wire up_wack_s;
  wire [15:0]up_waddr;
  wire \up_wcount[0]_i_1_n_0 ;
  wire \up_wcount[2]_i_1_n_0 ;
  wire \up_wcount_reg_n_0_[0] ;
  wire \up_wcount_reg_n_0_[1] ;
  wire \up_wcount_reg_n_0_[2] ;
  wire \up_wcount_reg_n_0_[3] ;
  wire [31:0]up_wdata;
  wire up_wreq;
  wire up_wreq_int_i_1_n_0;
  wire up_wsel_inv_i_1_n_0;

  LUT4 #(
    .INIT(16'h5540)) 
    up_axi_arready_int_i_1
       (.I0(up_axi_arready),
        .I1(up_rack),
        .I2(p_0_in6_in),
        .I3(up_axi_arready_int_i_2_n_0),
        .O(up_axi_arready_int_i_1_n_0));
  LUT5 #(
    .INIT(32'h80000000)) 
    up_axi_arready_int_i_2
       (.I0(\up_rcount_reg_n_0_[0] ),
        .I1(\up_rcount_reg_n_0_[1] ),
        .I2(\up_rcount_reg_n_0_[2] ),
        .I3(\up_rcount_reg_n_0_[3] ),
        .I4(p_0_in6_in),
        .O(up_axi_arready_int_i_2_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_axi_arready_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_axi_arready_int_i_1_n_0),
        .Q(up_axi_arready),
        .R(p_0_in));
  LUT1 #(
    .INIT(2'h1)) 
    up_axi_awready_int_i_1
       (.I0(up_rstn),
        .O(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h4)) 
    up_axi_awready_int_i_2
       (.I0(up_axi_awready),
        .I1(up_wack_s),
        .O(up_axi_awready_int_i_2_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_axi_awready_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_axi_awready_int_i_2_n_0),
        .Q(up_axi_awready),
        .R(p_0_in));
  LUT4 #(
    .INIT(16'h0C88)) 
    up_axi_bvalid_int_i_1
       (.I0(up_wack_d),
        .I1(up_rstn),
        .I2(up_axi_bready),
        .I3(up_axi_bvalid),
        .O(up_axi_bvalid_int_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_axi_bvalid_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_axi_bvalid_int_i_1_n_0),
        .Q(up_axi_bvalid),
        .R(1'b0));
  LUT3 #(
    .INIT(8'h8F)) 
    \up_axi_rdata_int[31]_i_1 
       (.I0(up_axi_rready),
        .I1(up_axi_rvalid_int_reg_0),
        .I2(up_rstn),
        .O(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[0] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[0]),
        .Q(up_axi_rdata[0]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[10] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[10]),
        .Q(up_axi_rdata[10]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[11] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[11]),
        .Q(up_axi_rdata[11]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[12] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[12]),
        .Q(up_axi_rdata[12]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[13] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[13]),
        .Q(up_axi_rdata[13]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[14] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[14]),
        .Q(up_axi_rdata[14]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[15] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[15]),
        .Q(up_axi_rdata[15]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[16] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[16]),
        .Q(up_axi_rdata[16]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[17] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[17]),
        .Q(up_axi_rdata[17]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[18] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[18]),
        .Q(up_axi_rdata[18]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[19] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[19]),
        .Q(up_axi_rdata[19]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[1] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[1]),
        .Q(up_axi_rdata[1]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[20] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[20]),
        .Q(up_axi_rdata[20]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[21] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[21]),
        .Q(up_axi_rdata[21]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[22] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[22]),
        .Q(up_axi_rdata[22]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[23] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[23]),
        .Q(up_axi_rdata[23]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[24] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[24]),
        .Q(up_axi_rdata[24]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[25] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[25]),
        .Q(up_axi_rdata[25]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[26] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[26]),
        .Q(up_axi_rdata[26]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[27] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[27]),
        .Q(up_axi_rdata[27]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[28] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[28]),
        .Q(up_axi_rdata[28]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[29] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[29]),
        .Q(up_axi_rdata[29]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[2] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[2]),
        .Q(up_axi_rdata[2]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[30] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[30]),
        .Q(up_axi_rdata[30]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[31] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[31]),
        .Q(up_axi_rdata[31]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[3] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[3]),
        .Q(up_axi_rdata[3]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[4] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[4]),
        .Q(up_axi_rdata[4]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[5] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[5]),
        .Q(up_axi_rdata[5]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[6] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[6]),
        .Q(up_axi_rdata[6]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[7] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[7]),
        .Q(up_axi_rdata[7]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[8] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[8]),
        .Q(up_axi_rdata[8]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_axi_rdata_int_reg[9] 
       (.C(up_clk),
        .CE(up_rack_d),
        .D(up_rdata_d[9]),
        .Q(up_axi_rdata[9]),
        .R(\up_axi_rdata_int[31]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h08C8)) 
    up_axi_rvalid_int_i_1
       (.I0(up_rack_d),
        .I1(up_rstn),
        .I2(up_axi_rvalid_int_reg_0),
        .I3(up_axi_rready),
        .O(up_axi_rvalid_int_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_axi_rvalid_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_axi_rvalid_int_i_1_n_0),
        .Q(up_axi_rvalid_int_reg_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h4)) 
    up_axi_wready_int_i_1
       (.I0(up_axi_wready),
        .I1(up_wack_s),
        .O(up_axi_wready_int_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_axi_wready_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_axi_wready_int_i_1_n_0),
        .Q(up_axi_wready),
        .R(p_0_in));
  LUT6 #(
    .INIT(64'hC888888888888888)) 
    up_rack_d_i_1
       (.I0(up_rack),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[0] ),
        .I3(\up_rcount_reg_n_0_[1] ),
        .I4(\up_rcount_reg_n_0_[2] ),
        .I5(\up_rcount_reg_n_0_[3] ),
        .O(up_rack_s));
  FDRE #(
    .INIT(1'b0)) 
    up_rack_d_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rack_s),
        .Q(up_rack_d),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[0] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[0]),
        .Q(up_raddr[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[10] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[10]),
        .Q(up_raddr[10]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[11] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[11]),
        .Q(up_raddr[11]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[12] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[12]),
        .Q(up_raddr[12]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[13] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[13]),
        .Q(up_raddr[13]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[14] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[14]),
        .Q(up_raddr[14]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[15] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[15]),
        .Q(up_raddr[15]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[1] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[1]),
        .Q(up_raddr[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[2] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[2]),
        .Q(up_raddr[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[3] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[3]),
        .Q(up_raddr[3]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[4] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[4]),
        .Q(up_raddr[4]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[5] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[5]),
        .Q(up_raddr[5]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[6] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[6]),
        .Q(up_raddr[6]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[7] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[7]),
        .Q(up_raddr[7]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[8] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[8]),
        .Q(up_raddr[8]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_raddr_int_reg[9] 
       (.C(up_clk),
        .CE(p_1_in_0),
        .D(up_axi_araddr[9]),
        .Q(up_raddr[9]),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'h04)) 
    \up_rcount[0]_i_1 
       (.I0(up_rack),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[0] ),
        .O(\up_rcount[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h1400)) 
    \up_rcount[1]_i_1 
       (.I0(up_rack),
        .I1(\up_rcount_reg_n_0_[0] ),
        .I2(\up_rcount_reg_n_0_[1] ),
        .I3(p_0_in6_in),
        .O(\up_rcount[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h14440000)) 
    \up_rcount[2]_i_1 
       (.I0(up_rack),
        .I1(\up_rcount_reg_n_0_[2] ),
        .I2(\up_rcount_reg_n_0_[1] ),
        .I3(\up_rcount_reg_n_0_[0] ),
        .I4(p_0_in6_in),
        .O(\up_rcount[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1444444400000000)) 
    \up_rcount[3]_i_1 
       (.I0(up_rack),
        .I1(\up_rcount_reg_n_0_[3] ),
        .I2(\up_rcount_reg_n_0_[0] ),
        .I3(\up_rcount_reg_n_0_[1] ),
        .I4(\up_rcount_reg_n_0_[2] ),
        .I5(p_0_in6_in),
        .O(\up_rcount[3]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \up_rcount[4]_i_1 
       (.I0(p_0_in6_in),
        .I1(up_rreq),
        .O(\up_rcount[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000FFFF7FFFFFFF)) 
    \up_rcount[4]_i_2 
       (.I0(\up_rcount_reg_n_0_[3] ),
        .I1(\up_rcount_reg_n_0_[2] ),
        .I2(\up_rcount_reg_n_0_[1] ),
        .I3(\up_rcount_reg_n_0_[0] ),
        .I4(p_0_in6_in),
        .I5(up_rack),
        .O(\up_rcount[4]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rcount_reg[0] 
       (.C(up_clk),
        .CE(\up_rcount[4]_i_1_n_0 ),
        .D(\up_rcount[0]_i_1_n_0 ),
        .Q(\up_rcount_reg_n_0_[0] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rcount_reg[1] 
       (.C(up_clk),
        .CE(\up_rcount[4]_i_1_n_0 ),
        .D(\up_rcount[1]_i_1_n_0 ),
        .Q(\up_rcount_reg_n_0_[1] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rcount_reg[2] 
       (.C(up_clk),
        .CE(\up_rcount[4]_i_1_n_0 ),
        .D(\up_rcount[2]_i_1_n_0 ),
        .Q(\up_rcount_reg_n_0_[2] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rcount_reg[3] 
       (.C(up_clk),
        .CE(\up_rcount[4]_i_1_n_0 ),
        .D(\up_rcount[3]_i_1_n_0 ),
        .Q(\up_rcount_reg_n_0_[3] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rcount_reg[4] 
       (.C(up_clk),
        .CE(\up_rcount[4]_i_1_n_0 ),
        .D(\up_rcount[4]_i_2_n_0 ),
        .Q(p_0_in6_in),
        .R(p_0_in));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[0]_i_1 
       (.I0(up_rdata[0]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[10]_i_1 
       (.I0(up_rdata[10]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[11]_i_1 
       (.I0(up_rdata[11]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[12]_i_1 
       (.I0(up_rdata[12]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[14]_i_1 
       (.I0(up_rdata[14]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[15]_i_1 
       (.I0(up_rdata[15]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[16]_i_1 
       (.I0(up_rdata[16]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[16]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[18]_i_1 
       (.I0(up_rdata[18]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[18]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[19]_i_1 
       (.I0(up_rdata[19]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[19]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[21]_i_1 
       (.I0(up_rdata[21]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[21]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[23]_i_1 
       (.I0(up_rdata[23]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[23]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[25]_i_1 
       (.I0(up_rdata[25]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[25]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[26]_i_1 
       (.I0(up_rdata[26]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[26]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[27]_i_1 
       (.I0(up_rdata[27]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[27]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[28]_i_1 
       (.I0(up_rdata[28]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[28]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h80000000FFFFFFFF)) 
    \up_rdata_d[29]_i_1 
       (.I0(p_0_in6_in),
        .I1(\up_rcount_reg_n_0_[3] ),
        .I2(\up_rcount_reg_n_0_[2] ),
        .I3(\up_rcount_reg_n_0_[1] ),
        .I4(\up_rcount_reg_n_0_[0] ),
        .I5(up_rstn),
        .O(\up_rdata_d[29]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[2]_i_1 
       (.I0(up_rdata[2]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[30]_i_1 
       (.I0(up_rdata[30]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[30]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[31]_i_1 
       (.I0(up_rdata[31]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[31]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[3]_i_1 
       (.I0(up_rdata[3]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[5]_i_1 
       (.I0(up_rdata[5]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[7]_i_1 
       (.I0(up_rdata[7]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEAAAAAAAAAAAAAAA)) 
    \up_rdata_d[9]_i_1 
       (.I0(up_rdata[9]),
        .I1(p_0_in6_in),
        .I2(\up_rcount_reg_n_0_[3] ),
        .I3(\up_rcount_reg_n_0_[2] ),
        .I4(\up_rcount_reg_n_0_[1] ),
        .I5(\up_rcount_reg_n_0_[0] ),
        .O(\up_rdata_d[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[0] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[0]_i_1_n_0 ),
        .Q(up_rdata_d[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[10] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[10]_i_1_n_0 ),
        .Q(up_rdata_d[10]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[11] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[11]_i_1_n_0 ),
        .Q(up_rdata_d[11]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[12] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[12]_i_1_n_0 ),
        .Q(up_rdata_d[12]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[13] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[13]),
        .Q(up_rdata_d[13]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[14] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[14]_i_1_n_0 ),
        .Q(up_rdata_d[14]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[15] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[15]_i_1_n_0 ),
        .Q(up_rdata_d[15]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[16] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[16]_i_1_n_0 ),
        .Q(up_rdata_d[16]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[17] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[17]),
        .Q(up_rdata_d[17]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[18] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[18]_i_1_n_0 ),
        .Q(up_rdata_d[18]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[19] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[19]_i_1_n_0 ),
        .Q(up_rdata_d[19]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[1] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[1]),
        .Q(up_rdata_d[1]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[20] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[20]),
        .Q(up_rdata_d[20]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[21] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[21]_i_1_n_0 ),
        .Q(up_rdata_d[21]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[22] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[22]),
        .Q(up_rdata_d[22]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[23] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[23]_i_1_n_0 ),
        .Q(up_rdata_d[23]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[24] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[24]),
        .Q(up_rdata_d[24]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[25] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[25]_i_1_n_0 ),
        .Q(up_rdata_d[25]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[26] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[26]_i_1_n_0 ),
        .Q(up_rdata_d[26]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[27] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[27]_i_1_n_0 ),
        .Q(up_rdata_d[27]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[28] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[28]_i_1_n_0 ),
        .Q(up_rdata_d[28]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[29] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[29]),
        .Q(up_rdata_d[29]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[2] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[2]_i_1_n_0 ),
        .Q(up_rdata_d[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[30] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[30]_i_1_n_0 ),
        .Q(up_rdata_d[30]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[31] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[31]_i_1_n_0 ),
        .Q(up_rdata_d[31]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[3] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[3]_i_1_n_0 ),
        .Q(up_rdata_d[3]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[4] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[4]),
        .Q(up_rdata_d[4]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[5] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[5]_i_1_n_0 ),
        .Q(up_rdata_d[5]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[6] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[6]),
        .Q(up_rdata_d[6]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[7] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[7]_i_1_n_0 ),
        .Q(up_rdata_d[7]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[8] 
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rdata[8]),
        .Q(up_rdata_d[8]),
        .R(\up_rdata_d[29]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \up_rdata_d_reg[9] 
       (.C(up_clk),
        .CE(1'b1),
        .D(\up_rdata_d[9]_i_1_n_0 ),
        .Q(up_rdata_d[9]),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'h80)) 
    up_rreq_int_i_1
       (.I0(p_1_in_0),
        .I1(up_axi_arvalid),
        .I2(up_rstn),
        .O(up_rreq_int_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_rreq_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rreq_int_i_1_n_0),
        .Q(up_rreq),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h55C0)) 
    up_rsel_inv_i_1
       (.I0(up_axi_arvalid),
        .I1(up_axi_rready),
        .I2(up_axi_rvalid_int_reg_0),
        .I3(p_1_in_0),
        .O(up_rsel_inv_i_1_n_0));
  (* inverted = "yes" *) 
  FDSE #(
    .INIT(1'b1)) 
    up_rsel_reg_inv
       (.C(up_clk),
        .CE(1'b1),
        .D(up_rsel_inv_i_1_n_0),
        .Q(p_1_in_0),
        .S(p_0_in));
  LUT6 #(
    .INIT(64'hFFFF000080000000)) 
    up_wack_d_i_1
       (.I0(\up_wcount_reg_n_0_[3] ),
        .I1(\up_wcount_reg_n_0_[2] ),
        .I2(\up_wcount_reg_n_0_[1] ),
        .I3(\up_wcount_reg_n_0_[0] ),
        .I4(p_0_in7_in),
        .I5(up_wack),
        .O(up_wack_s));
  FDRE #(
    .INIT(1'b0)) 
    up_wack_d_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_wack_s),
        .Q(up_wack_d),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[0] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[0]),
        .Q(up_waddr[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[10] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[10]),
        .Q(up_waddr[10]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[11] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[11]),
        .Q(up_waddr[11]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[12] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[12]),
        .Q(up_waddr[12]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[13] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[13]),
        .Q(up_waddr[13]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[14] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[14]),
        .Q(up_waddr[14]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[15] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[15]),
        .Q(up_waddr[15]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[1] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[1]),
        .Q(up_waddr[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[2] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[2]),
        .Q(up_waddr[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[3] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[3]),
        .Q(up_waddr[3]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[4] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[4]),
        .Q(up_waddr[4]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[5] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[5]),
        .Q(up_waddr[5]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[6] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[6]),
        .Q(up_waddr[6]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[7] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[7]),
        .Q(up_waddr[7]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[8] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[8]),
        .Q(up_waddr[8]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_waddr_int_reg[9] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_awaddr[9]),
        .Q(up_waddr[9]),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'h04)) 
    \up_wcount[0]_i_1 
       (.I0(up_wack),
        .I1(p_0_in7_in),
        .I2(\up_wcount_reg_n_0_[0] ),
        .O(\up_wcount[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h1400)) 
    \up_wcount[1]_i_1 
       (.I0(up_wack),
        .I1(\up_wcount_reg_n_0_[0] ),
        .I2(\up_wcount_reg_n_0_[1] ),
        .I3(p_0_in7_in),
        .O(p_2_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h14440000)) 
    \up_wcount[2]_i_1 
       (.I0(up_wack),
        .I1(\up_wcount_reg_n_0_[2] ),
        .I2(\up_wcount_reg_n_0_[1] ),
        .I3(\up_wcount_reg_n_0_[0] ),
        .I4(p_0_in7_in),
        .O(\up_wcount[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1444444400000000)) 
    \up_wcount[3]_i_1 
       (.I0(up_wack),
        .I1(\up_wcount_reg_n_0_[3] ),
        .I2(\up_wcount_reg_n_0_[0] ),
        .I3(\up_wcount_reg_n_0_[1] ),
        .I4(\up_wcount_reg_n_0_[2] ),
        .I5(p_0_in7_in),
        .O(p_2_in[3]));
  LUT2 #(
    .INIT(4'hE)) 
    \up_wcount[4]_i_1 
       (.I0(p_0_in7_in),
        .I1(up_wreq),
        .O(p_1_in));
  LUT6 #(
    .INIT(64'h3777777777777777)) 
    \up_wcount[4]_i_2 
       (.I0(up_wack),
        .I1(p_0_in7_in),
        .I2(\up_wcount_reg_n_0_[0] ),
        .I3(\up_wcount_reg_n_0_[1] ),
        .I4(\up_wcount_reg_n_0_[2] ),
        .I5(\up_wcount_reg_n_0_[3] ),
        .O(p_2_in[4]));
  FDRE #(
    .INIT(1'b0)) 
    \up_wcount_reg[0] 
       (.C(up_clk),
        .CE(p_1_in),
        .D(\up_wcount[0]_i_1_n_0 ),
        .Q(\up_wcount_reg_n_0_[0] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wcount_reg[1] 
       (.C(up_clk),
        .CE(p_1_in),
        .D(p_2_in[1]),
        .Q(\up_wcount_reg_n_0_[1] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wcount_reg[2] 
       (.C(up_clk),
        .CE(p_1_in),
        .D(\up_wcount[2]_i_1_n_0 ),
        .Q(\up_wcount_reg_n_0_[2] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wcount_reg[3] 
       (.C(up_clk),
        .CE(p_1_in),
        .D(p_2_in[3]),
        .Q(\up_wcount_reg_n_0_[3] ),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wcount_reg[4] 
       (.C(up_clk),
        .CE(p_1_in),
        .D(p_2_in[4]),
        .Q(p_0_in7_in),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[0] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[0]),
        .Q(up_wdata[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[10] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[10]),
        .Q(up_wdata[10]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[11] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[11]),
        .Q(up_wdata[11]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[12] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[12]),
        .Q(up_wdata[12]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[13] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[13]),
        .Q(up_wdata[13]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[14] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[14]),
        .Q(up_wdata[14]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[15] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[15]),
        .Q(up_wdata[15]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[16] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[16]),
        .Q(up_wdata[16]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[17] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[17]),
        .Q(up_wdata[17]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[18] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[18]),
        .Q(up_wdata[18]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[19] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[19]),
        .Q(up_wdata[19]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[1] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[1]),
        .Q(up_wdata[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[20] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[20]),
        .Q(up_wdata[20]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[21] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[21]),
        .Q(up_wdata[21]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[22] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[22]),
        .Q(up_wdata[22]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[23] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[23]),
        .Q(up_wdata[23]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[24] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[24]),
        .Q(up_wdata[24]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[25] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[25]),
        .Q(up_wdata[25]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[26] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[26]),
        .Q(up_wdata[26]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[27] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[27]),
        .Q(up_wdata[27]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[28] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[28]),
        .Q(up_wdata[28]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[29] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[29]),
        .Q(up_wdata[29]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[2] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[2]),
        .Q(up_wdata[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[30] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[30]),
        .Q(up_wdata[30]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[31] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[31]),
        .Q(up_wdata[31]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[3] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[3]),
        .Q(up_wdata[3]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[4] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[4]),
        .Q(up_wdata[4]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[5] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[5]),
        .Q(up_wdata[5]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[6] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[6]),
        .Q(up_wdata[6]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[7] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[7]),
        .Q(up_wdata[7]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[8] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[8]),
        .Q(up_wdata[8]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \up_wdata_int_reg[9] 
       (.C(up_clk),
        .CE(p_5_in),
        .D(up_axi_wdata[9]),
        .Q(up_wdata[9]),
        .R(p_0_in));
  LUT4 #(
    .INIT(16'h8000)) 
    up_wreq_int_i_1
       (.I0(p_5_in),
        .I1(up_axi_wvalid),
        .I2(up_axi_awvalid),
        .I3(up_rstn),
        .O(up_wreq_int_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    up_wreq_int_reg
       (.C(up_clk),
        .CE(1'b1),
        .D(up_wreq_int_i_1_n_0),
        .Q(up_wreq),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h7777F000)) 
    up_wsel_inv_i_1
       (.I0(up_axi_awvalid),
        .I1(up_axi_wvalid),
        .I2(up_axi_bready),
        .I3(up_axi_bvalid),
        .I4(p_5_in),
        .O(up_wsel_inv_i_1_n_0));
  (* inverted = "yes" *) 
  FDSE #(
    .INIT(1'b1)) 
    up_wsel_reg_inv
       (.C(up_clk),
        .CE(1'b1),
        .D(up_wsel_inv_i_1_n_0),
        .Q(p_5_in),
        .S(p_0_in));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
