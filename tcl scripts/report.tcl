# Load Quartus Prime Tcl Project package
package require ::quartus::project
package require ::quartus::report

# Name of the top level entity goes here
#set ENTITY_NAME "entity_name"

# Entity name is a command line argument
set ENTITY_NAME [lindex $argv 0]

# Creating project
project_open -revision $ENTITY_NAME $ENTITY_NAME

load_report

# Set panel name and id
set panel   {TimeQuest Timing Analyzer||Slow 1100mV 85C Model||Slow 1100mV 85C Model Fmax Summary}
set id      [get_report_panel_id $panel]

puts "Slow 1100mV 85C Model Fmax Summary\n"

# Get the number of rows
set row_cnt [get_number_of_rows -id $id]

for {set i 0} {$i < $row_cnt} {incr i} {
    puts [get_report_panel_row -row $i -id $id]
}

unload_report