set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { i_sys_clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { i_sw[0] }]; #IO_L7N_T1_AD2N_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { i_sw[1] }]; #IO_L7P_T1_AD2P_35 Sch=sw[1]

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
     [get_clocks -of_objects [get_pins Clk_Generator_Inst/o_clk_pxl]] \
     [get_clocks -of_objects [get_pins Clk_Generator_Inst/o_clk_pxl_5x]]] \
  -group [get_clocks -of_objects [ get_pins Clk_Generator_Inst/i_clk]];

set fwclk        [filter [get_clocks -of_objects [get_cells TMDS_Red_Serializer]] {name =~ *5x*}];     # forwarded clock name (generated using create_generated_clock at output clock port)        
set output_ports  {o_hdmi_tx_*};   # list of output ports
set_output_delay -clock $fwclk -max 1.6 [get_ports $output_ports];
set_output_delay -clock $fwclk -min 0.5 [get_ports $output_ports];

set_false_path -from $fwclk -to [get_ports $output_ports];
set_false_path -from [get_ports i_sw[*]];

