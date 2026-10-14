`timescale 1ns / 1ps
module reg_subsystem (
    input  wire         clk, 
    input  wire [511:0] r_reg, 
    output wire [31:0]  reg_out [0:31]
);
    genvar r;
    generate
        for (r = 0; r < 32; r = r + 1) begin : REG_MACRO_ARRAY
            SRAMLP2RW128x16 u_reg_ram (
                .A1(r_reg[(r*7)+6 : r*7]), .I1(r_reg[(r*16)+15 : r*16]), .O1(reg_out[r][15:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(r_reg[r]), .OEB1(1'b0),
                .A2(7'b0), .I2(16'b0), .O2(reg_out[r][31:16]), .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate
endmodule