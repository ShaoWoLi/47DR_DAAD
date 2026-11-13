//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Mon Nov  9 18:32:27 2026
//Host        : DESKTOP-R1144H2 running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (adc1_clk_clk_n,
    adc1_clk_clk_p,
    adc_axis_resetn,
    adc_capture_clk,
    adc_fabric_ref,
    dac2_clk_clk_n,
    dac2_clk_clk_p,
    data_clk,
    fclk_100m,
    host_resetn,
    m00_axis_tdata,
    m00_axis_tready,
    m00_axis_tvalid,
    m02_axis_tdata,
    m02_axis_tready,
    m02_axis_tvalid,
    m10_axis_tdata,
    m10_axis_tready,
    m10_axis_tvalid,
    m12_axis_tdata,
    m12_axis_tready,
    m12_axis_tvalid,
    m20_axis_tdata,
    m20_axis_tready,
    m20_axis_tvalid,
    m22_axis_tdata,
    m22_axis_tready,
    m22_axis_tvalid,
    m30_axis_tdata,
    m30_axis_tready,
    m30_axis_tvalid,
    m32_axis_tdata,
    m32_axis_tready,
    m32_axis_tvalid,
    pl_resetn0,
    rf_resetn,
    s00_axis_tdata,
    s00_axis_tready,
    s00_axis_tvalid,
    s02_axis_tdata,
    s02_axis_tready,
    s02_axis_tvalid,
    s10_axis_tdata,
    s10_axis_tready,
    s10_axis_tvalid,
    s12_axis_tdata,
    s12_axis_tready,
    s12_axis_tvalid,
    s20_axis_tdata,
    s20_axis_tready,
    s20_axis_tvalid,
    s22_axis_tdata,
    s22_axis_tready,
    s22_axis_tvalid,
    s30_axis_tdata,
    s30_axis_tready,
    s30_axis_tvalid,
    s32_axis_tdata,
    s32_axis_tready,
    s32_axis_tvalid,
    sysref_in_diff_n,
    sysref_in_diff_p,
    up_rack,
    up_raddr,
    up_rdata,
    up_rreq,
    up_wack,
    up_waddr,
    up_wdata,
    up_wreq,
    user_sysref_adc_0,
    user_sysref_dac_0,
    vin0_01_v_n,
    vin0_01_v_p,
    vin0_23_v_n,
    vin0_23_v_p,
    vin1_01_v_n,
    vin1_01_v_p,
    vin1_23_v_n,
    vin1_23_v_p,
    vin2_01_v_n,
    vin2_01_v_p,
    vin2_23_v_n,
    vin2_23_v_p,
    vin3_01_v_n,
    vin3_01_v_p,
    vin3_23_v_n,
    vin3_23_v_p,
    vout00_v_n,
    vout00_v_p,
    vout02_v_n,
    vout02_v_p,
    vout10_v_n,
    vout10_v_p,
    vout12_v_n,
    vout12_v_p,
    vout20_v_n,
    vout20_v_p,
    vout22_v_n,
    vout22_v_p,
    vout30_v_n,
    vout30_v_p,
    vout32_v_n,
    vout32_v_p);
  input adc1_clk_clk_n;
  input adc1_clk_clk_p;
  output [0:0]adc_axis_resetn;
  output adc_capture_clk;
  input adc_fabric_ref;
  input dac2_clk_clk_n;
  input dac2_clk_clk_p;
  output data_clk;
  output fclk_100m;
  output [0:0]host_resetn;
  output [191:0]m00_axis_tdata;
  input m00_axis_tready;
  output m00_axis_tvalid;
  output [191:0]m02_axis_tdata;
  input m02_axis_tready;
  output m02_axis_tvalid;
  output [191:0]m10_axis_tdata;
  input m10_axis_tready;
  output m10_axis_tvalid;
  output [191:0]m12_axis_tdata;
  input m12_axis_tready;
  output m12_axis_tvalid;
  output [191:0]m20_axis_tdata;
  input m20_axis_tready;
  output m20_axis_tvalid;
  output [191:0]m22_axis_tdata;
  input m22_axis_tready;
  output m22_axis_tvalid;
  output [191:0]m30_axis_tdata;
  input m30_axis_tready;
  output m30_axis_tvalid;
  output [191:0]m32_axis_tdata;
  input m32_axis_tready;
  output m32_axis_tvalid;
  output pl_resetn0;
  output [0:0]rf_resetn;
  input [255:0]s00_axis_tdata;
  output s00_axis_tready;
  input s00_axis_tvalid;
  input [255:0]s02_axis_tdata;
  output s02_axis_tready;
  input s02_axis_tvalid;
  input [255:0]s10_axis_tdata;
  output s10_axis_tready;
  input s10_axis_tvalid;
  input [255:0]s12_axis_tdata;
  output s12_axis_tready;
  input s12_axis_tvalid;
  input [255:0]s20_axis_tdata;
  output s20_axis_tready;
  input s20_axis_tvalid;
  input [255:0]s22_axis_tdata;
  output s22_axis_tready;
  input s22_axis_tvalid;
  input [255:0]s30_axis_tdata;
  output s30_axis_tready;
  input s30_axis_tvalid;
  input [255:0]s32_axis_tdata;
  output s32_axis_tready;
  input s32_axis_tvalid;
  input sysref_in_diff_n;
  input sysref_in_diff_p;
  input up_rack;
  output [15:0]up_raddr;
  input [31:0]up_rdata;
  output up_rreq;
  input up_wack;
  output [15:0]up_waddr;
  output [31:0]up_wdata;
  output up_wreq;
  input user_sysref_adc_0;
  input user_sysref_dac_0;
  input vin0_01_v_n;
  input vin0_01_v_p;
  input vin0_23_v_n;
  input vin0_23_v_p;
  input vin1_01_v_n;
  input vin1_01_v_p;
  input vin1_23_v_n;
  input vin1_23_v_p;
  input vin2_01_v_n;
  input vin2_01_v_p;
  input vin2_23_v_n;
  input vin2_23_v_p;
  input vin3_01_v_n;
  input vin3_01_v_p;
  input vin3_23_v_n;
  input vin3_23_v_p;
  output vout00_v_n;
  output vout00_v_p;
  output vout02_v_n;
  output vout02_v_p;
  output vout10_v_n;
  output vout10_v_p;
  output vout12_v_n;
  output vout12_v_p;
  output vout20_v_n;
  output vout20_v_p;
  output vout22_v_n;
  output vout22_v_p;
  output vout30_v_n;
  output vout30_v_p;
  output vout32_v_n;
  output vout32_v_p;

  wire adc1_clk_clk_n;
  wire adc1_clk_clk_p;
  wire [0:0]adc_axis_resetn;
  wire adc_capture_clk;
  wire adc_fabric_ref;
  wire dac2_clk_clk_n;
  wire dac2_clk_clk_p;
  wire data_clk;
  wire fclk_100m;
  wire [0:0]host_resetn;
  wire [191:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire [191:0]m02_axis_tdata;
  wire m02_axis_tready;
  wire m02_axis_tvalid;
  wire [191:0]m10_axis_tdata;
  wire m10_axis_tready;
  wire m10_axis_tvalid;
  wire [191:0]m12_axis_tdata;
  wire m12_axis_tready;
  wire m12_axis_tvalid;
  wire [191:0]m20_axis_tdata;
  wire m20_axis_tready;
  wire m20_axis_tvalid;
  wire [191:0]m22_axis_tdata;
  wire m22_axis_tready;
  wire m22_axis_tvalid;
  wire [191:0]m30_axis_tdata;
  wire m30_axis_tready;
  wire m30_axis_tvalid;
  wire [191:0]m32_axis_tdata;
  wire m32_axis_tready;
  wire m32_axis_tvalid;
  wire pl_resetn0;
  wire [0:0]rf_resetn;
  wire [255:0]s00_axis_tdata;
  wire s00_axis_tready;
  wire s00_axis_tvalid;
  wire [255:0]s02_axis_tdata;
  wire s02_axis_tready;
  wire s02_axis_tvalid;
  wire [255:0]s10_axis_tdata;
  wire s10_axis_tready;
  wire s10_axis_tvalid;
  wire [255:0]s12_axis_tdata;
  wire s12_axis_tready;
  wire s12_axis_tvalid;
  wire [255:0]s20_axis_tdata;
  wire s20_axis_tready;
  wire s20_axis_tvalid;
  wire [255:0]s22_axis_tdata;
  wire s22_axis_tready;
  wire s22_axis_tvalid;
  wire [255:0]s30_axis_tdata;
  wire s30_axis_tready;
  wire s30_axis_tvalid;
  wire [255:0]s32_axis_tdata;
  wire s32_axis_tready;
  wire s32_axis_tvalid;
  wire sysref_in_diff_n;
  wire sysref_in_diff_p;
  wire up_rack;
  wire [15:0]up_raddr;
  wire [31:0]up_rdata;
  wire up_rreq;
  wire up_wack;
  wire [15:0]up_waddr;
  wire [31:0]up_wdata;
  wire up_wreq;
  wire user_sysref_adc_0;
  wire user_sysref_dac_0;
  wire vin0_01_v_n;
  wire vin0_01_v_p;
  wire vin0_23_v_n;
  wire vin0_23_v_p;
  wire vin1_01_v_n;
  wire vin1_01_v_p;
  wire vin1_23_v_n;
  wire vin1_23_v_p;
  wire vin2_01_v_n;
  wire vin2_01_v_p;
  wire vin2_23_v_n;
  wire vin2_23_v_p;
  wire vin3_01_v_n;
  wire vin3_01_v_p;
  wire vin3_23_v_n;
  wire vin3_23_v_p;
  wire vout00_v_n;
  wire vout00_v_p;
  wire vout02_v_n;
  wire vout02_v_p;
  wire vout10_v_n;
  wire vout10_v_p;
  wire vout12_v_n;
  wire vout12_v_p;
  wire vout20_v_n;
  wire vout20_v_p;
  wire vout22_v_n;
  wire vout22_v_p;
  wire vout30_v_n;
  wire vout30_v_p;
  wire vout32_v_n;
  wire vout32_v_p;

  system system_i
       (.adc1_clk_clk_n(adc1_clk_clk_n),
        .adc1_clk_clk_p(adc1_clk_clk_p),
        .adc_axis_resetn(adc_axis_resetn),
        .adc_capture_clk(adc_capture_clk),
        .adc_fabric_ref(adc_fabric_ref),
        .dac2_clk_clk_n(dac2_clk_clk_n),
        .dac2_clk_clk_p(dac2_clk_clk_p),
        .data_clk(data_clk),
        .fclk_100m(fclk_100m),
        .host_resetn(host_resetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid),
        .m02_axis_tdata(m02_axis_tdata),
        .m02_axis_tready(m02_axis_tready),
        .m02_axis_tvalid(m02_axis_tvalid),
        .m10_axis_tdata(m10_axis_tdata),
        .m10_axis_tready(m10_axis_tready),
        .m10_axis_tvalid(m10_axis_tvalid),
        .m12_axis_tdata(m12_axis_tdata),
        .m12_axis_tready(m12_axis_tready),
        .m12_axis_tvalid(m12_axis_tvalid),
        .m20_axis_tdata(m20_axis_tdata),
        .m20_axis_tready(m20_axis_tready),
        .m20_axis_tvalid(m20_axis_tvalid),
        .m22_axis_tdata(m22_axis_tdata),
        .m22_axis_tready(m22_axis_tready),
        .m22_axis_tvalid(m22_axis_tvalid),
        .m30_axis_tdata(m30_axis_tdata),
        .m30_axis_tready(m30_axis_tready),
        .m30_axis_tvalid(m30_axis_tvalid),
        .m32_axis_tdata(m32_axis_tdata),
        .m32_axis_tready(m32_axis_tready),
        .m32_axis_tvalid(m32_axis_tvalid),
        .pl_resetn0(pl_resetn0),
        .rf_resetn(rf_resetn),
        .s00_axis_tdata(s00_axis_tdata),
        .s00_axis_tready(s00_axis_tready),
        .s00_axis_tvalid(s00_axis_tvalid),
        .s02_axis_tdata(s02_axis_tdata),
        .s02_axis_tready(s02_axis_tready),
        .s02_axis_tvalid(s02_axis_tvalid),
        .s10_axis_tdata(s10_axis_tdata),
        .s10_axis_tready(s10_axis_tready),
        .s10_axis_tvalid(s10_axis_tvalid),
        .s12_axis_tdata(s12_axis_tdata),
        .s12_axis_tready(s12_axis_tready),
        .s12_axis_tvalid(s12_axis_tvalid),
        .s20_axis_tdata(s20_axis_tdata),
        .s20_axis_tready(s20_axis_tready),
        .s20_axis_tvalid(s20_axis_tvalid),
        .s22_axis_tdata(s22_axis_tdata),
        .s22_axis_tready(s22_axis_tready),
        .s22_axis_tvalid(s22_axis_tvalid),
        .s30_axis_tdata(s30_axis_tdata),
        .s30_axis_tready(s30_axis_tready),
        .s30_axis_tvalid(s30_axis_tvalid),
        .s32_axis_tdata(s32_axis_tdata),
        .s32_axis_tready(s32_axis_tready),
        .s32_axis_tvalid(s32_axis_tvalid),
        .sysref_in_diff_n(sysref_in_diff_n),
        .sysref_in_diff_p(sysref_in_diff_p),
        .up_rack(up_rack),
        .up_raddr(up_raddr),
        .up_rdata(up_rdata),
        .up_rreq(up_rreq),
        .up_wack(up_wack),
        .up_waddr(up_waddr),
        .up_wdata(up_wdata),
        .up_wreq(up_wreq),
        .user_sysref_adc_0(user_sysref_adc_0),
        .user_sysref_dac_0(user_sysref_dac_0),
        .vin0_01_v_n(vin0_01_v_n),
        .vin0_01_v_p(vin0_01_v_p),
        .vin0_23_v_n(vin0_23_v_n),
        .vin0_23_v_p(vin0_23_v_p),
        .vin1_01_v_n(vin1_01_v_n),
        .vin1_01_v_p(vin1_01_v_p),
        .vin1_23_v_n(vin1_23_v_n),
        .vin1_23_v_p(vin1_23_v_p),
        .vin2_01_v_n(vin2_01_v_n),
        .vin2_01_v_p(vin2_01_v_p),
        .vin2_23_v_n(vin2_23_v_n),
        .vin2_23_v_p(vin2_23_v_p),
        .vin3_01_v_n(vin3_01_v_n),
        .vin3_01_v_p(vin3_01_v_p),
        .vin3_23_v_n(vin3_23_v_n),
        .vin3_23_v_p(vin3_23_v_p),
        .vout00_v_n(vout00_v_n),
        .vout00_v_p(vout00_v_p),
        .vout02_v_n(vout02_v_n),
        .vout02_v_p(vout02_v_p),
        .vout10_v_n(vout10_v_n),
        .vout10_v_p(vout10_v_p),
        .vout12_v_n(vout12_v_n),
        .vout12_v_p(vout12_v_p),
        .vout20_v_n(vout20_v_n),
        .vout20_v_p(vout20_v_p),
        .vout22_v_n(vout22_v_n),
        .vout22_v_p(vout22_v_p),
        .vout30_v_n(vout30_v_n),
        .vout30_v_p(vout30_v_p),
        .vout32_v_n(vout32_v_n),
        .vout32_v_p(vout32_v_p));
endmodule
