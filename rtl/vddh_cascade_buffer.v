`timescale 1ns / 1ps
// =========================================================================
// MODULE      : VDDH Cascade Buffer
// DESCRIPTION : Intermediate staging register to step 0.78V signals up 
//               to 1.05V before dropping them to 0.85V.
// =========================================================================

module vddh_cascade_buffer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] data_in,   // Coming from 0.78V domain
    output reg  [31:0] data_out   // Leaving at 1.05V
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_out <= 32'b0;
        else 
            data_out <= data_in;
    end
endmodule