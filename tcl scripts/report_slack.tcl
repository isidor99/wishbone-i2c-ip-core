# Load Quartus Prime Tcl Project package
package require ::quartus::project
package require ::quartus::report

# Name of the top level entity goes here
#set ENTITY_NAME "entity_name"

# Entity name is a command line argument
set ENTITY_NAME [lindex $argv 0]

# Project must be opend
project_open -revision $ENTITY_NAME $ENTITY_NAME

load_report
puts "Worst-case slack for a design:\n"

set panel {TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary}
set num_cols [get_number_of_columns -name $panel]

for {set i 1} {$i < $num_cols} {incr i} {
	set slack [get_report_panel_data -name $panel \
	-row_name "Worst-case Slack" -col $i]
	
	set type [get_report_panel_data -name $panel -row 0 -col $i]
	puts "\tWorst-case $type: $slack"
}


unload_report


# Project must be closed at the end
project_close