# 1. Run an ECO routing pass to aggressively target and connect the open nets
route_eco -max_detail_route_iterations 5

# 2. Force the detail router to resolve the remaining short violations incrementally
route_detail -incremental true 

# 3. Verify the final count
check_routes