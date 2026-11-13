`timescale 1ns/1ps
module reset_sync (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET async_resetn, FREQ_HZ 416667000" *)
    input wire clk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 async_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME async_resetn, POLARITY ACTIVE_LOW" *)
    input wire async_resetn,
    output wire resetn
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] pipe;

    always @(posedge clk or negedge async_resetn) begin
        if (!async_resetn)
            pipe <= 2'b00;
        else
            pipe <= {pipe[0], 1'b1};
    end

    assign resetn = pipe[1];
endmodule
