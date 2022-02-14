## Generated SDC file "wishbone_i2c_ip_core.sdc"

## Copyright (C) 2016  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"

## DATE    "Wed Feb 09 20:30:36 2022"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_i} -period 20 [get_ports {clk_i}]
create_clock -name clk_virt -period 20

#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock clk_virt -max 0.900 [get_ports {we_i}]
set_input_delay -clock clk_virt -min 0.700 [get_ports {we_i}]

set_input_delay -clock clk_virt -max 1.600 [get_ports {addr_i[*]}]
set_input_delay -clock clk_virt -min 1.400 [get_ports {addr_i[*]}]

set_input_delay -clock clk_virt -max 1.700 [get_ports {data_i[*]}]
set_input_delay -clock clk_virt -min 1.500 [get_ports {data_i[*]}]

set_input_delay -clock clk_virt -max 0.700 [get_ports {scl_b}]
set_input_delay -clock clk_virt -min 0.500 [get_ports {scl_b}]

set_input_delay -clock clk_virt -max 0.700 [get_ports {sda_b}]
set_input_delay -clock clk_virt -min 0.500 [get_ports {sda_b}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_virt -max 0.700 [get_ports {data_o[*]}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {data_o[*]}]

set_output_delay -clock clk_virt -max 0.700 [get_ports {ack_o}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {ack_o}]

set_output_delay -clock clk_virt -max 0.700 [get_ports {int_o}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {int_o}]

set_output_delay -clock clk_virt -max 0.700 [get_ports {scl_b}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {scl_b}]

set_output_delay -clock clk_virt -max 0.700 [get_ports {sda_b}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {sda_b}]

set_output_delay -clock clk_virt -max 0.700 [get_ports {gpo_o[*]}]
set_output_delay -clock clk_virt -min 0.500 [get_ports {gpo_o[*]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {rst_i}] -to [all_registers]
set_false_path -from [get_registers {register_block:reg_block|ram[2][*]}] -to [all_registers]
set_false_path -from [get_registers {register_block:reg_block|ram[7][*]}] -to [all_registers]

#**************************************************************
# Set Multicycle Path
#**************************************************************

#set_multicycle_path -from [get_registers {register_block:reg_block|ram[7][30]}] -to [get_registers {transaction_controller:tran_contr|count[3]}] -setup -end  2
#set_multicycle_path -from [get_registers {register_block:reg_block|ram[7][30]}] -to [get_registers {transaction_controller:tran_contr|count[3]}] -hold -end  2

#**************************************************************
# Set Maximum Delay
#**************************************************************

#set_max_delay -from [get_registers {register_block:reg_block|ram[7][30]}] -to [get_registers {transaction_controller:tran_contr|count[*]}] 30
#set_max_delay -from [get_registers {register_block:reg_block|ram[7][31]}] -to [get_registers {transaction_controller:tran_contr|count[*]}] 30

#**************************************************************
# Set Minimum Delay
#**************************************************************

#set_min_delay -from [get_registers {register_block:reg_block|ram[7][30]}] -to [get_registers {transaction_controller:tran_contr|count[4]}] 10


#**************************************************************
# Set Input Transition
#**************************************************************

