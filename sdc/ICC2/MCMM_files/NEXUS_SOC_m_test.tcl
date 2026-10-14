# ==========================================================================
# NEXUS_SOC_m_test.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
set_case_analysis 1 [get_ports scan_en]
source NEXUS_SOC_m_func.tcl

create_clock -add -period 30.0 -name ate_clk [get_ports clk_master]
set_clock_groups -asynchronous -group {ate_clk} -group {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}
set_false_path -from [get_ports scan_en]