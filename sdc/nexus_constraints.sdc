# ==========================================================================
# NEXUS SoC - SYNTHESIS CONSTRAINTS (SDC)
# DESCRIPTION : Cleaned setup matching actual RTL port names + MCP Traps
# ==========================================================================

# 1. CLOCK DEFINITIONS
create_clock -name clk_master  -period 2.5 [get_ports clk_master]
create_clock -name clk_virtual -period 3.0

# Default Domain (VDD - 0.85V)
create_clock -name clk_sdram_0 -period 3.0 [get_ports clk_sdram_0]
create_clock -name clk_sdram_1 -period 3.0 [get_ports clk_sdram_1]
create_clock -name clk_sdram_2 -period 3.0 [get_ports clk_sdram_2]
create_clock -name clk_sdram_3 -period 3.0 [get_ports clk_sdram_3]
create_clock -name clk_ft_0    -period 5.0 [get_ports clk_ft_0]
create_clock -name clk_ft_1    -period 5.0 [get_ports clk_ft_1]

# High Power Domain (VDDH - 1.05V)
create_clock -name clk_h_tx    -period 1.5 [get_ports clk_h_tx]
create_clock -name clk_h_rx    -period 1.5 [get_ports clk_h_rx]

# Low Power Domain (VDDL - 0.78V)
create_clock -name clk_lp_tx -period 12.0 [get_ports clk_lp_tx] 
create_clock -name clk_lp_rx -period 12.0 [get_ports clk_lp_rx] 

# 2. ASYNCHRONOUS CLOCK GROUPING
set_clock_groups -asynchronous \
    -group {clk_master clk_sdram_0 clk_sdram_1 clk_sdram_2 clk_sdram_3 clk_ft_0 clk_ft_1} \
    -group {clk_h_tx clk_h_rx} \
    -group {clk_lp_tx clk_lp_rx} \
    -group {clk_virtual}

# 3. TIMING MARGINS & TRANSITIONS
set_clock_uncertainty -setup 0.20 [all_clocks] 
set_clock_uncertainty -hold  0.05 [all_clocks]
set_clock_transition 0.1 [get_clocks {clk_master clk_sdram_0 clk_sdram_1 clk_sdram_2 clk_sdram_3 clk_ft_0 clk_ft_1 clk_h_tx clk_h_rx clk_lp_tx clk_lp_rx}]

# 4. I/O CONSTRAINTS
set_input_delay  -max 0.5 -clock clk_virtual [get_ports sys_data_in*]
set_output_delay -max 0.5 -clock clk_virtual [get_ports master_sig_out*]

# 5. AREA & CONGESTION LIMITS
set_max_fanout 16 [current_design]
set_max_transition 0.5 [current_design]
set_max_capacitance 1.0 [current_design]

# 6. EDUCATIONAL TIMING TRAPS (INTENTIONAL VIOLATIONS)
# Using original RTL port names: clk_ft_0 (Slow) and clk_master (Fast)
set_multicycle_path -setup 0 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
set_multicycle_path -setup 2 -from [get_clocks clk_master] -to [get_clocks clk_ft_0]

# Force the timing engine to treat Scan Enable as logic 0 for functional timing
set_case_analysis 0 [get_ports scan_en]

# Tell the tool not to worry about setup/hold timing on the scan enable tree
set_false_path -from [get_ports scan_en]