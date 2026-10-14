`timescale 1ns / 1ps
module pci_cluster #(parameter ID = 0) (
    input  wire         clk, 
    input  wire [511:0] r_pci, 
    output wire [7:0]   pci_out [0:24]
);
    genvar p;
    generate
        for (p = 0; p < 25; p = p + 1) begin : MACRO_ARRAY
            localparam idx = p + (ID * 25);
            SRAMLP2RW32x4 u_pci_ram (
                .A1(r_pci[(idx*5)+4 : idx*5]), .I1(r_pci[(idx*4)+3 : idx*4]), .O1(pci_out[p][3:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(r_pci[idx]), .OEB1(1'b0),
                .A2(5'b0), .I2(4'b0), .O2(pci_out[p][7:4]), .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate
endmodule