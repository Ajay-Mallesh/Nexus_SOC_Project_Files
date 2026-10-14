# ==========================================================================
# NEXUS SoC - PORT LISTS
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
set mv_ports(clocks) [get_ports "clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*"]
set mv_ports(test_si) [get_ports scan_in -quiet] 
set mv_ports(test_so) [get_ports scan_out -quiet] 
set mv_ports(sys_inputs) [get_ports sys_data_in* -quiet]
set mv_ports(sys_outputs) [get_ports master_sig_out* -quiet]

# ---> ADD THIS MISSING LINE <---
# (Change rst_n and scan_en to match your actual top-level Verilog port names)
set mv_ports(mode_reset) [get_ports "rst_n scan_en test_mode" -quiet]

return 1