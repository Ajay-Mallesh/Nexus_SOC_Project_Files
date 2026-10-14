# ==========================================================================
# NEXUS_SOC_s_func.ss_m40c.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
suppress_message UID-401
set_driving_cell -lib_cell ${DRIVING_CELL_CLOCKS} $mv_ports(clocks)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(mode_reset)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(sys_inputs)
unsuppress_message UID-401

set_clock_uncertainty -setup 0.20 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]
set_clock_uncertainty -hold  0.05 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]

set real_clocks [remove_from_collection [get_clocks *] [get_clocks "clk_virtual"]]
set_clock_transition 0.1 $real_clocks

set_input_delay  -add_delay -max 0.5 -clock clk_virtual $mv_ports(sys_inputs)
set_input_delay  -add_delay -min 0.1 -clock clk_virtual $mv_ports(sys_inputs)
set_output_delay -add_delay -max 0.5 -clock clk_virtual $mv_ports(sys_outputs)
set_output_delay -add_delay -min 0.1 -clock clk_virtual $mv_ports(sys_outputs)