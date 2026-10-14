# ==========================================================================
# NEXUS_SOC_c_ff_125c.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
set TECH_LIB_NAME [file rootname [file tail $TECH_LIB]]
set_parasitic_parameters -library $TECH_LIB_NAME -early_spec maxTLU -late_spec maxTLU
set_temperature 125
set_process_number 0.99
set_process_label typical

set_voltage 0.85 -object_list [get_supply_nets VDD]
set_voltage 0.78 -object_list [get_supply_nets VDDL]
set_voltage 1.05 -object_list [get_supply_nets VDDH]
set_voltage 0.00 -object_list [get_supply_nets VSS]
set_timing_derate -early 0.93 -cell_delay -net_delay