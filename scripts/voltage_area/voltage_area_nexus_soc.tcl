################################################################################
# Author  : Gingeeyy
# Date    : July 6, 2026
# Version : 1.0
# Description : Floorplanning automation script to calculate cell areas, determine
#               utilization bounds, and create legal snapped voltage areas.
################################################################################

################################################################################
# POWER DOMAIN: PD_HIGH
################################################################################

# Remove any existing voltage areas before redefining them
remove_voltage_area -all
set sum 0

# Loop through all flat cells belonging to the 'PD_HIGH' power domain and sum up their areas
foreach area [get_attribute [get_flat_cells -filter "power_domain==PD_HIGH"] area] {
    set sum [expr $area + $sum]
}
puts "total area is : $sum"

# Define target utilization (75%)
set util 0.75

# Calculate required target voltage area based on utilization
set voltage_area [expr $sum / $util]
puts "Total area of PD_HIGH with 0.75 % util is : $voltage_area"

# Set desired height and snap it to the row/site grid (using site height/step multipliers)
set height 320
set h [expr {ceil($height / 1.672) * 1.672 + 1.672}]

# Calculate raw width and snap it to the horizontal site grid (e.g., 0.152um pitch)
set width [expr $voltage_area / $height]
set width [expr $width + 50]
set w [expr {ceil($width / 0.152) * 0.152}]
puts "Width: $width"

# Define Lower-Left X (llx) and Lower-Left Y (lly) placement coordinates
set llx 10.016
set lly [expr 10.016 + 1.672]

# Calculate Upper-Right coordinates (urx, ury) by adding calculated dimensions
set urx [expr $llx + $w]
set ury [expr $lly + $h]

puts "urx : $urx"
puts "ury : $ury"

# Structure the bounding box list for the region
set coordinates [list [list $llx $lly] [list $urx $ury]]

# Create the physical voltage area with a 5.016um guard band for PD_HIGH
create_voltage_area -region $coordinates -guard_band {{5.016 5.016}} -power_domains PD_HIGH


################################################################################
# POWER DOMAIN: PD_LOW
################################################################################

set sum_lp 0

# Loop through all flat cells belonging to the 'PD_LP' power domain and sum up their areas
foreach area_lp [get_attribute [get_flat_cells -filter "power_domain==PD_LP"] area] {
    set sum_lp [expr $area_lp + $sum_lp]
}
puts "total area is : $sum_lp"

# Define target utilization (75%) for low power domain
set util_lp 0.75

# Calculate required target voltage area for PD_LOW
set voltage_area_lp [expr $sum_lp / $util_lp]
puts "Total area of PD_LOW with 0.75 % util is : $voltage_area_lp"

# Set desired height and snap it to the row grid lines
set height_lp 316
set h_lp [expr {ceil($height_lp / 1.672) * 1.672 + 1.672}]

# Calculate raw width and snap it to the standard cell site pitch
set width_lp [expr $voltage_area_lp / $height_lp]
set w_lp [expr {ceil($width_lp / 0.152) * 0.152}]
puts "Width LP: $width_lp"

# Define coordinates with specific floorplan offsets for PD_LOW placement
set llx_lp [expr 640 + 19.056]
set lly_lp [expr 500 + 1166.968]

# Calculate Upper-Right coordinates (urx_lp, ury_lp)
set urx_lp [expr $llx_lp + $w_lp]
set ury_lp [expr $lly_lp + $h_lp]

puts "urx_lp : $urx_lp"
puts "ury_lp : $ury_lp"

# Structure the bounding box list for the region
set coordinates_lp [list [list $llx_lp $lly_lp] [list $urx_lp $ury_lp]]

# Create the physical voltage area with a 5.016um guard band for PD_LOW
create_voltage_area -region $coordinates_lp -guard_band {{5.016 5.016}} -power_domains PD_LP