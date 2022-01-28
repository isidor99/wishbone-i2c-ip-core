# Load Quartus Prime Tcl Project package
package require ::quartus::project
package require ::quartus::flow

# Name of the top level entity goes here
#set ENTITY_NAME "entity_name" 

# Entity name is a command line argument
set ENTITY_NAME [lindex $argv 0]

# Project must be opend
project_open -revision $ENTITY_NAME $ENTITY_NAME

# Running Quartus Analysis & Synthesis
execute_module -tool map

# Running Quartus Fitter
execute_module -tool fit

# Running Quartus Assembler
execute_module -tool asm 

# Running Quartus TimeQuest Timing Analyzer
execute_module -tool sta 

# Running Quartus EDA Netlist Writer
execute_module -tool eda

# Project must be closed at the end
project_close



