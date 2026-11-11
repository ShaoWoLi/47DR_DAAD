`timescale 1ns/1ps
// AXI4-Lite endpoint and a bundled-data request/acknowledge mailbox.
// Host map: 90000000..900fffff wave RAM (128 KiB/channel); 90200000..9020003f registers.
module awg_control #(
    parameter integer ADDR_BITS = 11
) (
    input wire host_clk, input wire host_resetn,
    input wire [31:0] s_awaddr, input wire s_awvalid, output wire s_awready,
    input wire [31:0] s_wdata, input wire [3:0] s_wstrb,
    input wire s_wvalid, output wire s_wready,
    output reg [1:0] s_bresp, output reg s_bvalid, input wire s_bready,
    input wire [31:0] s_araddr, input wire s_arvalid, output wire s_arready,
    output reg [31:0] s_rdata, output reg [1:0] s_rresp,
    output reg s_rvalid, input wire s_rready,
    output wire [7:0] mem_en, output wire [3:0] mem_we,
    output wire [15:0] mem_addr, output wire [31:0] mem_wdata,
    input wire [255:0] mem_rdata,
    output wire capture_read_req, output wire [17:0] capture_read_addr,
    input wire [31:0] capture_read_data, input wire capture_read_valid,
    input wire capture_busy, input wire capture_done, input wire [17:0] capture_samples,
    input wire sample_clk, input wire sample_resetn, input wire ps_ready,
    input wire player_running, input wire player_started,
    input wire [7:0] player_faults,
    output reg start, output reg stop, output reg clear_fault,
    output reg capture_marker,
    output reg [ADDR_BITS:0] length_sample,
    output reg [7:0] mask_sample
);
    localparam [31:0] REG_BASE=32'h90200000;
    localparam [31:0] CAPTURE_BASE=32'h91000000;
    reg aw_full, w_full;
    reg [31:0] awaddr, wdata;
    reg [3:0] wstrb;
    reg [ADDR_BITS:0] length_host;
    reg [7:0] mask_host;
    reg [3:0] command_payload;
    reg [ADDR_BITS:0] length_payload;
    reg [7:0] mask_payload;
    reg request_toggle;
    reg ack_toggle;
    (* ASYNC_REG="TRUE" *) reg [1:0] ack_sync, running_sync, ready_sync;
    (* ASYNC_REG="TRUE" *) reg [1:0] capture_status_meta, capture_status_sync;
    (* ASYNC_REG="TRUE" *) reg [17:0] capture_samples_meta, capture_samples_sync;
    (* ASYNC_REG="TRUE" *) reg [7:0] faults_meta, faults_sync;
    (* ASYNC_REG="TRUE" *) reg [1:0] request_sync;
    reg [1:0] result_sample;
    (* ASYNC_REG="TRUE" *) reg [1:0] result_meta, result_sync;
    reg [2:0] command_state;
    reg capture_read_pending;
    reg [3:0] command_sample;
    localparam CMD_IDLE=0, CMD_DECODE=1, CMD_START=2, CMD_STOP=3, CMD_FINISH=4;
    wire busy = request_toggle != ack_sync[1];
    wire locked = busy || running_sync[1];
    wire write_fire = aw_full && w_full && !s_bvalid;
    wire write_mem = awaddr[31:20] == 12'h900 && awaddr[1:0] == 0;
    wire write_mem_ok = write_fire && write_mem && !locked;
    wire read_fire = s_arvalid && s_arready;
    wire read_mem = s_araddr[31:20] == 12'h900 && s_araddr[1:0] == 0;
    wire read_capture = s_araddr >= CAPTURE_BASE && s_araddr < CAPTURE_BASE + 32'h00100000 && s_araddr[1:0] == 0;
    // One RAM port arbitrates host read/write. A pending write takes priority.
    assign s_awready = !aw_full && !s_bvalid;
    assign s_wready = !w_full && !s_bvalid;
    reg [1:0] read_wait;
    reg [2:0] read_channel;
    assign s_arready = !s_rvalid && read_wait == 0 && !capture_read_pending && !write_fire;
    wire mem_read_fire = read_fire && read_mem;
    wire capture_read_fire = read_fire && read_capture;
    assign capture_read_req = capture_read_fire;
    assign capture_read_addr = (s_araddr - CAPTURE_BASE) >> 2;
    wire [31:0] access_addr = write_mem_ok ? awaddr : s_araddr;
    assign mem_en = (write_mem_ok || mem_read_fire) ? (8'b1 << access_addr[19:17]) : 8'd0;
    assign mem_we = write_mem_ok ? wstrb : 4'd0;
    assign mem_addr = {1'b0, access_addr[16:2]};
    assign mem_wdata = wdata;

    function automatic [31:0] merge_bytes(input [31:0] old_value, input [31:0] new_value, input [3:0] strobe);
        integer b;
        begin
            merge_bytes=old_value;
            for (b=0;b<4;b=b+1) if(strobe[b]) merge_bytes[b*8 +: 8]=new_value[b*8 +: 8];
        end
    endfunction
    wire [31:0] merged_length = merge_bytes({{(31-ADDR_BITS){1'b0}},length_host},wdata,wstrb);
    wire [31:0] merged_mask = merge_bytes({24'd0,mask_host},wdata,wstrb);
    wire command_valid = wstrb[0] && (wdata==1 || wdata==2 || wdata==4 || wdata==8);
    always @(posedge host_clk) begin
        if (!host_resetn) begin
            aw_full<=0; w_full<=0; awaddr<=0; wdata<=0; wstrb<=0;
            s_bvalid<=0; s_bresp<=0; s_rvalid<=0; s_rresp<=0; s_rdata<=0;
            read_wait<=0; read_channel<=0;
            capture_read_pending<=0;
            capture_status_meta<=0; capture_status_sync<=0;
            capture_samples_meta<=0; capture_samples_sync<=0;
            length_host<=1; mask_host<=0;
            command_payload<=0; length_payload<=1; mask_payload<=0;
            request_toggle<=0; ack_sync<=0; running_sync<=0; ready_sync<=0;
            faults_meta<=0; faults_sync<=0; result_meta<=0; result_sync<=0;
        end else begin
            ack_sync<={ack_sync[0],ack_toggle};
            running_sync<={running_sync[0],player_running};
            ready_sync<={ready_sync[0],ps_ready};
            faults_meta<=player_faults; faults_sync<=faults_meta;
            capture_status_meta<={capture_done,capture_busy}; capture_status_sync<=capture_status_meta;
            capture_samples_meta<=capture_samples; capture_samples_sync<=capture_samples_meta;
            result_meta<=result_sample; result_sync<=result_meta;
            if (s_awvalid && s_awready) begin awaddr<=s_awaddr; aw_full<=1; end
            if (s_wvalid && s_wready) begin wdata<=s_wdata; wstrb<=s_wstrb; w_full<=1; end
            if (s_bvalid && s_bready) s_bvalid<=0;
            if (write_fire) begin
                aw_full<=0; w_full<=0; s_bvalid<=1; s_bresp<=0;
                if (write_mem) begin
                    if (locked) s_bresp<=2; // SLVERR: RAM is immutable during a run.
                end else if (awaddr==REG_BASE+8) begin
                    if (busy || !command_valid || !ready_sync[1] ||
                        (wdata==2 && (running_sync[1] || mask_host==0 || faults_sync!=0)) ||
                        (wdata==4 && running_sync[1]) ||
                        (wdata==8 && capture_status_sync[0])) s_bresp<=2;
                    else begin
                        command_payload<=wdata[3:0];
                        length_payload<=length_host; mask_payload<=mask_host;
                        request_toggle<=~request_toggle;
                    end
                end else if (awaddr==REG_BASE+12) begin
                    if (locked || merged_length<1 || merged_length>(1<<ADDR_BITS)) s_bresp<=2;
                    else length_host<=merged_length[ADDR_BITS:0];
                end else if (awaddr==REG_BASE+16) begin
                    if (locked || merged_mask>255) s_bresp<=2;
                    else mask_host<=merged_mask[7:0];
                end else s_bresp<=2;
            end
            if (s_rvalid && s_rready) s_rvalid<=0;
            if (read_wait!=0) begin
                read_wait<=read_wait-1'b1;
                if (read_wait==1) begin
                    s_rdata<=mem_rdata[32*read_channel +: 32];
                    s_rvalid<=1; s_rresp<=0;
                end
            end
            if (capture_read_valid && capture_read_pending) begin
                s_rdata<=capture_read_data;
                s_rvalid<=1;
                s_rresp<=0;
                capture_read_pending<=0;
            end
            if (read_fire) begin
                s_rresp<=0;
                if (read_mem) begin
                    read_channel<=s_araddr[19:17]; read_wait<=1;
                end else if (read_capture) begin
                    capture_read_pending<=1;
                end else begin
                    s_rvalid<=1;
                    case (s_araddr)
                        REG_BASE: s_rdata<=32'h41574731; // AWG1
                        REG_BASE+4: s_rdata<={26'd0,result_sync, faults_sync!=0,ready_sync[1],busy,running_sync[1]};
                        REG_BASE+8: s_rdata<=0;
                        REG_BASE+12: s_rdata<=length_host;
                        REG_BASE+16: s_rdata<=mask_host;
                        REG_BASE+20: s_rdata<=32'd9000000; // 9.0 GS/s expressed in kS/s.
                        REG_BASE+24: s_rdata<=32'd0; // RFDC DUC/NCO disabled.
                        REG_BASE+28: s_rdata<=faults_sync;
                        REG_BASE+32: s_rdata<=32'h00020001; // ADC RAM uses contiguous 32-bit host words.
                        REG_BASE+36: s_rdata<=32'd65520;
                        REG_BASE+40: s_rdata<={30'd0,capture_status_sync};
                        REG_BASE+44: s_rdata<={14'd0,capture_samples_sync};
                        default: begin s_rdata<=0; s_rresp<=2; end
                    endcase
                end
            end
        end
    end

    // Payload registers remain constant from request until acknowledgement.
    // Two RF-clock synchronizer stages give the bundled payload settling time.
    always @(posedge sample_clk) begin
        if (!sample_resetn) begin
            request_sync<=0; ack_toggle<=0; command_state<=CMD_IDLE;
            start<=0; stop<=0; clear_fault<=0; capture_marker<=0;
            length_sample<=1; mask_sample<=0; result_sample<=0;
            command_sample<=0;
        end else begin
            request_sync<={request_sync[0],request_toggle};
            start<=0; clear_fault<=0; capture_marker<=0;
            case (command_state)
                CMD_IDLE: if (request_sync[1]!=ack_toggle) begin
                    result_sample<=0;
                    // Capture the stable mailbox as data. Decode only local
                    // registers, never asynchronous command bits as enables.
                    command_sample<=command_payload;
                    length_sample<=length_payload; mask_sample<=mask_payload;
                    command_state<=CMD_DECODE;
                end
                CMD_DECODE: begin
                    case (command_sample)
                        4'd1: begin stop<=1; command_state<=CMD_STOP; end
                        4'd2: begin
                            if (!ps_ready || player_running || player_faults!=0) begin
                                result_sample<=1; command_state<=CMD_FINISH;
                            end else begin
                                start<=1; command_state<=CMD_START;
                            end
                        end
                        4'd4: begin clear_fault<=1; command_state<=CMD_FINISH; end
                        4'd8: begin capture_marker<=1; command_state<=CMD_FINISH; end
                        default: begin result_sample<=1; command_state<=CMD_FINISH; end
                    endcase
                end
                CMD_START: begin
                    if (player_started) command_state<=CMD_FINISH;
                    else if (player_faults!=0) begin result_sample<=2; command_state<=CMD_FINISH; end
                    else if (!ps_ready) begin result_sample<=1; command_state<=CMD_FINISH; end
                end
                CMD_STOP: if (!player_running) begin stop<=0; command_state<=CMD_FINISH; end
                CMD_FINISH: begin ack_toggle<=request_sync[1]; command_state<=CMD_IDLE; end
            endcase
        end
    end
endmodule
