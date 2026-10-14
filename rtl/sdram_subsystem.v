`timescale 1ns / 1ps
module sdram_subsystem (
    input  wire         clk, 
    input  wire [511:0] r_sdram, 
    output wire [7:0]   sdram_out [0:35]
);
    genvar s;
    generate
        for (s = 0; s < 36; s = s + 1) begin : SDRAM_MACRO_ARRAY
            SRAMLP2RW32x4 u_sdram_ram (
                .A1(r_sdram[(s*5)+4 : s*5]), .I1(r_sdram[(s*4)+3 : s*4]), .O1(sdram_out[s][3:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(r_sdram[s]), .OEB1(1'b0),
                .A2(5'b0), .I2(4'b0), .O2(sdram_out[s][7:4]), .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate
endmodule