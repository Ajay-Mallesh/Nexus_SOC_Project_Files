set_attribute [get_cells fifo_pci/U4400] physical_status fixed
create_keepout_margin -type hard -outer {1 1 1 1} [get_cells "fifo_pci/U2624 fifo_pci/U2975 fifo_pci/U3008 fifo_pci/U4023 fifo_pci/ctmTdsLR_1_18516 fifo_pci/U4753 fifo_pci/U4272 fifo_pci/U3252 fifo_pci/U4123 fifo_pci/U4864"]
legalize_placement -incremental
set_routing_rule [get_nets "u_risc_reg/HFSNET_101 u_risc_reg/HFSNET_479 u_risc_reg/ZBUF_146_429 u_risc_reg/HFSNET_453 u_risc_reg/clock_opt_opt_ZBUF_103_33"] -clear
route_detail -incremental true

-------------------------------------------------------------------------------------------------------------------

# 1. Define strictly the 6 failing M1 cells and their specific nets
set bad_cells [get_cells "fifo_pci/U4400 fifo_pci/U3008 fifo_pci/U4023 fifo_pci/U4753 fifo_pci/U4272 fifo_pci/U2645"]
set bad_nets [get_nets "fifo_pci/HFSNET_2468 fifo_pci/HFSNET_2679 fifo_pci/HFSNET_2524 fifo_pci/clock_opt_opt_ZBUF_295_201 fifo_pci/HFSNET_2456 fifo_pci/HFSNET_2453"]

# 1. Tell the tool explicitly to delete the detailed and global routing shapes
remove_routes -nets $bad_nets -detail_route -global_route

# 2. Apply the hard boundary
create_keepout_margin -type hard -outer {1 1 1 1} $bad_cells

# 3. Push them out of the collision zones
legalize_placement -incremental

# 4. Lock the cells so they never snap back
set_attribute $bad_cells physical_status fixed

# 5. Route ONLY these 6 nets from scratch
route_eco -nets $bad_nets

--------------------------------------------------------------------------------------------------------------------

# 1. Target the final TWO surviving M1 shorts
set stubborn_cells [get_cells "fifo_pci/U2960 fifo_pci/U4440"]
set broken_nets [get_nets "fifo_pci/clock_opt_opt_ZBUF_349_203 fifo_pci/clock_opt_opt_ZBUF_295_201"]

# 2. Rip up the colliding wires completely
remove_routes -nets $broken_nets -detail_route -global_route

# 3. Unfix the cells and throw them a massive 15.0 microns away to guarantee they clear the strap
set_attribute $stubborn_cells physical_status unplaced
move_objects -delta {15.0 0.0} $stubborn_cells

# 4. Snap them to legal sites in the new, distant column
legalize_placement -cells $stubborn_cells
set_attribute $stubborn_cells physical_status fixed

# 5. Reroute the final two nets cleanly
route_eco -nets $broken_nets



----------------------------------------------------------------------------------------------------------------------

# 1. Target the final M1 short exact cell and net from your ErrorSet
set last_cell [get_cells "fifo_pci/U4946"]
set last_net [get_nets "fifo_pci/clock_opt_opt_ZBUF_312_203"]

# 2. Rip up the colliding wire completely
remove_routes -nets $last_net -detail_route -global_route

# 3. Unfix the cell and force a massive diagonal jump (15um X and 15um Y)
set_attribute $last_cell physical_status unplaced
move_objects -delta {15.0 15.0} $last_cell

# 4. Snap it to a safe, legal site in the distant location
legalize_placement -cells $last_cell
set_attribute $last_cell physical_status fixed

# 5. Reroute the final net cleanly
route_eco -nets $last_net