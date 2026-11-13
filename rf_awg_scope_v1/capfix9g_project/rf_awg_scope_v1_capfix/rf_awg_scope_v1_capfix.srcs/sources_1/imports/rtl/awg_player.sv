`timescale 1ns/1ps
module awg_player #(
    parameter integer ADDR_BITS = 10,
    parameter integer START_TIMEOUT = 1024
) (
    input wire clk,
    input wire resetn,
    input wire ps_ready,
    input wire start,
    input wire stop,
    input wire clear_fault,
    input wire [ADDR_BITS:0] length_beats,
    input wire [7:0] channel_mask,
    output wire [7:0] ram_en,
    output wire [7:0] ram_zero,
    output wire [8*ADDR_BITS-1:0] ram_addr,
    input wire [8191:0] ram_data,
    output wire [8191:0] axis_data,
    output wire [7:0] axis_valid,
    input wire [7:0] axis_ready,
    input wire [7:0] downstream_ready,
    output reg running,
    output reg start_marker,
    output reg [7:0] active,
    output reg [7:0] fault_channels,
    output reg [31:0] wrap_count
);
    localparam IDLE=2'd0, PRIME=2'd1, PLAY=2'd2;
    reg [1:0] state;
    reg [ADDR_BITS-1:0] last_addr;
    reg [7:0] mask;
    reg stopping;
    reg [15:0] prime_wait;
    reg prime_phase;
    reg [2:0] leader;
    reg [ADDR_BITS-1:0] next_addr [0:7];
    wire all_ready = (axis_ready & mask) == mask;
    wire all_downstream_ready = (downstream_ready & mask) == mask;
    wire downstream_stall = |(active & ~downstream_ready);
    wire halt = stopping || stop || !ps_ready || downstream_stall;
    // Idle and disabled channels receive valid zeros so the RFDC is not starved.
    assign axis_valid = 8'hff;
    genvar ch;
    generate for (ch=0; ch<8; ch=ch+1) begin: output_channel
        assign ram_en[ch] = (state == PRIME && axis_ready[ch]) ||
                            (state == PLAY && active[ch] && axis_ready[ch] && !halt);
        assign ram_zero[ch] = (state == IDLE) ||
                              (state == PRIME && (!all_ready || !mask[ch])) ||
                              (state == PLAY && !active[ch]) ||
                              (state == PLAY && halt && axis_ready[ch]);
        assign ram_addr[ADDR_BITS*ch +: ADDR_BITS] = next_addr[ch];
        assign axis_data[1024*ch +: 1024] = (state == PLAY && active[ch]) ?
            ram_data[1024*ch +: 1024] : 1024'd0;
    end endgenerate
    integer i;
    always @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
            running <= 0;
            last_addr <= 0;
            mask <= 0;
            stopping <= 0;
            prime_wait <= 0;
            leader <= 0;
            active <= 0;
            fault_channels <= 0;
            start_marker <= 0;
            wrap_count <= 0;
            for (i=0; i<8; i=i+1) next_addr[i] <= 0;
        end else begin
            start_marker <= 0;
            if (clear_fault && state == IDLE) fault_channels <= 0;
            case (state)
                IDLE: begin
                    active <= 0;
                    stopping <= 0;
                    prime_phase <= 0;
                    if (start && ps_ready) begin
                        mask <= channel_mask;
                        last_addr <= length_beats[ADDR_BITS-1:0] - 1'b1;
                        prime_wait <= 0;
                        wrap_count <= 0;
                        for (i=7; i>=0; i=i-1) if (channel_mask[i]) leader <= i;
                        for (i=0; i<8; i=i+1) next_addr[i] <= 0;
                        state <= PRIME;
                        running <= 1;
                    end
                end
                PRIME: begin
                    if (stop || !ps_ready) begin state <= IDLE; running <= 0; end
                    else if (all_ready && all_downstream_ready && !prime_phase) begin
                        prime_phase <= 1;
                        for (i=0; i<8; i=i+1)
                            next_addr[i] <= length_beats <= 1 ? 0 : 1;
                    end else if (all_ready && all_downstream_ready) begin
                        active <= mask;
                        start_marker <= 1;
                        state <= PLAY;
                        prime_phase <= 0;
                        for (i=0; i<8; i=i+1)
                            next_addr[i] <= next_addr[i] == last_addr ? 0 : next_addr[i]+1'b1;
                    end else if (prime_wait == START_TIMEOUT-1) begin
                        fault_channels <= fault_channels | (mask & ~axis_ready) |
                                          (mask & ~downstream_ready);
                        state <= IDLE;
                        running <= 0;
                    end else prime_wait <= prime_wait + 1'b1;
                end
                PLAY: begin
                    if (downstream_stall) begin
                        fault_channels <= fault_channels | (active & ~downstream_ready);
                        stopping <= 1; // Any skew invalidates this multi-channel run.
                    end
                    if (halt) begin
                        // Never withdraw/change a valid stalled word. Drain each
                        // outstanding word independently, then return to zeros.
                        active <= active & ~downstream_ready;
                        if ((active & ~downstream_ready) == 0) begin
                            state <= IDLE;
                            running <= 0;
                            stopping <= 0;
                        end
                    end else begin
                        for (i=0; i<8; i=i+1)
                            if (active[i] && axis_ready[i])
                                next_addr[i] <= next_addr[i] == last_addr ? 0 : next_addr[i]+1'b1;
                        if (all_ready && next_addr[leader] == 0) wrap_count <= wrap_count + 1'b1;
                    end
                end
                default: begin state <= IDLE; running <= 0; end
            endcase
        end
    end
endmodule
