# ==========================================================================
# NEXUS_SOC_s_test.ff_125c.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
suppress_message UID-401

# ---> DRIVING CELL FIX FOR SAED32 LIBRARY <---
set DRIVING_CELL_CLOCKS "NBUFFX4_RVT"
set DRIVING_CELL_PORTS  "NBUFFX4_RVT"

set_driving_cell -lib_cell ${DRIVING_CELL_CLOCKS} $mv_ports(clocks)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(mode_reset)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $mv_ports(sys_inputs)
set_driving_cell $mv_ports(test_si) -lib_cell INVX4_RVT
unsuppress_message UID-401

set_clock_uncertainty -setup 0.20 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]
set_clock_uncertainty -hold  0.05 [get_clocks {clk_master clk_sdram_* clk_ft_* clk_h_* clk_lp_*}]
set_clock_uncertainty -setup 0.20 [get_clocks ate_clk]
set_clock_uncertainty -hold  0.10 [get_clocks ate_clk]

set real_clocks [remove_from_collection [get_clocks *] [get_clocks "clk_virtual"]]
set_clock_transition 0.1 $real_clocks

set_input_delay  -add_delay -max 0.5 -clock clk_virtual $mv_ports(sys_inputs)
set_output_delay -add_delay -max 0.5 -clock clk_virtual $mv_ports(sys_outputs)

set_input_delay  -max 4.0 -clock ate_clk $mv_ports(mode_reset)
set_input_delay  -max 2.0 -clock ate_clk $mv_ports(test_si)
set_output_delay -max 2.0 -clock ate_clk $mv_ports(test_so)