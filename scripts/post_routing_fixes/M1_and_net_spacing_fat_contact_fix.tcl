# 1. Unlock all standard logic cells so the legalizer is legally allowed to move them
set logic_cells [get_cells -hierarchical -filter "is_hard_macro == false && is_physical_only == false"]
set_attribute $logic_cells physical_status placed

# 2. Force the legalizer to nudge the congested cells out from under the VSS/VDD rails
legalize_placement -incremental

# 3. Fire the detail router to clean up the metal now that the pins are free
route_detail -incremental true -initial_drc_from_input true