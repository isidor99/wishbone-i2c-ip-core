# Load Quartus Prime Tcl Project package
package require ::quartus::project

# Name of the top level entity goes here
#set ENTITY_NAME "entity_name"

# Entity name is a command line argument
set ENTITY_NAME [lindex $argv 0]

# Creating project
project_new -revision $ENTITY_NAME $ENTITY_NAME

# Assign Family, EDA sim. and top-level entity 
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH ${ENTITY_NAME}_tb -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_NAME ${ENTITY_NAME}_tb -section_id eda_simulation
set_global_assignment -name EDA_DESIGN_INSTANCE_NAME NA -section_id ${ENTITY_NAME}_tb
set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME ${ENTITY_NAME}_tb -section_id ${ENTITY_NAME}_tb
set_global_assignment -name EDA_TEST_BENCH_FILE ${ENTITY_NAME}_tb.vhd -section_id ${ENTITY_NAME}_tb
set_global_assignment -name VHDL_FILE ${ENTITY_NAME}.vhd
set_global_assignment -name VHDL_FILE ${ENTITY_NAME}_tb.vhd
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
#Assign pins

	# Depends on your dising
	# Example:
	# set_location_assignment -to clk Pin_28
#
# Commit assignments
export_assignments
	 
project_close

	