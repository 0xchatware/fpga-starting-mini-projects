-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
-- Date        : Thu Jul  3 14:14:42 2025
-- Host        : LAPTOP-H2TG1BH8 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Projects/fpga_mini_project_starter/ip/clk_wiz_720p_0/clk_wiz_720p_0_stub.vhdl
-- Design      : clk_wiz_720p_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_720p_0 is
  Port ( 
    o_clk_pxl : out STD_LOGIC;
    o_clk_pxl_5x : out STD_LOGIC;
    i_locked : out STD_LOGIC;
    i_clk : in STD_LOGIC
  );

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of clk_wiz_720p_0 : entity is "clk_wiz_720p_0,clk_wiz_v6_0_16_0_0,{component_name=clk_wiz_720p_0,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=PLL,num_out_clk=2,clkin1_period=8.000,clkin2_period=10.000,use_power_down=false,use_reset=false,use_locked=true,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}";
end clk_wiz_720p_0;

architecture stub of clk_wiz_720p_0 is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "o_clk_pxl,o_clk_pxl_5x,i_locked,i_clk";
begin
end;
