// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Thu Jul  3 14:14:42 2025
// Host        : LAPTOP-H2TG1BH8 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Projects/fpga_mini_project_starter/ip/clk_wiz_720p_0/clk_wiz_720p_0_stub.v
// Design      : clk_wiz_720p_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CORE_GENERATION_INFO = "clk_wiz_720p_0,clk_wiz_v6_0_16_0_0,{component_name=clk_wiz_720p_0,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=PLL,num_out_clk=2,clkin1_period=8.000,clkin2_period=10.000,use_power_down=false,use_reset=false,use_locked=true,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}" *) 
module clk_wiz_720p_0(o_clk_pxl, o_clk_pxl_5x, i_locked, i_clk)
/* synthesis syn_black_box black_box_pad_pin="i_locked,i_clk" */
/* synthesis syn_force_seq_prim="o_clk_pxl" */
/* synthesis syn_force_seq_prim="o_clk_pxl_5x" */;
  output o_clk_pxl /* synthesis syn_isclock = 1 */;
  output o_clk_pxl_5x /* synthesis syn_isclock = 1 */;
  output i_locked;
  input i_clk;
endmodule
