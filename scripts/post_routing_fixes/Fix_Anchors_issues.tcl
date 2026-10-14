# 1. Unfix the anchors by changing their status from 'fixed' to 'placed'
set_placement_status placed [get_cells -hierarchical "u_xtree*"]

# 2. Force the anchors to snap perfectly to the legal placement site rows
legalize_placement -cells [get_cells -hierarchical "u_xtree*"]

# 3. Apply a Hard Keepout Margin (The force field!)
create_keepout_margin -type hard -outer {1 1 1 1} [get_cells -hierarchical "u_xtree*"]

# 4. Lock the anchors down permanently again
set_placement_status fixed [get_cells -hierarchical "u_xtree*"]

# 5. Legalize incrementally
legalize_placement -incremental
