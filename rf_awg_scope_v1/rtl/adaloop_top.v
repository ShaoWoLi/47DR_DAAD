`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/09 00:38:59
// Design Name: 
// Module Name: adaloop_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adaloop_top(
//global clock
input           pl_clk_n,
input           pl_clk_p,
input           pl_sysref_n,
input           pl_sysref_p,

//rf signal
input           adc1_clk_n,
input           adc1_clk_p,
input           dac2_clk_n,
input           dac2_clk_p,
input           sysref_in_n,
input           sysref_in_p,

input           vin0_01_n,
input           vin0_01_p,
input           vin0_23_n,
input           vin0_23_p,
input           vin1_01_n,
input           vin1_01_p,
input           vin1_23_n,
input           vin1_23_p,
input           vin2_01_n,
input           vin2_01_p,
input           vin2_23_n,
input           vin2_23_p,
input           vin3_01_n,
input           vin3_01_p,
input           vin3_23_n,
input           vin3_23_p,
output          vout00_n,
output          vout00_p,
output          vout02_n,
output          vout02_p,
output          vout10_n,
output          vout10_p,
output          vout12_n,
output          vout12_p,
output          vout20_n,
output          vout20_p,
output          vout22_n,
output          vout22_p,
output          vout30_n,
output          vout30_p,
output          vout32_n,
output          vout32_p,

output[1:0]     led

);


    wire [191:0]    m00_axis_tdata;
    wire            m00_axis_tready=1'b1;
    wire            m00_axis_tvalid;
    wire [191:0]    m02_axis_tdata;
    wire            m02_axis_tready=1'b1;
    wire            m02_axis_tvalid;
    wire [191:0]    m10_axis_tdata;
    wire            m10_axis_tready=1'b1;
    wire            m10_axis_tvalid;
    wire [191:0]    m12_axis_tdata;
    wire            m12_axis_tready=1'b1;
    wire            m12_axis_tvalid;
    wire [191:0]    m20_axis_tdata;
    wire            m20_axis_tready=1'b1;
    wire            m20_axis_tvalid;
    wire [191:0]    m22_axis_tdata;
    wire            m22_axis_tready=1'b1;
    wire            m22_axis_tvalid;
    wire [191:0]    m30_axis_tdata;
    wire            m30_axis_tready=1'b1;
    wire            m30_axis_tvalid;
    wire [191:0]    m32_axis_tdata;
    wire            m32_axis_tready=1'b1;
    wire            m32_axis_tvalid;
    wire [255:0]    s00_axis_tdata;
    wire            s00_axis_tready;
    wire            s00_axis_tvalid;
    wire [255:0]    s02_axis_tdata;
    wire            s02_axis_tready;
    wire            s02_axis_tvalid;
    wire [255:0]    s10_axis_tdata;
    wire            s10_axis_tready;
    wire            s10_axis_tvalid;
    wire [255:0]    s12_axis_tdata;
    wire            s12_axis_tready;
    wire            s12_axis_tvalid;
    wire [255:0]    s20_axis_tdata;
    wire            s20_axis_tready;
    wire            s20_axis_tvalid;
    wire [255:0]    s22_axis_tdata;
    wire            s22_axis_tready;
    wire            s22_axis_tvalid;
    wire [255:0]    s30_axis_tdata;
    wire            s30_axis_tready;
    wire            s30_axis_tvalid;
    wire [255:0]    s32_axis_tdata;
    wire            s32_axis_tready;
    wire            s32_axis_tvalid;
// Local Parameters derived from user selection
localparam C_NUM_CHNL         = 8;
wire fclk_100m, data_clk, adc_capture_clk, adc_capture_ram_clk, adc_axis_resetn, adc_capture_ram_resetn;
wire fclk_reset0, rf_resetn, host_resetn;
wire config_done;
wire [31:0] fw_ver = 32'h00010000;
wire [C_NUM_CHNL*256-1:0] dac_tdata;
wire [C_NUM_CHNL-1:0]     dac_tvalid;
wire [C_NUM_CHNL-1:0]     dac_tready;
wire [C_NUM_CHNL-1:0]     adc_tvalid;
wire [C_NUM_CHNL-1:0]     adc_tready=8'hff;
wire [C_NUM_CHNL*192-1:0] adc_raw_tdata;

wire [15:0]                   gpio_tri_i;
wire [15:0]                   gpio_tri_o;
wire [15:0]                   gpio_tri_t;
wire [ 6:0]                   axi_rd_addr;
wire [ 6:0]                   axi_wr_addr;
wire [31:0]                   axi_rd_data;
wire [31:0]                   axi_wr_data;
wire [7:0]                    adc_freeze;
wire [7:0]                    adc_clear_ov;
wire [7:0] adc_over_volt = 8'd0; // Not exported by reference RFDC BD; not an overrange measurement.

assign adc_raw_tdata[192*0+:192] = m00_axis_tdata;
assign adc_raw_tdata[192*1+:192] = m02_axis_tdata;
assign adc_raw_tdata[192*2+:192] = m10_axis_tdata;
assign adc_raw_tdata[192*3+:192] = m12_axis_tdata;
assign adc_raw_tdata[192*4+:192] = m20_axis_tdata;
assign adc_raw_tdata[192*5+:192] = m22_axis_tdata;
assign adc_raw_tdata[192*6+:192] = m30_axis_tdata;
assign adc_raw_tdata[192*7+:192] = m32_axis_tdata;
assign adc_tvalid = {m32_axis_tvalid,m30_axis_tvalid,m22_axis_tvalid,m20_axis_tvalid,
                     m12_axis_tvalid,m10_axis_tvalid,m02_axis_tvalid,m00_axis_tvalid};

assign s00_axis_tdata = dac_tdata[256*0+:256];
assign s02_axis_tdata = dac_tdata[256*1+:256];
assign s10_axis_tdata = dac_tdata[256*2+:256];
assign s12_axis_tdata = dac_tdata[256*3+:256];
assign s20_axis_tdata = dac_tdata[256*4+:256];
assign s22_axis_tdata = dac_tdata[256*5+:256];
assign s30_axis_tdata = dac_tdata[256*6+:256];
assign s32_axis_tdata = dac_tdata[256*7+:256];

assign s00_axis_tvalid = dac_tvalid[0];
assign s02_axis_tvalid = dac_tvalid[1];
assign s10_axis_tvalid = dac_tvalid[2];
assign s12_axis_tvalid = dac_tvalid[3];
assign s20_axis_tvalid = dac_tvalid[4];
assign s22_axis_tvalid = dac_tvalid[5];
assign s30_axis_tvalid = dac_tvalid[6];
assign s32_axis_tvalid = dac_tvalid[7];

assign dac_tready[0] = s00_axis_tready;
assign dac_tready[1] = s02_axis_tready;
assign dac_tready[2] = s10_axis_tready;
assign dac_tready[3] = s12_axis_tready;
assign dac_tready[4] = s20_axis_tready;
assign dac_tready[5] = s22_axis_tready;
assign dac_tready[6] = s30_axis_tready;
assign dac_tready[7] = s32_axis_tready;

reg            user_sysref_adc;
reg            user_sysref_dac;

  wire          up_rack;
  wire [15:0]   up_raddr;
  wire [31:0]   up_rdata;
  wire          up_rreq;
  wire          up_wack;
  wire [15:0]   up_waddr;
  wire [31:0]   up_wdata;
  wire          up_wreq;
    
system system_i(
    .adc1_clk_clk_n     (adc1_clk_n),
    .adc1_clk_clk_p     (adc1_clk_p),
    .dac2_clk_clk_n     (dac2_clk_n),
    .dac2_clk_clk_p     (dac2_clk_p),
    .data_clk           (data_clk),
    .adc_capture_clk    (adc_capture_clk),
    .adc_axis_resetn    (adc_axis_resetn),
    .pl_resetn0         (fclk_reset0),
    .rf_resetn          (rf_resetn),
    .host_resetn        (host_resetn),
    .m00_axis_tdata     (m00_axis_tdata),
    .m00_axis_tready    (m00_axis_tready),
    .m00_axis_tvalid    (m00_axis_tvalid),
    .m02_axis_tdata     (m02_axis_tdata),
    .m02_axis_tready    (m02_axis_tready),
    .m02_axis_tvalid    (m02_axis_tvalid),
    .m10_axis_tdata     (m10_axis_tdata),
    .m10_axis_tready    (m10_axis_tready),
    .m10_axis_tvalid    (m10_axis_tvalid),
    .m12_axis_tdata     (m12_axis_tdata),
    .m12_axis_tready    (m12_axis_tready),
    .m12_axis_tvalid    (m12_axis_tvalid),
    .m20_axis_tdata     (m20_axis_tdata),
    .m20_axis_tready    (m20_axis_tready),
    .m20_axis_tvalid    (m20_axis_tvalid),
    .m22_axis_tdata     (m22_axis_tdata),
    .m22_axis_tready    (m22_axis_tready),
    .m22_axis_tvalid    (m22_axis_tvalid),
    .m30_axis_tdata     (m30_axis_tdata),
    .m30_axis_tready    (m30_axis_tready),
    .m30_axis_tvalid    (m30_axis_tvalid),
    .m32_axis_tdata     (m32_axis_tdata),
    .m32_axis_tready    (m32_axis_tready),
    .m32_axis_tvalid    (m32_axis_tvalid),
    
    .s00_axis_tdata     (s00_axis_tdata),
    .s00_axis_tready    (s00_axis_tready),
    .s00_axis_tvalid    (s00_axis_tvalid),
    .s02_axis_tdata     (s02_axis_tdata),
    .s02_axis_tready    (s02_axis_tready),
    .s02_axis_tvalid    (s02_axis_tvalid),
    .s10_axis_tdata     (s10_axis_tdata),
    .s10_axis_tready    (s10_axis_tready),
    .s10_axis_tvalid    (s10_axis_tvalid),
    .s12_axis_tdata     (s12_axis_tdata),
    .s12_axis_tready    (s12_axis_tready),
    .s12_axis_tvalid    (s12_axis_tvalid),
    .s20_axis_tdata     (s20_axis_tdata),
    .s20_axis_tready    (s20_axis_tready),
    .s20_axis_tvalid    (s20_axis_tvalid),
    .s22_axis_tdata     (s22_axis_tdata),
    .s22_axis_tready    (s22_axis_tready),
    .s22_axis_tvalid    (s22_axis_tvalid),
    .s30_axis_tdata     (s30_axis_tdata),
    .s30_axis_tready    (s30_axis_tready),
    .s30_axis_tvalid    (s30_axis_tvalid),
    .s32_axis_tdata     (s32_axis_tdata),
    .s32_axis_tready    (s32_axis_tready),
    .s32_axis_tvalid    (s32_axis_tvalid),

//    .s00_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s00_axis_tready     (s00_axis_tready),
//    .s00_axis_tvalid     (1'b1),
//    .s02_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s02_axis_tready     (s02_axis_tready),
//    .s02_axis_tvalid     (1'b1),
//    .s10_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s10_axis_tready     (s10_axis_tready),
//    .s10_axis_tvalid     (1'b1),
//    .s12_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s12_axis_tready     (s12_axis_tready),
//    .s12_axis_tvalid     (1'b1),
//    .s20_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s20_axis_tready     (s20_axis_tready),
//    .s20_axis_tvalid     (1'b1),
//    .s22_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s22_axis_tready     (s22_axis_tready),
//    .s22_axis_tvalid     (1'b1),
//    .s30_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s30_axis_tready     (s30_axis_tready),
//    .s30_axis_tvalid     (1'b1),
//    .s32_axis_tdata      ({4{16'd0, 16'd32767}}),
//    .s32_axis_tready     (s32_axis_tready),
//    .s32_axis_tvalid     (1'b1),
    
    .sysref_in_diff_n   (sysref_in_n),
    .sysref_in_diff_p   (sysref_in_p),
    .fclk_100m          (fclk_100m),
    .up_rack            (up_rack),
    .up_raddr           (up_raddr),
    .up_rdata           (up_rdata),
    .up_rreq            (up_rreq),
    .up_wack            (up_wack),
    .up_waddr           (up_waddr),
    .up_wdata           (up_wdata),
    .up_wreq            (up_wreq),
    .user_sysref_adc_0  (user_sysref_adc),
    .user_sysref_dac_0  (user_sysref_dac),
    .vin0_01_v_n        (vin0_01_n),
    .vin0_01_v_p        (vin0_01_p),
    .vin0_23_v_n        (vin0_23_n),
    .vin0_23_v_p        (vin0_23_p),
    .vin1_01_v_n        (vin1_01_n),
    .vin1_01_v_p        (vin1_01_p),
    .vin1_23_v_n        (vin1_23_n),
    .vin1_23_v_p        (vin1_23_p),
    .vin2_01_v_n        (vin2_01_n),
    .vin2_01_v_p        (vin2_01_p),
    .vin2_23_v_n        (vin2_23_n),
    .vin2_23_v_p        (vin2_23_p),
    .vin3_01_v_n        (vin3_01_n),
    .vin3_01_v_p        (vin3_01_p),
    .vin3_23_v_n        (vin3_23_n),
    .vin3_23_v_p        (vin3_23_p),
    .vout00_v_n         (vout00_n),
    .vout00_v_p         (vout00_p),
    .vout02_v_n         (vout02_n),
    .vout02_v_p         (vout02_p),
    .vout10_v_n         (vout10_n),
    .vout10_v_p         (vout10_p),
    .vout12_v_n         (vout12_n),
    .vout12_v_p         (vout12_p),
    .vout20_v_n         (vout20_n),
    .vout20_v_p         (vout20_p),
    .vout22_v_n         (vout22_n),
    .vout22_v_p         (vout22_p),
    .vout30_v_n         (vout30_n),
    .vout30_v_p         (vout30_p),
    .vout32_v_n         (vout32_n),
    .vout32_v_p         (vout32_p)
);

// Multi-tile sync logic
  IBUFDS pl_clk_i (
    .I          (pl_clk_p),
    .IB         (pl_clk_n),
    .O          (pl_clk));

  IBUFDS pl_sysref_i (
    .I          (pl_sysref_p),
    .IB         (pl_sysref_n),
    .O          (pl_sysref));

  reg pl_sysref_r;  
  always @(posedge pl_clk) begin
    pl_sysref_r <= pl_sysref;
  end

  always @(posedge pl_clk) begin
    user_sysref_adc <= pl_sysref_r;
  end

  always @(posedge pl_clk) begin
    user_sysref_dac <= pl_sysref_r;
  end


//register defination
wire [31:0] sdr_info={16'h1000,16'd840};
wire        mtime_start;
wire [ 1:0] pps_select;
wire [31:0] clock_1pps;
wire [11:0] phase;
wire [3:0]  rf_mode;

user_control user_control(
.axi_gp_clk       (fclk_100m      ),//global
.axi_rst          (~fclk_reset0    ),
.up_rack          (up_rack),
.up_raddr         (up_raddr),
.up_rdata         (up_rdata),
.up_rreq          (up_rreq),
.up_wack          (up_wack),
.up_waddr         (up_waddr),
.up_wdata         (up_wdata),
.up_wreq          (up_wreq),
.mtime_start      (mtime_start    ),//register out
.pps_select       (pps_select     ),
.clock_1pps       (clock_1pps     ),
.phase            (phase          ),
.rf_mode          (rf_mode        ),
.config_done      (config_done    ),
.adc_freeze       (adc_freeze     ),
.adc_clear_ov     (adc_clear_ov   ),
.sdr_info         (sdr_info       ),//register in
.fw_ver           (fw_ver         ),
.adc_over_volt    (adc_over_volt  ),
.dev_clk_locked   (rf_resetn)
);

// Independent JTAG AXI4-Lite endpoint; PS RFDC address map is unchanged.
wire [31:0] j_awaddr,j_wdata,j_araddr,j_rdata;
wire [3:0] j_wstrb;
wire [1:0] j_bresp,j_rresp;
wire j_awvalid,j_awready,j_wvalid,j_wready,j_bvalid,j_bready;
wire j_arvalid,j_arready,j_rvalid,j_rready;
jtag_awg_axi jtag_axi_i (
    .aclk(fclk_100m),.aresetn(host_resetn),
    .m_axi_awaddr(j_awaddr),.m_axi_awprot(),.m_axi_awvalid(j_awvalid),.m_axi_awready(j_awready),
    .m_axi_wdata(j_wdata),.m_axi_wstrb(j_wstrb),.m_axi_wvalid(j_wvalid),.m_axi_wready(j_wready),
    .m_axi_bresp(j_bresp),.m_axi_bvalid(j_bvalid),.m_axi_bready(j_bready),
    .m_axi_araddr(j_araddr),.m_axi_arprot(),.m_axi_arvalid(j_arvalid),.m_axi_arready(j_arready),
    .m_axi_rdata(j_rdata),.m_axi_rresp(j_rresp),.m_axi_rvalid(j_rvalid),.m_axi_rready(j_rready)
);
wire awg_running, awg_start_marker, scope_capture_marker, awg_ps_ready;
wire awg_ram_clk, awg_ram_resetn;
wire [7:0] awg_active, awg_faults;
wire [31:0] awg_wraps;
wire capture_read_req, capture_read_valid, capture_busy, capture_done;
wire [17:0] capture_read_addr, capture_samples;
wire [31:0] capture_read_data;
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) awg_ram_clock_divider (
    .I(data_clk), .CE(1'b1), .CLR(1'b0), .O(awg_ram_clk)
);
BUFGCE_DIV #(.BUFGCE_DIVIDE(4)) adc_capture_ram_clock_divider (
    .I(adc_capture_clk), .CE(1'b1), .CLR(1'b0), .O(adc_capture_ram_clk)
);
reset_sync awg_ram_reset_sync (
    .clk(awg_ram_clk), .async_resetn(rf_resetn), .resetn(awg_ram_resetn)
);
reset_sync adc_capture_ram_reset_sync (
    .clk(adc_capture_ram_clk), .async_resetn(adc_axis_resetn), .resetn(adc_capture_ram_resetn)
);
awg_subsystem awg_i (
    .host_clk(fclk_100m),.host_resetn(host_resetn),
    .sample_clk(data_clk),.sample_resetn(rf_resetn),.ps_config_done(config_done),
    .ram_clk(awg_ram_clk),.ram_resetn(awg_ram_resetn),
    .s_awaddr(j_awaddr),.s_awvalid(j_awvalid),.s_awready(j_awready),
    .s_wdata(j_wdata),.s_wstrb(j_wstrb),.s_wvalid(j_wvalid),.s_wready(j_wready),
    .s_bresp(j_bresp),.s_bvalid(j_bvalid),.s_bready(j_bready),
    .s_araddr(j_araddr),.s_arvalid(j_arvalid),.s_arready(j_arready),
    .s_rdata(j_rdata),.s_rresp(j_rresp),.s_rvalid(j_rvalid),.s_rready(j_rready),
    .capture_read_req(capture_read_req),.capture_read_addr(capture_read_addr),
    .capture_read_data(capture_read_data),.capture_read_valid(capture_read_valid),
    .capture_busy(capture_busy),.capture_done(capture_done),.capture_samples(capture_samples),
    .dac_data(dac_tdata),.dac_valid(dac_tvalid),.dac_ready(dac_tready),
    .running(awg_running),.start_marker(awg_start_marker),.capture_marker(scope_capture_marker),
    .active(awg_active),.fault_channels(awg_faults),.wrap_count(awg_wraps),.ps_ready(awg_ps_ready)
);
adc_capture adc_capture_i (
    .adc_clk(adc_capture_clk),.adc_resetn(adc_axis_resetn),
    .ram_clk(adc_capture_ram_clk),.ram_resetn(adc_capture_ram_resetn),
    .host_clk(fclk_100m),.host_resetn(host_resetn),.arm(scope_capture_marker),
    .adc_data(adc_raw_tdata),.adc_valid(adc_tvalid),
    .host_word_addr(capture_read_addr),.host_read(capture_read_req),
    .host_read_data(capture_read_data),.host_read_valid(capture_read_valid),
    .busy(capture_busy),.done(capture_done),.captured_samples(capture_samples)
);
reg [31:0] adc_beat_counter;
always @(posedge adc_capture_clk) begin
    if (!adc_axis_resetn) adc_beat_counter<=0;
    else adc_beat_counter<=adc_beat_counter+1'b1;
end
ila_awg_scope scope_ila (
    .clk(adc_capture_clk),.probe0(adc_raw_tdata[15:0]),.probe1(adc_tvalid),
    .probe2(adc_beat_counter),.probe3(capture_busy),.probe4(capture_done)
);
assign led[0]=&adc_tvalid;
assign led[1]=awg_running && !(|awg_faults);
endmodule
