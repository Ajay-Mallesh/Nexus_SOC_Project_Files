# ==========================================================================
# NEXUS SoC - SYNTHESIS SCRIPT (WLM Single-Corner Setup & Legacy DFT)
# ==========================================================================
# PROJECT     : Nexus SoC Multi-Voltage Architecture
# AUTHOR      : AJAYMALLESH
# VERSION     : 1.2 (Zero-Error MV & 8-Chain DFT Configured)
# ==========================================================================

suppress_message {OPT-1209 TIM-134 UCN-4 UID-401}

# Create Directory 
set dir_path "./outputs/nexus_soc_final"

if {![file exists $dir_path]} {
    file mkdir $dir_path
    puts "Directory created: $dir_path"
} else {
    puts "Directory already exists: $dir_path"
}

# 1. PATHS & VARIABLES SETUP
set search_path "./inputs"
set UPF_FILE "./inputs/nexus_power_intent.upf"
set SDC_FILE "./inputs/nexus_constraints.sdc"

# 2. LIBRARY SETUP
set target_library "saed32rvt_tt0p85v125c.db saed32rvt_tt1p05v125c.db saed32rvt_tt0p78v125c.db saed32rvt_dlvl_tt0p78v125c_i1p05v.db saed32rvt_dlvl_tt0p85v125c_i1p05v.db saed32rvt_ulvl_tt1p05v125c_i0p78v.db saed32rvt_ulvl_tt1p05v125c_i0p85v.db"
set link_library "* $target_library"

# 3. READ & ELABORATE RTL 
analyze -format sverilog { \
    async_fifo.v \
    core_fabric.v \
    lp_ram_subsystem.v \
    nexus_soc_top.v \
    pci_cluster.v \
    reg_subsystem.v \
    sdram_subsystem.v \
    sram_stub.v \
    sram_stub_pci.v \
    sram_stub_reg.v \
    vddh_cascade_buffer.v \
}

elaborate nexus_soc_top
current_design nexus_soc_top
link

# Lock down all three unique macro types as Black Boxes
set_dont_touch [get_designs SRAMLP2RW64x8] true
set_dont_touch [get_designs SRAMLP2RW32x4] true
set_dont_touch [get_designs SRAMLP2RW128x16] true
# set_dont_touch [get_cells u_cascade_bridge] true

# ==========================================================================
# 4 & 5. READ POWER INTENT & WORST-CASE CONSTRAINTS
# ==========================================================================
load_upf $UPF_FILE

set_voltage 0.85 -object_list {VDD}
set_voltage 1.05 -object_list {VDDH}
set_voltage 0.78 -object_list {VDDL} 
set_voltage 0.00 -object_list {VSS}

read_sdc $SDC_FILE

# Operating conditions for the worst-case library
set_operating_conditions -library saed32rvt_tt0p85v125c tt0p85v125c

check_mv_design

# ==========================================================================
# 5.5 MULTI-VOLTAGE PRE-COMPILATION FIXES
# ==========================================================================
remove_attribute [get_lib_cells */TIE*] dont_use
set_input_transition 0.1 [get_ports rst_n]

# DISABLED OVERRIDES: Let the UPF file handle the rules to avoid MV-611 crashes
# set auto_insert_level_shifters_on_ideal_nets all
# set auto_insert_level_shifters_on_clocks all 

set compile_enable_multivoltage_dr_fix true

# ==========================================================================
# 5.6 DOMAIN BOUNDARY CONTROL 
# ==========================================================================
set_ungroup [get_cells {u_lp_tx u_lp_rx u_pci_tx_0 u_pci_tx_1 u_pci_rx_0 u_pci_rx_1 u_cascade_bridge}] false
set_boundary_optimization [get_cells {u_lp_tx u_lp_rx u_pci_tx_0 u_pci_tx_1 u_pci_rx_0 u_pci_rx_1 u_cascade_bridge}] false

# ==========================================================================
# 6. MAIN COMPILATION
# ==========================================================================
uniquify -force
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

# Force a buffer tree based on raw pin count, bypassing 0-cap blindness.
set_max_fanout 16 [get_designs nexus_soc_top]

compile_ultra -scan -no_autoungroup -gate_clock -retime

insert_mv_cells

compile_ultra -incremental

# ==========================================================================
# 7. DFT & SCAN CHAIN INSERTION
# ==========================================================================
# DELETE THIS LINE: create_port scan_en -direction in
set_dft_signal -view spec -type ScanEnable -port scan_en -active_state 1

set_dft_signal -view existing_dft -type ScanClock -port clk_master -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port rst_n -active_state 0

# Create 8 physical input/output ports for the 8 scan chains
for {set i 1} {$i <= 8} {incr i} {
    create_port scan_in_$i -direction in
    create_port scan_out_$i -direction out
    set_dft_signal -view spec -type ScanDataIn -port scan_in_$i
    set_dft_signal -view spec -type ScanDataOut -port scan_out_$i
}

set_dft_configuration -fix_reset enable -fix_clock enable
set_scan_configuration -chain_count 8 -clock_mixing mix_clocks

create_test_protocol
dft_drc
preview_dft
insert_dft

# ==========================================================================
# 8. RENAME & EXPORT DATA
# ==========================================================================
change_names -rules verilog -hierarchy

# --- A. SCANDEF ---
write_scan_def -output $dir_path/nexus_soc_top.scandef

# --- B. UPF ---
save_upf $dir_path/nexus_soc_top.upf

set file_name "$dir_path/nexus_soc_top.upf"
set in_file [open $file_name r]
set file_data [read $in_file]
close $in_file

regsub -all {\[([0-9]+)\]_UPF} $file_data {_\1_UPF} file_data

set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Nexus SoC Multi-Voltage Architecture"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "# VERSION     : 1.0 (Silicon-Ready)"
puts $out_file "# DATE        : [clock format [clock seconds] -format {%B %d, %Y}]"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- C. SDC (SINGLE EXPORT FOR WLM) ---
write_sdc $dir_path/nexus_soc_top_synth.sdc

set file_name "$dir_path/nexus_soc_top_synth.sdc"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Nexus SoC Multi-Voltage Architecture"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "# VERSION     : 1.0 (Mapped Timing Constraints)"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- D. NETLIST ---
write -format verilog -hierarchy -output $dir_path/nexus_soc_top_netlist_sfo.v
set file_name "$dir_path/nexus_soc_top_netlist_sfo.v"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "// =========================================================================="
puts $out_file "// PROJECT     : Nexus SoC Multi-Voltage Architecture"
puts $out_file "// AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "// VERSION     : 1.0 (Mapped Gate-Level Netlist)"
puts $out_file "// ==========================================================================\n"
puts $out_file $file_data
close $out_file