`timescale 1ns/1ps
// Thirty-two 32-bit banks form one 1024-bit RAM word: sixty-four signed real DAC samples.
// The host aperture is byte addressed and exposes each bank word individually.
module awg_wave_bank #(
    parameter integer ADDR_BITS = 10
) (
    input wire host_clk,
    input wire host_en,
    input wire [3:0] host_we,
    input wire [15:0] host_word_addr,
    input wire [31:0] host_wdata,
    output wire [31:0] host_rdata,
    input wire sample_clk,
    input wire sample_en,
    input wire sample_zero,
    input wire [ADDR_BITS-1:0] sample_addr,
    output wire [1023:0] sample_data,
    input wire net_write_en,
    input wire [ADDR_BITS-1:0] net_write_addr,
    input wire [1023:0] net_write_data
);
    wire [4:0] lane = host_word_addr[4:0];
    reg [4:0] read_lane;
    wire [1023:0] host_read;
    always @(posedge host_clk)
        if (host_en) read_lane <= lane;
    assign host_rdata = host_read[32*read_lane +: 32];

    genvar b;
    generate for (b=0; b<32; b=b+1) begin: bank
        (* ram_style = "block" *) reg [31:0] memory [0:(1<<ADDR_BITS)-1];
        reg [31:0] host_q, sample_q, sample_pipe;
        integer byte_index;
        always @(posedge host_clk) begin
            if (host_en && lane == b) begin
                for (byte_index=0; byte_index<4; byte_index=byte_index+1)
                    if (host_we[byte_index])
                        memory[host_word_addr[ADDR_BITS+4:5]][8*byte_index +: 8]
                            <= host_wdata[8*byte_index +: 8];
                host_q <= memory[host_word_addr[ADDR_BITS+4:5]];
            end
        end
        always @(posedge sample_clk) begin
            // Ethernet loads use the playback-side BRAM port while the player
            // is stopped.  The 1024-bit network word is one complete RAM row.
            if (net_write_en) begin
                memory[net_write_addr] <= net_write_data[32*b +: 32];
            end else if (sample_en) begin
                sample_q <= memory[sample_addr];
                sample_pipe <= sample_q;
            end
        end
        assign host_read[32*b +: 32] = host_q;
        assign sample_data[32*b +: 32] = sample_pipe;
    end endgenerate
endmodule
