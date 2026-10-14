# Fix hard macros in place so they do not move during placement
set_fixed_objects [get_flat_cells -filter is_hard_macro]

# remove pb
remove_placement_blockages

# remove boundary cells
remove_cells [get_flat_cells -all *boundary*]

# remove tap cells
remove_cells [get_flat_cells -all *tapfiller*]

# Boundary cells
set_boundary_cell_rules -left_boundary_cell DCAP_HVT -right_boundary_cell DCAP_HVT -at_va_boundary
compile_boundary_cells

# Tap cells
create_tap_cells -lib_cell DCAP_HVT -distance 30 -skip_fixed_cells -pattern stagger

# add soft pb
derive_placement_blockages

# sanity check
check_boundary_cells