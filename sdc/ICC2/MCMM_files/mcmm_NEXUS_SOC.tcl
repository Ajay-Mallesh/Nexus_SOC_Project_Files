# ==========================================================================
# Tool: IC Compiler II
# Script: mcmm_NEXUS_SOC.tcl
# AUTHOR         : [AJAYMALLESH]
# ==========================================================================
puts "RM-info : Running script [info script]\n"

# 1. ENVIRONMENT SETUP 
lappend search_path /home/ajaym/vg_10/projects/nexus_soc/inputs/mcmm_files \
                    /home/ajaym/vg_10/projects/nexus_soc/inputs/CLIBs
set TECH_LIB [which saed32_1p9m_tech.ndm]

# 2. CLEAR PREVIOUS CONSTRAINTS
remove_scenarios -all
remove_modes -all
remove_corners -all

set m_constr(func) "NEXUS_SOC_m_func.tcl"
set m_constr(test) "NEXUS_SOC_m_test.tcl"

set c_constr(ss_125c) "NEXUS_SOC_c_ss_125c.tcl"
set c_constr(ss_m40c) "NEXUS_SOC_c_ss_m40c.tcl"
set c_constr(ff_125c) "NEXUS_SOC_c_ff_125c.tcl"
set c_constr(ff_m40c) "NEXUS_SOC_c_ff_m40c.tcl"

set s_constr(func.ss_125c) "NEXUS_SOC_s_func.ss_125c.tcl"
set s_constr(func.ss_m40c) "NEXUS_SOC_s_func.ss_m40c.tcl"
set s_constr(func.ff_125c) "NEXUS_SOC_s_func.ff_125c.tcl"
set s_constr(func.ff_m40c) "NEXUS_SOC_s_func.ff_m40c.tcl"
set s_constr(test.ss_125c) "NEXUS_SOC_s_test.ss_125c.tcl"
set s_constr(test.ff_125c) "NEXUS_SOC_s_test.ff_125c.tcl"

foreach m [array names m_constr] { create_mode $m }
foreach c [array names c_constr] { create_corner $c }
foreach s [array names s_constr] { 
    lassign [split $s "."] m c
    create_scenario -name $s -mode $m -corner $c 
}

source NEXUS_SOC_port_lists.tcl
foreach m [array names m_constr] { current_mode $m; source $m_constr($m) }
foreach c [array names c_constr] { current_corner $c; source $c_constr($c) }
foreach s [array names s_constr] { current_scenario $s; source $s_constr($s) }

set_scenario_status {func.ss_125c func.ss_m40c test.ss_125c} -hold false
set_scenario_status {func.ff_125c func.ff_m40c test.ff_125c} -setup false

puts "RM-info : Completed script [info script]\n"