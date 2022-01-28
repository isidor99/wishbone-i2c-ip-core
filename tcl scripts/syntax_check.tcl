
# ONLY RUN IF YOU HAVE Quartus Prime Pro Edition
# RUN COMMAND: quartus_syn -t syntax_check.tcl clock_generator

# Entity name is a command line argument
set ENTITY_NAME [lindex $argv 0]

# Get current directory path
set dir [pwd]

#  Assing files as variable of all files in the current dir.
set files [glob -directory $dir *.vhd]

# Project must be opend
project_open -revision $ENTITY_NAME $ENTITY_NAME

foreach file $files {
	post_message $file
	analyze_files -files $file
}

project_close


