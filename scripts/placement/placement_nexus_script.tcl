# ==========================================================================
# AUTHOR         : Buss Buss Cat
# PROJECT        : Multi-Voltage Nexus SOC
# DESCRIPTION    : Placement Script
# ==========================================================================

# ====================================================================
# 1. INITIALIZATION & SETUP
# ====================================================================
# Copy the completed floorplan/powerplan to a new block

# copy_block -from *all_error* -to initial_placement

# open_block initial_placement

link

# Sanity check to ensure the floorplan is ready for standard cells
check_design -checks pre_placement_stage

# Lock down hard macros (SRAMs, IPs) so the placer doesn't move them
#set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

# Read the scan chain definitions
read_def ./outputs/nexus_soc_final/nexus_soc_top.scandef

# Load the MCMM timing environment
source ./inputs/mcmm_files/mcmm_NEXUS_SOC.tcl


# ====================================================================
# Multi Cycle Path
# ====================================================================
set_multicycle_path -hold -1 -from [get_clocks clk_ft_0] -to [get_clocks clk_master]

# ====================================================================
# 2. LIBRARY CONSTRAINTS
# ====================================================================
# Unlock Tie-High/Tie-Low cells for constant logic mapping
set_attribute [get_lib_cells */*TIE*] dont_touch false
set_attribute [get_lib_cells */*TIE*] dont_use false

# ====================================================================
# 3. PLACEMENT & ROUTING SETTINGS (App Options - Fixed Syntax)
# ====================================================================
# Enable advanced legalization algorithms
set_app_options -name place.legalize.enable_advanced_legalizer -value true

set_app_options -name place.legalize.legalizer_search_and_repair -value true

# Set max density to 75% to leave room for future clock buffers
set_app_options -name place.coarse.max_density -value 0.55

# Restrict max fanout
set_app_options -name opt.common.max_fanout -value 40

set_ideal_network [all_fanout -clock_tree]

# Restrict routing estimates to Metal 2 through Metal 6
set_ignored_layers -min_routing_layer M2 -max_routing_layer M6
set_app_options -name route.common.net_max_layer_mode -value hard
set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection

# ====================================================================
# 4. BLOCKAGES & PLACEMENT EXECUTION
# ====================================================================
remove_placement_blockages -all
derive_placement_blockages

# Run raw spatial placement without timing optimization
# create_placement

# Snap the loosely placed cells legally into the standard cell rows
# legalize_placement

# ====================================================================
# 5. ANALYSIS & SAVING
# ====================================================================
# Check if the raw placement created any routing nightmares
#report_congestion -rerun_global_router

# refine_placement -congestion_effort high

# Save the raw placement database
# save_block

# Check initial timing (Expect violations since we skipped optimization)
# report_timing

place_opt

save_block place_opt_done