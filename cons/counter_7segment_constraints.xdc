set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { i_sys_clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk -period 8.00 -waveform {0 4} [get_ports { i_sys_clk }];

# Pmod A

set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { o_segment_a }]; #IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { o_segment_b }]; #IO_L17N_T2_34 Sch=ja_n[1]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { o_segment_c }]; #IO_L7P_T1_34 Sch=ja_p[2]
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { o_segment_d }]; #IO_L7N_T1_34 Sch=ja_n[2]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { o_segment_e }]; #IO_L12P_T1_MRCC_34 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { o_segment_f }]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { o_segment_g }]; #IO_L22P_T3_34 Sch=ja_p[4]

set_false_path -to [get_ports {o_segment_a}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_b}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_c}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_d}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_e}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_f}] -from [get_ports {i_sys_clk}];
set_false_path -to [get_ports {o_segment_g}] -from [get_ports {i_sys_clk}];