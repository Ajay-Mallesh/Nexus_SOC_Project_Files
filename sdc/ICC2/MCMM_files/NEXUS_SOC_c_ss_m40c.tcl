# ==========================================================================
# NEXUS_SOC_c_ss_m40c.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
set TECH_LIB_NAME [file rootname [file tail $TECH_LIB]]
set_parasitic_parameters -library $TECH_LIB_NAME -early_spec minTLU -late_spec minTLU
set_temperature -40
set_process_number 1.01
set_process_label typical

set_voltage 0.85 -object_list [get_supply_nets VDD]
set_voltage 0.78 -object_list [get_supply_nets VDDL]
set_voltage 1.05 -object_list [get_supply_nets VDDH]
set_voltage 0.00 -object_list [get_supply_nets VSS]
set_timing_derate -late 1.05 -cell_delay -net_delay