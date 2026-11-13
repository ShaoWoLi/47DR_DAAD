`timescale 1ns/1ps
module awg_subsystem #(
    parameter integer AWG_ADDR_BITS = 10,
    parameter integer ENABLE_HOST_RAM = 1,
    parameter integer ENABLE_CAPTURE_JTAG_READ = 1,
    parameter [31:0] CAPTURE_LAYOUT = 32'h00020001,
    parameter [31:0] CAPTURE_MAX_SAMPLES = 32'd65520
) (
    input wire host_clk, input wire host_resetn,
    input wire sample_clk, input wire sample_resetn,
    input wire ram_clk, input wire ram_resetn, input wire ps_config_done,
    input wire net_clk, input wire net_resetn,
    input wire net_write_valid, output wire net_write_ready,
    output wire net_write_idle,
    input wire [2:0] net_write_channel, input wire [AWG_ADDR_BITS-1:0] net_write_addr,
    input wire [1023:0] net_write_data,
    input wire [31:0] s_awaddr, input wire s_awvalid, output wire s_awready,
    input wire [31:0] s_wdata, input wire [3:0] s_wstrb,
    input wire s_wvalid, output wire s_wready,
    output wire [1:0] s_bresp, output wire s_bvalid, input wire s_bready,
    input wire [31:0] s_araddr, input wire s_arvalid, output wire s_arready,
    output wire [31:0] s_rdata, output wire [1:0] s_rresp,
    output wire s_rvalid, input wire s_rready,
    output wire capture_read_req, output wire [17:0] capture_read_addr,
    input wire [31:0] capture_read_data, input wire capture_read_valid,
    input wire capture_busy, input wire capture_done, input wire [17:0] capture_samples,
    output wire [2047:0] dac_data, output wire [7:0] dac_valid,
    input wire [7:0] dac_ready,
    output wire running, output reg start_marker, output wire capture_marker,
    output wire [7:0] active, output wire [7:0] fault_channels,
    output wire [31:0] wrap_count, output wire ps_ready
);
    (* ASYNC_REG="TRUE" *) reg [1:0] config_sync;
    always @(posedge sample_clk) begin
        if (!sample_resetn) config_sync<=0;
        else config_sync<={config_sync[0],ps_config_done};
    end
    assign ps_ready=config_sync[1];
    (* ASYNC_REG="TRUE" *) reg [1:0] ram_config_sync;
    always @(posedge ram_clk) begin
        if (!ram_resetn) ram_config_sync <= 0;
        else ram_config_sync <= {ram_config_sync[0], ps_ready};
    end
    (* ASYNC_REG="TRUE" *) reg [7:0] dac_ready_sync1, dac_ready_sync2;
    always @(posedge ram_clk) begin
        if (!ram_resetn) begin
            dac_ready_sync1 <= 0;
            dac_ready_sync2 <= 0;
        end else begin
            dac_ready_sync1 <= dac_ready;
            dac_ready_sync2 <= dac_ready_sync1;
        end
    end
    wire [7:0] mem_en, ram_en, ram_zero, mask;
    wire [3:0] mem_we;
    wire [15:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [255:0] mem_rdata;
    wire [8*AWG_ADDR_BITS-1:0] ram_addr;
    wire [8191:0] ram_data;
    wire [8191:0] player_axis_data;
    wire [7:0] player_axis_valid, player_axis_ready;
    wire [2047:0] gearbox_data;
    wire [7:0] gearbox_valid, gearbox_data_valid, gearbox_ready;
    wire [7:0] gearbox_prefetch_ready;
    wire [7:0] gearbox_enable;
    wire [4:0] gearbox_count [0:7];
    localparam integer NET_FIFO_WIDTH = 1027 + AWG_ADDR_BITS;
    wire [NET_FIFO_WIDTH-1:0] net_fifo_din = {net_write_channel, net_write_addr, net_write_data};
    wire [NET_FIFO_WIDTH-1:0] net_fifo_dout;
    wire net_fifo_full, net_fifo_empty, net_fifo_wr_en, net_fifo_rd_en;
    wire net_fifo_wr_busy, net_fifo_rd_busy;
    wire [4:0] net_fifo_wr_data_count;
    (* ASYNC_REG="TRUE" *) reg [1:0] running_net_sync;
    always @(posedge net_clk) begin
        if (!net_resetn) running_net_sync <= 2'b11;
        else running_net_sync <= {running_net_sync[0], running};
    end
    assign net_write_ready = !net_fifo_full && !net_fifo_wr_busy && !running_net_sync[1];
    assign net_write_idle = net_fifo_wr_data_count == 0 && !net_fifo_wr_busy;
    assign net_fifo_wr_en = net_write_valid && net_write_ready;
    assign net_fifo_rd_en = !net_fifo_empty && !net_fifo_rd_busy && !running;
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("block"), .FIFO_WRITE_DEPTH(16),
        .WRITE_DATA_WIDTH(NET_FIFO_WIDTH), .READ_DATA_WIDTH(NET_FIFO_WIDTH),
        .READ_MODE("fwft"), .FIFO_READ_LATENCY(0),
        .USE_ADV_FEATURES("0000"), .CDC_SYNC_STAGES(2),
        .DOUT_RESET_VALUE("0"), .ECC_MODE("no_ecc"),
        .FULL_RESET_VALUE(0), .PROG_EMPTY_THRESH(10), .PROG_FULL_THRESH(12),
        .RD_DATA_COUNT_WIDTH(5), .WR_DATA_COUNT_WIDTH(5),
        .WAKEUP_TIME(0)
    ) net_awg_write_fifo (
        .rst(!ram_resetn || !net_resetn),
        .wr_clk(net_clk), .wr_en(net_fifo_wr_en), .din(net_fifo_din),
        .full(net_fifo_full), .overflow(), .wr_rst_busy(net_fifo_wr_busy), .wr_data_count(net_fifo_wr_data_count),
        .prog_full(), .almost_full(), .wr_ack(), .sbiterr(), .dbiterr(),
        .rd_clk(ram_clk), .rd_en(net_fifo_rd_en), .dout(net_fifo_dout),
        .empty(net_fifo_empty), .underflow(), .rd_rst_busy(net_fifo_rd_busy), .rd_data_count(),
        .prog_empty(), .almost_empty(), .data_valid(), .injectsbiterr(1'b0),
        .injectdbiterr(1'b0), .sleep(1'b0)
    );
    wire player_start_marker;
    wire player_started_ram;
    wire start, stop, clear_fault;
    wire [AWG_ADDR_BITS:0] length_beats;
    awg_control #(
        .ADDR_BITS(AWG_ADDR_BITS), .ENABLE_HOST_RAM(ENABLE_HOST_RAM),
        .ENABLE_CAPTURE_READ(ENABLE_CAPTURE_JTAG_READ),
        .CAPTURE_LAYOUT(CAPTURE_LAYOUT), .CAPTURE_MAX_SAMPLES(CAPTURE_MAX_SAMPLES)
    ) control (
        .host_clk(host_clk),.host_resetn(host_resetn),
        .s_awaddr(s_awaddr),.s_awvalid(s_awvalid),.s_awready(s_awready),
        .s_wdata(s_wdata),.s_wstrb(s_wstrb),.s_wvalid(s_wvalid),.s_wready(s_wready),
        .s_bresp(s_bresp),.s_bvalid(s_bvalid),.s_bready(s_bready),
        .s_araddr(s_araddr),.s_arvalid(s_arvalid),.s_arready(s_arready),
        .s_rdata(s_rdata),.s_rresp(s_rresp),.s_rvalid(s_rvalid),.s_rready(s_rready),
        .mem_en(mem_en),.mem_we(mem_we),.mem_addr(mem_addr),
        .mem_wdata(mem_wdata),.mem_rdata(mem_rdata),
        .capture_read_req(capture_read_req),.capture_read_addr(capture_read_addr),
        .capture_read_data(capture_read_data),.capture_read_valid(capture_read_valid),
        .capture_busy(capture_busy),.capture_done(capture_done),.capture_samples(capture_samples),
        .sample_clk(ram_clk),.sample_resetn(ram_resetn),.ps_ready(ps_ready),
        .player_running(running),.player_started(player_started_ram),.player_faults(fault_channels),
        .start(start),.stop(stop),.clear_fault(clear_fault),.capture_marker(capture_marker),
        .length_sample(length_beats),.mask_sample(mask)
    );
    (* ASYNC_REG="TRUE" *) reg [1:0] start_marker_sync;
    (* ASYNC_REG="TRUE" *) reg [1:0] start_toggle_sync;
    reg start_marker_toggle;
    reg start_toggle_seen;
    (* ASYNC_REG="TRUE" *) reg [7:0] active_sync1, active_sync2;
    reg start_marker_pending;
    reg start_marker_release_pending;
    reg gearbox_stream_enable;
    always @(posedge ram_clk) begin
        if (!ram_resetn) begin
            start_toggle_sync <= 0;
            start_toggle_seen <= 0;
        end else begin
            start_toggle_sync <= {start_toggle_sync[0], start_marker_toggle};
            start_toggle_seen <= start_toggle_sync[1];
        end
    end
    assign player_started_ram = start_toggle_sync[1] ^ start_toggle_seen;
    always @(posedge sample_clk) begin
        if (!sample_resetn) begin
            start_marker_sync <= 0;
            active_sync1 <= 0;
            active_sync2 <= 0;
            start_marker_pending <= 0;
            start_marker_release_pending <= 0;
            gearbox_stream_enable <= 0;
            start_marker <= 1'b0;
            start_marker_toggle <= 1'b0;
        end else begin
            start_marker_sync <= {start_marker_sync[0],player_start_marker};
            active_sync1 <= active;
            active_sync2 <= active_sync1;
            start_marker <= 1'b0;
            if (start_marker) start_marker_toggle <= ~start_marker_toggle;
            if (active_sync2 == 0) gearbox_stream_enable <= 0;
            if (start_marker_sync[1]) start_marker_pending <= 1'b1;
            if (start_marker_pending &&
                active_sync2 != 0 &&
                (&(gearbox_prefetch_ready | ~active_sync2))) begin
                start_marker_pending <= 1'b0;
                start_marker_release_pending <= 1'b1;
                gearbox_stream_enable <= 1'b1;
            end
            if (start_marker_release_pending &&
                ((gearbox_data_valid & active_sync2) == active_sync2) && active_sync2 != 0) begin
                start_marker <= 1'b1;
                start_marker_release_pending <= 1'b0;
            end
        end
    end
    genvar c;
    generate for (c=0;c<8;c=c+1) begin: channel
        awg_wave_bank #(.ADDR_BITS(AWG_ADDR_BITS)) wave_ram (
            .host_clk(host_clk),.host_en(mem_en[c]),.host_we(mem_we),
            .host_word_addr(mem_addr),.host_wdata(mem_wdata),.host_rdata(mem_rdata[32*c +: 32]),
            .sample_clk(ram_clk),.sample_en(ram_en[c]),.sample_zero(ram_zero[c]),
            .sample_addr(ram_addr[AWG_ADDR_BITS*c +: AWG_ADDR_BITS]),
            .sample_data(ram_data[1024*c +: 1024]),
            .net_write_en(net_fifo_rd_en && net_fifo_dout[NET_FIFO_WIDTH-1 -: 3] == c),
            .net_write_addr(net_fifo_dout[1023+AWG_ADDR_BITS:1024]),
            .net_write_data(net_fifo_dout[1023:0])
        );
        axis_wide_gearbox gearbox (
            .s_clk(ram_clk),.s_resetn(ram_resetn),.s_enable(running),
            .s_data(player_axis_data[1024*c +: 1024]),
            .s_valid(player_axis_valid[c] && active[c]),.s_ready(player_axis_ready[c]),
            .m_clk(sample_clk),.m_resetn(sample_resetn),
            .m_enable(gearbox_stream_enable),
            .m_idle(!active_sync2[c]),
            .m_data(gearbox_data[256*c +: 256]),.m_valid(gearbox_valid[c]),
            .m_data_valid(gearbox_data_valid[c]),
            .m_count(gearbox_count[c]),
            .m_prefetch_ready(gearbox_prefetch_ready[c]),
            .m_ready(gearbox_ready[c])
        );
    end endgenerate
    awg_player #(.ADDR_BITS(AWG_ADDR_BITS)) player (
        .clk(ram_clk),.resetn(ram_resetn),.ps_ready(ram_config_sync[1]),
        .start(start),.stop(stop),.clear_fault(clear_fault),
        .length_beats(length_beats),.channel_mask(mask),
        .ram_en(ram_en),.ram_zero(ram_zero),.ram_addr(ram_addr),.ram_data(ram_data),
        .axis_data(player_axis_data),.axis_valid(player_axis_valid),.axis_ready(player_axis_ready),
        .downstream_ready(dac_ready_sync2),
        .running(running),.start_marker(player_start_marker),.active(active),
        .fault_channels(fault_channels),.wrap_count(wrap_count)
    );
    genvar d;
    generate for (d=0; d<8; d=d+1) begin: dac_axis_slice
        axis_register_slice #(.DATA_WIDTH(256)) tx_slice (
            .clk(sample_clk), .resetn(sample_resetn),
            .s_data(gearbox_data[256*d +: 256]),
            .s_valid(gearbox_valid[d]), .s_ready(gearbox_ready[d]),
            .m_data(dac_data[256*d +: 256]),
            .m_valid(dac_valid[d]), .m_ready(dac_ready[d])
        );
    end endgenerate
endmodule
