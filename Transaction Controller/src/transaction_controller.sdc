## Generated SDC file "transaction_controller.sdc"

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

## DATE    "Thu Feb 03 17:09:23 2022"

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
create_clock -name {rst_i} -period 20 [get_ports {rst_i}]

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

set_input_delay -clock clk_virt -max 0.650 [get_ports {enbl_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {enbl_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {rep_strt_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {rep_strt_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {slv_addr_len_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {slv_addr_len_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {msl_sel_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {msl_sel_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {scl_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {scl_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {tx_buff_e_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {tx_buff_e_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {rx_buff_f_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {rx_buff_f_i}]

set_input_delay -clock clk_virt -max 0.650 [get_ports {i2c_start_i}]
set_input_delay -clock clk_virt -min 0.450 [get_ports {i2c_start_i}]
#
#set_input_delay -clock clk_virt -max 0.650 [get_ports {slv_addr_i[*]}]
#set_input_delay -clock clk_virt -min 0.450 [get_ports {slv_addr_i[*]}]
#
#set_input_delay -clock clk_virt -max 0.650 [get_ports {tx_data_i[*]}]
#set_input_delay -clock clk_virt -min 0.450 [get_ports {tx_data_i[*]}]

#set_input_delay -clock clk_virt -max 0.650 [get_ports {mode_i[*]}]
#set_input_delay -clock clk_virt -min 0.450 [get_ports {mode_i[*]}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_virt -max 0.550 [get_ports {tx_rd_enbl_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {tx_rd_enbl_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {rx_wr_enbl_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {rx_wr_enbl_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {busy_flg_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {busy_flg_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {ack_flg_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {ack_flg_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {clk_enbl_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {clk_enbl_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {arb_lost_flg_o}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {arb_lost_flg_o}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {rx_data_o[*]}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {rx_data_o[*]}]

set_output_delay -clock clk_virt -max 0.550 [get_ports {sda_b}]
set_output_delay -clock clk_virt -min 0.350 [get_ports {sda_b}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {rst_i}] -to [all_registers]
set_false_path -from [get_ports {sda_b}] -to [all_registers]
set_false_path -from [get_ports {sysclk_i[*]}] -to [all_registers]
set_false_path -from [get_ports {mode_i[*]}] -to [all_registers]
set_false_path -from [get_ports {byte_count_i[*]}] -to [all_registers]
set_false_path -from [get_ports {slv_addr_i[*]}] -to [all_registers]
set_false_path -from [get_ports {tx_data_i[*]}] -to [all_registers]
#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

