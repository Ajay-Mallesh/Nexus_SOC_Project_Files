# ==========================================================================
# NEXUS_SOC_m_func.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
set_case_analysis 0 [get_ports scan_en]

create_clock -period 2.5 -name clk_master [get_ports clk_master]
create_clock -period 3.0 -name clk_virtual

foreach i {0 1 2 3} { create_clock -period 3.0 -name clk_sdram_$i [get_ports clk_sdram_$i] }
foreach i {0 1} { create_clock -period 5.0 -name clk_ft_$i [get_ports clk_ft_$i] }
foreach i {tx rx} { 
    create_clock -period 1.5 -name clk_h_$i [get_ports clk_h_$i]
    create_clock -period 12.0 -name clk_lp_$i [get_ports clk_lp_$i] 
}

set_clock_groups -asynchronous \
    -group {clk_master clk_sdram_0 clk_sdram_1 clk_sdram_2 clk_sdram_3 clk_ft_0 clk_ft_1} \
    -group {clk_h_tx clk_h_rx} \
    -group {clk_lp_tx clk_lp_rx} \
    -group {clk_virtual}

set_multicycle_path -setup 0 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
set_multicycle_path -setup 2 -from [get_clocks clk_master] -to [get_clocks clk_ft_0]
set_false_path -from [get_ports scan_en]