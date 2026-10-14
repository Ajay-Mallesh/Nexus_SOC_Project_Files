# ==========================================================================
# func_min.tcl (HOLD / MIN TIMING @ n40C)
# PROJECT: NEXUS SoC
# AUTHOR : RUBYYY
# ==========================================================================

# Suppress extraction warnings on multi-voltage boundary nets
suppress_message {RC-005 RC-008 RC-009}

# 1. SEARCH PATH & LIBRARIES
set search_path {/home/tools/libraries/28nm/lib/stdcell_hvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_lvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_rvt/db_nldm /home/tools/libraries/28nm/lib/sram_lp_new/db_nldm /home/ajaym/vg_10/projects/nexus_soc/inputs /home/ajaym/vg_10/projects/nexus_soc/inputs/CLIBs}

set link_library "* saed32rvt_tt1p05v125c.db saed32hvt_tt1p05v125c.db saed32lvt_tt1p05v125c.db saed32rvt_tt0p85v125c.db saed32hvt_tt0p85v125c.db saed32lvt_tt0p85v125c.db saed32rvt_tt0p78v125c.db saed32hvt_tt0p78v125c.db saed32lvt_tt0p78v125c.db saed32rvt_ulvl_tt1p05v125c_i0p85v.db saed32rvt_ulvl_tt1p05v125c_i0p78v.db saed32rvt_dlvl_tt0p85v125c_i1p05v.db saed32rvt_dlvl_tt0p78v125c_i1p05v.db saed32hvt_ulvl_tt1p05v125c_i0p85v.db saed32hvt_ulvl_tt1p05v125c_i0p78v.db saed32hvt_dlvl_tt0p85v125c_i1p05v.db saed32hvt_dlvl_tt0p78v125c_i1p05v.db saed32sramlp_ss0p95v125c_i0p95v.db dw_foundation.sldb"

# 2. READ DESIGN DATA
read_verilog /home/ajaym/vg_10/projects/nexus_soc/PRIMETIME_NEXUS_SOC/inputs/routed_nexus_soc_netlist.v
current_design nexus_soc_top
set link_create_black_boxes false
link_design nexus_soc_top -force

# 3. READ POWER INTENT
load_upf /home/ajaym/vg_10/projects/nexus_soc/PRIMETIME_NEXUS_SOC/inputs/nexus_soc_top.upf

# 4. SET VOLTAGES (Fast Corner Maximums)
set_voltage 1.16 -object_list [get_supply_nets VDDH]
set_voltage 0.95 -object_list [get_supply_nets VDD]
set_voltage 0.85 -object_list [get_supply_nets VDDL]

set_eco_options -physical_icc2_lib /home/ajaym/vg_10/projects/nexus_soc/outputs/work/NEXUS_SOC.nlib -physical_icc2_blocks last_short_util_55

# 5. READ PARASITICS & CONSTRAINTS
read_parasitics /home/ajaym/vg_10/projects/nexus_soc/PRIMETIME_NEXUS_SOC/inputs/NEXUS_SOC.cbest.spef -keep_capacitive_coupling
read_sdc /home/ajaym/vg_10/projects/nexus_soc/PRIMETIME_NEXUS_SOC/inputs/ff_m40.sdc

# ---> DISARM THE INTENTIONAL TIMING TRAPS <---
# Wiping out the artificial 0-cycle and 2-cycle traps using reset_path
reset_path -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
reset_path -from [get_clocks clk_master] -to [get_clocks clk_ft_0]

# (Or using your overwrite method, which is also perfectly valid:)
# set_multicycle_path -setup 1 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]
# set_multicycle_path -setup 1 -from [get_clocks clk_master] -to [get_clocks clk_ft_0]

# Propagate the physical clock tree to resolve hold numbers
set_propagated_clock [all_clocks]

set si_enable_analysis true
set si_xtalk_composite_aggr_mode statistical
check_eco
update_timing -full

save_session ./sessions/func_min.session
report_global_timing