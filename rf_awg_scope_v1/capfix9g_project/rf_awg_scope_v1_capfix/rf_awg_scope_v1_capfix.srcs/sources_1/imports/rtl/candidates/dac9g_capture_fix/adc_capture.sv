`timescale 1ns/1ps
module adc_capture #(
    parameter integer CHANNELS = 8,
    // Four 12 x 16-bit RFDC beats form one 768-bit RAM entry.
    parameter integer CAPTURE_SAMPLES = 65520,
    parameter integer SAMPLES_PER_BEAT = 12,
    parameter integer PACK_BEATS = 4,
    parameter integer ADDR_BITS = 18,
    parameter integer FIFO_ADDR_BITS = 3
) (
    input wire adc_clk,
    input wire adc_resetn,
    input wire ram_clk,
    input wire ram_resetn,
    input wire host_clk,
    input wire host_resetn,
    input wire arm,
    input wire [CHANNELS*SAMPLES_PER_BEAT*16-1:0] adc_data,
    input wire [CHANNELS-1:0] adc_valid,
    input wire [ADDR_BITS-1:0] host_word_addr,
    input wire host_read,
    output reg [31:0] host_read_data,
    output reg host_read_valid,
    output reg busy,
    output reg done,
    output reg [17:0] captured_samples
);
    localparam integer CAPTURE_BEATS = (CAPTURE_SAMPLES + SAMPLES_PER_BEAT - 1) / SAMPLES_PER_BEAT;
    localparam integer CAPTURE_WORDS = (CAPTURE_BEATS + PACK_BEATS - 1) / PACK_BEATS;
    localparam integer CHANNEL_BEAT_WIDTH = SAMPLES_PER_BEAT * 16;
    localparam integer CHANNEL_RAM_WIDTH = CHANNEL_BEAT_WIDTH * PACK_BEATS;
    localparam integer PREVIOUS_BEATS_WIDTH = CHANNEL_BEAT_WIDTH * (PACK_BEATS - 1);
    // The host address and read_slot count 32-bit words, not 16-bit samples.
    localparam integer WORDS_PER_RAM_ENTRY = CHANNEL_RAM_WIDTH / 32;
    localparam integer FIFO_WIDTH = CHANNELS * CHANNEL_RAM_WIDTH;
    localparam integer FIFO_DEPTH = 1 << FIFO_ADDR_BITS;

    reg [CHANNEL_BEAT_WIDTH-1:0] adc_data_pipe [0:CHANNELS-1];
    reg [PREVIOUS_BEATS_WIDTH-1:0] previous_beats [0:CHANNELS-1];
    reg [CHANNELS-1:0] adc_valid_pipe;
    reg [1:0] pack_phase;
    reg [13:0] write_beat;
    reg [1:0] arm_sync;
    reg arm_seen;
    reg input_complete;
    reg start_toggle;
    (* ASYNC_REG="TRUE" *) reg [1:0] finish_sync;
    reg finish_seen;

    wire capture_write = busy && !input_complete && (&adc_valid_pipe);
    wire final_beat = (write_beat + 1 >= CAPTURE_BEATS);
    // Exact packed captures do not need the end-of-frame comparator on the
    // FIFO write-enable path. Keep the partial-final-word case parameterized.
    wire fifo_wr_en = capture_write && ((pack_phase == PACK_BEATS-1) ||
                        ((CAPTURE_BEATS % PACK_BEATS) != 0 && final_beat));
    wire [FIFO_WIDTH-1:0] fifo_din;
    wire [FIFO_WIDTH-1:0] fifo_dout;
    wire fifo_full;
    wire fifo_empty;
    wire fifo_rd_en;
    wire fifo_wr_overflow;
    wire fifo_rd_underflow;

    genvar g;
    generate
        for (g = 0; g < CHANNELS; g = g + 1) begin : pack_channels
            always @(posedge adc_clk) begin
                if (!adc_resetn) begin
                    adc_data_pipe[g] <= 0;
                    previous_beats[g] <= 0;
                end else begin
                    adc_data_pipe[g] <= adc_data[g*CHANNEL_BEAT_WIDTH +: CHANNEL_BEAT_WIDTH];
                    if (capture_write && pack_phase < PACK_BEATS-1)
                        previous_beats[g][CHANNEL_BEAT_WIDTH*pack_phase +: CHANNEL_BEAT_WIDTH]
                            <= adc_data_pipe[g];
                end
            end

            assign fifo_din[g*CHANNEL_RAM_WIDTH +: CHANNEL_RAM_WIDTH] =
                {adc_data_pipe[g], previous_beats[g]};
        end
    endgenerate

    wire [CHANNEL_RAM_WIDTH-1:0] channel_read_data [0:CHANNELS-1];
    reg [5:0] read_slot;
    reg [2:0] read_channel;
    reg read_pending;
    reg [1:0] start_sync;
    reg start_seen;
    reg ram_capture_active;
    reg [13:0] ram_write_word;
    reg finish_toggle;

    // Pack four RFDC beats, cross them through an asynchronous FIFO, then
    // write one 4x-wide RAM entry per quarter-rate RAM clock.
    adc_async_fifo #(
        .WIDTH(FIFO_WIDTH),
        .ADDR_BITS(FIFO_ADDR_BITS)
    ) capture_fifo (
        .wr_clk(adc_clk), .wr_resetn(adc_resetn),
        .wr_en(fifo_wr_en), .wr_data(fifo_din), .full(fifo_full),
        .wr_overflow(fifo_wr_overflow),
        .rd_clk(ram_clk), .rd_resetn(ram_resetn),
        .rd_en(fifo_rd_en), .rd_data(fifo_dout), .empty(fifo_empty),
        .rd_underflow(fifo_rd_underflow)
    );

    assign fifo_rd_en = ram_capture_active && !fifo_empty;

    generate
        for (g = 0; g < CHANNELS; g = g + 1) begin : channel_memory
            (* ram_style = "block" *) reg [CHANNEL_RAM_WIDTH-1:0] mem [0:CAPTURE_WORDS-1];
            reg [CHANNEL_RAM_WIDTH-1:0] read_data;

            always @(posedge ram_clk) begin
                if (fifo_rd_en)
                    mem[ram_write_word] <= fifo_dout[g*CHANNEL_RAM_WIDTH +: CHANNEL_RAM_WIDTH];
            end

            always @(posedge host_clk) begin
                if (host_read && host_word_addr[17:15] == g)
                    read_data <= mem[host_word_addr[14:0] / WORDS_PER_RAM_ENTRY];
            end

            assign channel_read_data[g] = read_data;
        end
    endgenerate

    always @(posedge adc_clk) begin
        if (!adc_resetn) begin
            write_beat <= 0;
            busy <= 0;
            done <= 0;
            captured_samples <= 0;
            arm_sync <= 0;
            arm_seen <= 0;
            adc_valid_pipe <= 0;
            pack_phase <= 0;
            input_complete <= 0;
            start_toggle <= 0;
            finish_sync <= 0;
            finish_seen <= 0;
        end else begin
            adc_valid_pipe <= adc_valid;
            arm_sync <= {arm_sync[0], arm};
            finish_sync <= {finish_sync[0], finish_toggle};
            if (!arm_sync[1]) arm_seen <= 0;
            if (arm_sync[1] && !arm_seen && !busy) begin
                arm_seen <= 1;
                busy <= 1;
                done <= 0;
                write_beat <= 0;
                captured_samples <= 0;
                pack_phase <= 0;
                input_complete <= 0;
                start_toggle <= ~start_toggle;
                finish_seen <= finish_sync[1];
            end else if (capture_write) begin
                if (fifo_wr_en) pack_phase <= 0;
                else pack_phase <= pack_phase + 1'b1;
                if (final_beat) begin
                    input_complete <= 1;
                end else begin
                    write_beat <= write_beat + 1'b1;
                    if (captured_samples + SAMPLES_PER_BEAT > CAPTURE_SAMPLES)
                        captured_samples <= CAPTURE_SAMPLES;
                    else
                        captured_samples <= captured_samples + SAMPLES_PER_BEAT;
                end
            end

            if (busy && input_complete && finish_sync[1] != finish_seen) begin
                finish_seen <= finish_sync[1];
                busy <= 0;
                done <= 1;
                captured_samples <= CAPTURE_SAMPLES;
            end
        end
    end

    always @(posedge ram_clk) begin
        if (!ram_resetn) begin
            start_sync <= 0;
            start_seen <= 0;
            ram_capture_active <= 0;
            ram_write_word <= 0;
            finish_toggle <= 0;
        end else begin
            start_sync <= {start_sync[0], start_toggle};
            if (start_sync[1] != start_seen) begin
                start_seen <= start_sync[1];
                ram_capture_active <= 1;
                ram_write_word <= 0;
            end else if (fifo_rd_en) begin
                if (ram_write_word + 1 >= CAPTURE_WORDS) begin
                    ram_capture_active <= 0;
                    finish_toggle <= ~finish_toggle;
                end else begin
                    ram_write_word <= ram_write_word + 1'b1;
                end
            end
        end
    end

    always @(posedge host_clk) begin
        if (!host_resetn) begin
            host_read_data <= 0;
            host_read_valid <= 0;
            read_pending <= 0;
            read_slot <= 0;
            read_channel <= 0;
        end else begin
            host_read_valid <= read_pending;
            read_pending <= host_read;
            if (host_read) begin
                read_slot <= host_word_addr[14:0] % WORDS_PER_RAM_ENTRY;
                read_channel <= host_word_addr[17:15];
            end
            if (read_pending)
                host_read_data <= channel_read_data[read_channel][read_slot*32 +: 32];
        end
    end
endmodule

module adc_async_fifo #(
    parameter integer WIDTH = 3072,
    parameter integer ADDR_BITS = 3
) (
    input wire wr_clk,
    input wire wr_resetn,
    input wire wr_en,
    input wire [WIDTH-1:0] wr_data,
    output wire full,
    output reg wr_overflow,
    input wire rd_clk,
    input wire rd_resetn,
    input wire rd_en,
    output wire [WIDTH-1:0] rd_data,
    output wire empty,
    output reg rd_underflow
);
    localparam integer PTR_BITS = ADDR_BITS + 1;
    localparam integer DEPTH = 1 << ADDR_BITS;
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_BITS-1:0] wr_bin, wr_gray, rd_bin, rd_gray;
    reg full_reg, empty_reg;
    (* ASYNC_REG="TRUE" *) reg [PTR_BITS-1:0] rd_gray_sync1, rd_gray_sync2;
    (* ASYNC_REG="TRUE" *) reg [PTR_BITS-1:0] wr_gray_sync1, wr_gray_sync2;
    wire wr_fire = wr_en && !full_reg;
    wire rd_fire = rd_en && !empty_reg;
    wire [PTR_BITS-1:0] wr_bin_next = wr_bin + wr_fire;
    wire [PTR_BITS-1:0] rd_bin_next = rd_bin + rd_fire;
    wire [PTR_BITS-1:0] wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    wire [PTR_BITS-1:0] rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;
    wire [PTR_BITS-1:0] full_compare = rd_gray_sync2 ^
        ((1 << ADDR_BITS) | (1 << (ADDR_BITS - 1)));
    wire full_next = wr_gray_next == full_compare;
    wire empty_next = rd_gray_next == wr_gray_sync2;

    assign full = full_reg;
    assign empty = empty_reg;
    assign rd_data = mem[rd_bin[ADDR_BITS-1:0]];

    always @(posedge wr_clk) begin
        if (!wr_resetn) begin
            wr_bin <= 0;
            wr_gray <= 0;
            full_reg <= 0;
            rd_gray_sync1 <= 0;
            rd_gray_sync2 <= 0;
            wr_overflow <= 0;
        end else begin
            rd_gray_sync1 <= rd_gray;
            rd_gray_sync2 <= rd_gray_sync1;
            full_reg <= full_next;
            if (wr_en && full) wr_overflow <= 1;
            if (wr_fire) begin
                mem[wr_bin[ADDR_BITS-1:0]] <= wr_data;
                wr_bin <= wr_bin_next;
                wr_gray <= wr_gray_next;
            end
        end
    end

    always @(posedge rd_clk) begin
        if (!rd_resetn) begin
            rd_bin <= 0;
            rd_gray <= 0;
            empty_reg <= 1;
            wr_gray_sync1 <= 0;
            wr_gray_sync2 <= 0;
            rd_underflow <= 0;
        end else begin
            wr_gray_sync1 <= wr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
            empty_reg <= empty_next;
            if (rd_en && empty) rd_underflow <= 1;
            if (rd_fire) begin
                rd_bin <= rd_bin_next;
                rd_gray <= rd_gray_next;
            end
        end
    end
endmodule
