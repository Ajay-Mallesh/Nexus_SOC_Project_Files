`timescale 1ns / 1ps
// =========================================================================
// PROJECT     : Nexus SoC Multi-Voltage Architecture
// AUTHOR      : AJAYMALLESH
// DESCRIPTION : Top Level 16-Clock SoC with CDC-Safe FIFOs and Cascade Bridge
// =========================================================================

module nexus_soc_top (
    input  wire         clk_master,
    input  wire         clk_sdram_0, input wire clk_sdram_1, 
    input  wire         clk_sdram_2, input wire clk_sdram_3,
    input  wire         clk_ft_0,    input wire clk_ft_1,       
    input  wire         clk_h_tx,    input wire clk_h_rx,
    input  wire         clk_lp_tx,   input wire clk_lp_rx,
    input  wire         iso_en_high, input wire iso_en_lp, 
    input  wire         save_en,     input wire restore_en,
    input  wire         rst_n,
    input  wire [31:0]  sys_data_in,
    
    // --- ADD THESE DFT SCAN PORTS ---
    input  wire         scan_en,
    input  wire [7:0]   scan_in,
    output wire [7:0]   scan_out,
    // --------------------------------
    
    output reg  [127:0] master_sig_out
);

    // --- Signals ---
    wire [511:0] r_pci, r_sdram, r_reg, r_core;
    wire [511:0] r_pci_h, r_sdram_s;
    wire [31:0]  context_out [0:31]; 
    wire [31:0]  context_out_cascaded; // Staged signal for 0.78V -> 0.85V crossing
    wire [7:0]   pci_out_0 [0:24], pci_out_1 [0:24], pci_out_2 [0:24], pci_out_3 [0:24];
    wire [7:0]   sdram_out [0:35];   
    wire [31:0]  reg_out [0:31];

    // --- CDC Safe FIFOs ---
    async_fifo #(.WIDTH(512)) fifo_pci (
        .wclk(clk_master), .wrst_n(rst_n), .winc(1'b1), .wdata(r_pci),
        .rclk(clk_h_tx),   .rrst_n(rst_n), .rinc(1'b1), .rdata(r_pci_h)
    );

    async_fifo #(.WIDTH(512)) fifo_sdram (
        .wclk(clk_master), .wrst_n(rst_n), .winc(1'b1), .wdata(r_sdram),
        .rclk(clk_sdram_0), .rrst_n(rst_n), .rinc(1'b1), .rdata(r_sdram_s)
    );

    // --- The 1.05V Cascade Bridge ---
    vddh_cascade_buffer u_cascade_bridge (
        .clk(clk_master),
        .rst_n(rst_n),
        .data_in(context_out[0]),      // From VDDL (0.78V domain)
        .data_out(context_out_cascaded) // To VDDH (1.05V domain)
    );

    // --- Subsystem Instantiations ---
    core_fabric u_core_unit (.clk(clk_master), .rst_n(rst_n), .sys_data_in(sys_data_in), 
                             .r_pci(r_pci), .r_sdram(r_sdram), .r_reg(r_reg), .r_core(r_core));

    pci_cluster #(.ID(0)) u_pci_tx_0 (.clk(clk_h_tx), .r_pci(r_pci_h), .pci_out(pci_out_0));
    pci_cluster #(.ID(1)) u_pci_tx_1 (.clk(clk_h_tx), .r_pci(r_pci_h), .pci_out(pci_out_1));
    pci_cluster #(.ID(2)) u_pci_rx_0 (.clk(clk_h_rx), .r_pci(r_pci_h), .pci_out(pci_out_2));
    pci_cluster #(.ID(3)) u_pci_rx_1 (.clk(clk_h_rx), .r_pci(r_pci_h), .pci_out(pci_out_3));

    lp_ram_subsystem u_lp_tx (.clk(clk_lp_tx), .rst_n(rst_n), .sys_data_in(sys_data_in), .out(context_out[0:15]));
    lp_ram_subsystem u_lp_rx (.clk(clk_lp_rx), .rst_n(rst_n), .sys_data_in(sys_data_in), .out(context_out[16:31]));

    sdram_subsystem u_sdram_ctrl (.clk(clk_sdram_0), .r_sdram(r_sdram_s), .sdram_out(sdram_out));
    reg_subsystem   u_risc_reg   (.clk(clk_master),  .r_reg(r_reg),     .reg_out(reg_out));

    // --- Output Logic (Now using cascaded 1.05V -> 0.85V bridge) ---
    always @(posedge clk_master or negedge rst_n) begin
        if (!rst_n) master_sig_out <= 128'b0;
        else master_sig_out <= {context_out_cascaded, pci_out_0[0], sdram_out[0], reg_out[0]}; 
    end
endmodule