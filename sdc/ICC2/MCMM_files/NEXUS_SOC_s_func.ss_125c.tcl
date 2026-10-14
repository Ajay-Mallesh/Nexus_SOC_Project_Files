# ==========================================================================
# NEXUS_SOC_s_func.ss_125c.tcl (UPDATED FOR <4HR RUNTIME)
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
suppress_message UID-401
set_driving_cell -lib_cell ${DRIVING_CELL_CLOCKS} $mv_ports(clocks)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(mode_reset)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(sys_inputs)
unsuppress_message UID-401

# ---> SWEET SPOT: Aggressive setup target that is mathematically solvable on 1 CPU
set_clock_uncertainty -setup 0.25 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]
set_clock_uncertainty -hold  0.05 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]

set real_clocks [remove_from_collection [get_clocks *] [get_clocks "clk_virtual"]]
set_clock_transition 0.20 $real_clocks

# ---> SWEET SPOT: Realistic max delays that don't starve internal data paths
set_input_delay  -add_delay -max 2.0 -clock clk_virtual $mv_ports(sys_inputs)
set_output_delay -add_delay -max 2.0 -clock clk_virtual $mv_ports(sys_outputs)