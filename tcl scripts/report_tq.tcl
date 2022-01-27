# Load Quartus Prime Tcl Project package
package require ::quartus::project
package require ::quartus::sdc
package require ::quartus::sta


# Create Timing Netlist (Always First)
create_timing_netlist


# Read SDC and update timing
read_sdc
update_timing_netlist

# Returns number of clocks
report_clocks

# Prints all clocks
puts "Clocks:"
foreach_in_collection clk [all_clocks] {
	puts [get_clock_info -name $clk]
}

# Prints all registers
puts "Registers:"
foreach_in_collection reg [all_registers] {
    puts [get_register_info -name $reg]
}


# Get domain summary object
puts "Fmax:"
set domain_list [get_clock_fmax_info]
foreach domain $domain_list {
	set name [lindex $domain 0]
	set fmax [lindex $domain 1]
	set restricted_fmax [lindex $domain 2]

	puts "Clock $name : Fmax = $fmax (Restricted Fmax = $restricted_fmax)"
}


foreach_in_collection edge_slack [get_edge_slacks -setup] {
	# Each item in the collection is an {edge slack} pair
	set edge [lindex $edge_slack 0]
	set slack [lindex $edge_slack 1]

	set src_node [get_edge_info -src $edge]
	set dst_node [get_edge_info -dst $edge]

	post_message -type info "Found edge [get_node_info -name $src_node] -> [get_node_info -name $dst_node] with slack $slack"
}

delete_timing_netlist
