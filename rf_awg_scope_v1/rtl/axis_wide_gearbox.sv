`timescale 1ns/1ps
module axis_wide_gearbox #(
    parameter integer FIFO_ADDR_BITS = 4,
    parameter integer S_DATA_WIDTH = 1024,
    parameter integer M_DATA_WIDTH = 256
) (
    input wire s_clk,
    input wire s_resetn,
    input wire s_enable,
    input wire [S_DATA_WIDTH-1:0] s_data,
    input wire s_valid,
    output wire s_ready,
    input wire m_clk,
    input wire m_resetn,
    input wire m_enable,
    input wire m_idle,
    output wire [M_DATA_WIDTH-1:0] m_data,
    output wire m_valid,
    output wire m_data_valid,
    output wire [FIFO_ADDR_BITS:0] m_count,
    output reg m_prefetch_ready,
    input wire m_ready
);
    localparam integer PTR_BITS = FIFO_ADDR_BITS + 1;
    localparam integer DEPTH = 1 << FIFO_ADDR_BITS;
    localparam integer CHUNKS = S_DATA_WIDTH / M_DATA_WIDTH;
    localparam integer CHUNK_BITS = $clog2(CHUNKS);
    (* ram_style="block" *) reg [S_DATA_WIDTH-1:0] storage [0:DEPTH-1];
    reg [PTR_BITS-1:0] wr_bin, wr_gray, rd_bin, rd_gray;
    (* ASYNC_REG="TRUE" *) reg [PTR_BITS-1:0] rd_gray_sync1, rd_gray_sync2;
    (* ASYNC_REG="TRUE" *) reg [PTR_BITS-1:0] wr_gray_sync1, wr_gray_sync2;
    (* ASYNC_REG="TRUE" *) reg flush_sync1, flush_sync2;
    reg [1:0] enable_sync;
    reg s_enable_d;
    reg flush_toggle;
    reg flush_seen;
    reg flush_ready;
    reg [CHUNK_BITS-1:0] chunk_index;
    reg [S_DATA_WIDTH-1:0] head;
    reg [S_DATA_WIDTH-1:0] prefetched_data;
    reg prefetched_valid;
    reg prefetch_pending;
    reg [M_DATA_WIDTH-1:0] output_data;
    reg output_valid;
    reg full_reg;
    wire [PTR_BITS-1:0] wr_bin_next = wr_bin + (s_valid && s_ready);
    wire [PTR_BITS-1:0] wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    wire full_next = wr_gray_next == {~rd_gray_sync2[PTR_BITS-1:PTR_BITS-2], rd_gray_sync2[PTR_BITS-3:0]};
    function automatic [PTR_BITS-1:0] gray_to_bin(input [PTR_BITS-1:0] gray);
        integer bit_index;
        begin
            gray_to_bin[PTR_BITS-1] = gray[PTR_BITS-1];
            for (bit_index=PTR_BITS-2; bit_index>=0; bit_index=bit_index-1)
                gray_to_bin[bit_index] = gray_to_bin[bit_index+1] ^ gray[bit_index];
        end
    endfunction
    wire [PTR_BITS-1:0] wr_bin_sync = gray_to_bin(wr_gray_sync2);
    wire fifo_empty = (rd_gray == wr_gray_sync2);
    wire output_slot_ready = !output_valid || m_ready;
    wire load_output = output_slot_ready && prefetched_valid &&
                       enable_sync[1] && m_enable && (flush_sync2 == flush_seen);
    wire prefetch_fire = (!prefetched_valid || load_output) &&
                         !prefetch_pending && !fifo_empty &&
                         enable_sync[1] && m_enable && flush_ready;
    wire pop = prefetch_fire;
    wire [PTR_BITS-1:0] rd_bin_next = rd_bin + pop;
    wire [PTR_BITS-1:0] rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;
    wire write_fire = s_resetn && s_enable && s_enable_d && s_valid && s_ready;

    always @(posedge s_clk) begin
        if (write_fire) storage[wr_bin[FIFO_ADDR_BITS-1:0]] <= s_data;
    end

    assign s_ready = !full_reg;
    // Keep the DAC stream active with zeros while idle, but never label an
    // empty FIFO word as valid during an active waveform.
    assign m_valid = (!m_enable || !enable_sync[1]) || m_idle || m_data_valid;
    assign m_data_valid = output_valid && enable_sync[1] && m_enable &&
                          (flush_sync2 == flush_seen);
    assign m_count = (flush_sync2 == flush_seen) ?
                     (wr_bin_sync - rd_bin + prefetched_valid + prefetch_pending) : {PTR_BITS{1'b0}};
    assign m_data = (!m_enable || m_idle) ? {M_DATA_WIDTH{1'b0}} : output_data;

    always @(posedge s_clk or negedge s_resetn) begin
        if (!s_resetn) begin
            wr_bin <= 0;
            wr_gray <= 0;
            full_reg <= 0;
            s_enable_d <= 0;
            flush_toggle <= 0;
            rd_gray_sync1 <= 0;
            rd_gray_sync2 <= 0;
        end else begin
            rd_gray_sync1 <= rd_gray;
            rd_gray_sync2 <= rd_gray_sync1;
            s_enable_d <= s_enable;
            if (s_enable_d != s_enable) flush_toggle <= ~flush_toggle;
            if (!s_enable || !s_enable_d) begin
                wr_bin <= 0;
                wr_gray <= 0;
                full_reg <= 0;
            end else begin
                full_reg <= full_next;
            end
            if (write_fire) begin
                wr_bin <= wr_bin_next;
                wr_gray <= wr_gray_next;
            end
        end
    end

    always @(posedge m_clk or negedge m_resetn) begin
        if (!m_resetn) begin
            rd_bin <= 0;
            rd_gray <= 0;
            wr_gray_sync1 <= 0;
            wr_gray_sync2 <= 0;
            flush_sync1 <= 0;
            flush_sync2 <= 0;
            enable_sync <= 0;
            chunk_index <= 0;
            flush_seen <= 0;
            flush_ready <= 0;
            prefetched_data <= 0;
            prefetched_valid <= 0;
            prefetch_pending <= 0;
            output_data <= 0;
            output_valid <= 0;
            m_prefetch_ready <= 0;
        end else begin
            wr_gray_sync1 <= wr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
            flush_sync1 <= flush_toggle;
            flush_sync2 <= flush_sync1;
            enable_sync <= {enable_sync[0], s_enable};
            m_prefetch_ready <= (flush_sync2 == flush_seen) &&
                                ((wr_bin_sync - rd_bin + prefetched_valid + prefetch_pending) >= 8);
            if (!enable_sync[1] || flush_sync2 != flush_seen)
            begin
                chunk_index <= 0;
                rd_bin <= 0;
                rd_gray <= 0;
                flush_seen <= flush_sync2;
                flush_ready <= 0;
                prefetched_valid <= 0;
                prefetch_pending <= 0;
                output_valid <= 0;
                m_prefetch_ready <= 0;
            end
            else begin
                flush_ready <= 1;
                if (output_slot_ready) begin
                    if (load_output) begin
                        output_data <= prefetched_data[M_DATA_WIDTH*chunk_index +: M_DATA_WIDTH];
                        output_valid <= 1;
                    end else output_valid <= 0;
                end
                if (load_output) begin
                    if (chunk_index == CHUNKS-1) begin
                        chunk_index <= 0;
                        prefetched_valid <= 0;
                    end else chunk_index <= chunk_index + 1'b1;
                end

                if (prefetch_fire) begin
                    head <= storage[rd_bin[FIFO_ADDR_BITS-1:0]];
                    rd_bin <= rd_bin_next;
                    rd_gray <= rd_gray_next;
                    prefetch_pending <= 1;
                end else if (prefetch_pending) begin
                    prefetched_data <= head;
                    prefetched_valid <= 1;
                    prefetch_pending <= 0;
                end
            end
        end
    end
endmodule
