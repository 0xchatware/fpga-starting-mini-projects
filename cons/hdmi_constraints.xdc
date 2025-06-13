set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { i_sys_clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk

set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_clk_n }]; #IO_L11N_T1_SRCC_35 Sch=hdmi_tx_clk_n
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_clk_p }]; #IO_L11P_T1_SRCC_35 Sch=hdmi_tx_clk_p
set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=hdmi_tx_d_n[0]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=hdmi_tx_d_p[0]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=hdmi_tx_d_n[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=hdmi_tx_d_p[1]
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=hdmi_tx_d_n[2]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { o_hdmi_tx_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=hdmi_tx_d_p[2]

set_clock_groups -asynchronous \
  -group [list \
     [get_clocks -of_objects [get_pins Clk_Generator_Inst/o_clk_25MHz]] \
     [get_clocks -of_objects [get_pins Clk_Generator_Inst/o_clk_125MHz]]] \
  -group [get_clocks -of_objects [ get_pins Clk_Generator_Inst/i_clk]];
  

#  Rising Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#  
# forwarded         ____                      ___________________ 
# clock                 |____________________|                   |____________ 
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

set fwclk        [filter [get_clocks -of_objects [get_cells TMDS_Red_Serializer]] {name =~ *_25*}];     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu          0.630;            # destination device setup time requirement
set thd          0.030;            # destination device hold time requirement
set trce_dly_max 1.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_hdmi_*};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

# Report Timing Template
# report_timing -to [get_ports $output_ports] -max_paths 20 -nworst 1 -delay_type min_max -name src_sync_pos_out -file src_sync_pos_out.txt;
