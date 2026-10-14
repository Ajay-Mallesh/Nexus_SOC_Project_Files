# ==========================================================================
# AUTHOR         : Kurry.The.Mr.GentleMan
# PROJECT        : Multi-Voltage Nexus SOC
# DESCRIPTION    : Floorplan Initialization Script
# ==========================================================================

# Initialize the chip floorplan geometry and placement grid
# -shape R: Set the block boundary to a Rectangular shape
# -side_ratio {1 1}: Maintain a 1:1 aspect ratio (creates a square block)
# -core_utilization 0.55: Allocate 55% of the core area for standard cells (leaves 45% for routing/buffers)
# -core_offset 5: Leave a 5-unit margin between the core boundary and block edge for I/O and PG rings
# -site_def unit: Define the standard cell placement site template type as "unit"
# -use_site_row: Create continuous placement rows across the core using the specified site definition

initialize_floorplan -shape R -side_ratio {1 1} -core_utilization 0.55 -core_offset 5 -site_def unit -use_site_row