`timescale 1ns / 1ps
module core_fabric (
    input  wire         clk, 
    input  wire         rst_n, 
    input  wire [31:0]  sys_data_in,
    output reg  [511:0] r_pci, 
    output reg  [511:0] r_sdram,
    output reg  [511:0] r_reg, 
    output reg  [511:0] r_core
);
    reg [511:0] data_path_fabric [0:383]; 
    integer h;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (h = 0; h < 384; h = h + 1) data_path_fabric[h] <= 512'b0;
            r_pci <= 512'b0; r_sdram <= 512'b0; r_reg <= 512'b0; r_core <= 512'b0;
        end else begin
            data_path_fabric[0] <= {16{sys_data_in}};
            for (h = 1; h < 384; h = h + 1)
                data_path_fabric[h] <= {data_path_fabric[h-1][510:0], data_path_fabric[h-1][511]} ^ 512'hDEADBEEF;
            r_pci <= data_path_fabric[383] ^ 512'hA5A5;
            r_sdram <= data_path_fabric[383] ^ 512'h5A5A;
            r_reg <= data_path_fabric[383] ^ 512'h0F0F;
            r_core <= data_path_fabric[383] ^ 512'hF0F0;
        end
    end
endmodule