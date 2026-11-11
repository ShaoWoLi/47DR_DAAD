`timescale 1ns/1ps
module axis_register_slice #(
    parameter integer DATA_WIDTH = 256
) (
    input wire clk,
    input wire resetn,
    input wire [DATA_WIDTH-1:0] s_data,
    input wire s_valid,
    output reg s_ready,
    output wire [DATA_WIDTH-1:0] m_data,
    output wire m_valid,
    input wire m_ready
);
    reg [DATA_WIDTH-1:0] data_reg0;
    reg [DATA_WIDTH-1:0] data_reg1;
    reg [1:0] occupancy;
    reg [1:0] occupancy_next;
    wire push = s_valid && s_ready;
    wire pop = m_valid && m_ready;

    // Predict readiness from the next occupancy to keep the source control path registered.
    assign m_data = data_reg0;
    assign m_valid = occupancy != 0;

    always @* begin
        occupancy_next = occupancy;
        case ({push, pop})
            2'b10: if (occupancy != 2) occupancy_next = occupancy + 1'b1;
            2'b01: if (occupancy != 0) occupancy_next = occupancy - 1'b1;
            default: occupancy_next = occupancy;
        endcase
    end

    always @(posedge clk) begin
        if (!resetn) begin
            occupancy <= 0;
            s_ready <= 1'b1;
        end else begin
            occupancy <= occupancy_next;
            s_ready <= occupancy_next != 2;
            case ({push, pop})
                2'b10: begin
                    if (occupancy == 0)
                        data_reg0 <= s_data;
                    else
                        data_reg1 <= s_data;
                end
                2'b01: begin
                    if (occupancy == 2) begin
                        data_reg0 <= data_reg1;
                    end
                end
                2'b11: begin
                    if (occupancy == 1) begin
                        data_reg0 <= s_data;
                    end else if (occupancy == 2) begin
                        data_reg0 <= data_reg1;
                        data_reg1 <= s_data;
                    end
                end
                default: begin end
            endcase
        end
    end
endmodule
