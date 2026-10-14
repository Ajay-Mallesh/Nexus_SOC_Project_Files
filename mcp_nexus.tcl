# ==================================================================
# 1. CLEANUP & LOCKDOWN (Run before any ECO commands)
# ==================================================================
# ==========================================================================
# TIMING EXCEPTIONS: MULTI-CYCLE PATHS
# ==========================================================================

# 2-Cycle Path: u_core_unit to fifo_pci
# Setup gets 2 full clock cycles (5.0ns) to arrive
set_multicycle_path 2 -setup -from [get_cells u_core_unit/r_pci_reg_*] -to [get_cells fifo_pci/mem_reg_*]

# Hold is brought back to 1 cycle to prevent the hold check from shifting
set_multicycle_path 1 -hold  -from [get_cells u_core_unit/r_pci_reg_*] -to [get_cells fifo_pci/mem_reg_*]