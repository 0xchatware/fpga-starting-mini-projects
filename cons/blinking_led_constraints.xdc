set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { i_sys_clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk -period 8.00 -waveform {0 4} [get_ports { i_sys_clk }];

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { o_led }]; #IO_L6N_T0_VREF_34 Sch=led[0]
set_false_path -to [get_ports {o_led}] -from [get_ports {i_sys_clk}];