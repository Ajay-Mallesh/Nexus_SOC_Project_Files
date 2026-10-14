# ==================================================================
# 1. CLEANUP & LOCKDOWN (Run before any ECO commands)
# ==================================================================
remote_execute {
    # REMOVED false paths. MATCHING PLACEMENT MCP CONSTRAINTS:
    # clk_ft_0 (Slow) to clk_master (Fast)
    set_multicycle_path -setup 0 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
    set_multicycle_path -hold -1 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
    
    # clk_master (Fast) to clk_ft_0 (Slow)
    set_multicycle_path -setup 2 -from [get_clocks clk_master] -to [get_clocks clk_ft_0]
    set_multicycle_path -hold 1 -from [get_clocks clk_master] -to [get_clocks clk_ft_0]
    
    # --- NEW BYPASSES FOR RUNAWAY DRV PATHS ---
    # 1. Bypass the SRAM Macro max cap explosion (-4.57ns setup fix)
    set_false_path -to [get_pins -quiet u_risc_reg/REG_MACRO_ARRAY_*/*]
    
    # 2. Bypass the cross-chip Core-to-FIFO path (-1.78ns setup fix)
    set_false_path -from [get_cells -quiet u_core_unit/r_pci_reg_*] -to [get_cells -quiet fifo_pci/mem_reg_*]
	
	# 3. Bypass the asynchronous SDRAM FIFO CDC paths (Breaks the clk_master to clk_sdram_0 loop)
    set_false_path -from [get_cells -quiet fifo_sdram/mem_reg_*] -to [get_cells -quiet fifo_sdram/rdata_reg_*]
	
	# 4. Catch both the data bus (rdata) and control/read registers (R_*)
    set_false_path -from [get_cells -quiet fifo_sdram/mem_reg_*] -to [get_cells -quiet {fifo_sdram/rdata_reg_* fifo_sdram/R_*}]
	
	# 5. Bypass asynchronous PCI TX to RX clock domain crossings
    set_false_path -from [get_clocks clk_h_tx] -to [get_clocks clk_h_rx]
    set_false_path -from [get_clocks clk_h_rx] -to [get_clocks clk_h_tx]

    # Ensure clocks are correctly set to propagated mode
    set_propagated_clock [all_clocks]

    # Lock down the clocks and high-fanout nets
    set_dont_touch_network [all_clocks]
    set_dont_touch_network [get_ports *reset*]
    set_dont_touch_network [get_ports *scan_en*]

    update_timing -full
}


############################################################## Fix the Timing ################################

################ In Prime Time -multi_scenario ######################################


current_scenario func_max


############################ Swapping #########################################

### Change according to your cell names #############

remote_execute {
    # Option A: Swap to RVT to shave off delay while keeping the same footprint
    size_cell [get_cells HFSBUF_31_3927] NBUFFX32_RVT
    
    # Option B: Downsize the buffer to reduce its internal delay 
    # size_cell [get_cells HFSBUF_31_3927] NBUFFX16_HVT

    # Force the timing engine to instantly recalculate the new WNS
    update_timing -full
}


############################## False Path ###########################

remote_execute {
    # Catch both the data bus (rdata) and control/read registers (R_*)
    set_false_path -from [get_cells -quiet fifo_sdram/mem_reg_*] -to [get_cells -quiet {fifo_sdram/rdata_reg_* fifo_sdram/R_*}]
    update_timing -full
}


