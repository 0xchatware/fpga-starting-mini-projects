----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2025 06:24:09 PM
-- Design Name: 
-- Module Name: Binary_To_7Segment - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Binary_To_7Segment is
  Port (
    i_value : in std_logic_vector (3 downto 0);
    i_enable : in std_logic;
    o_segment_a : out std_logic;
    o_segment_b : out std_logic;
    o_segment_c : out std_logic;
    o_segment_d : out std_logic;
    o_segment_e : out std_logic;
    o_segment_f : out std_logic;
    o_segment_g : out std_logic);
end Binary_To_7Segment;
    
architecture Behavioral of Binary_To_7Segment is
    type t_data is array (0 to 15) of std_logic_vector (6 downto 0);
    
    constant DATA_REPRESENTATION : t_data := (7x"7e", 7x"30", 7x"6d", 7x"79", 7x"33", 
                                              7x"5b", 7x"5f", 7x"70", 7x"7f", 7x"7b",
                                              7x"77", 7x"1f", 7x"4e", 7x"3d", 7x"4f",
                                              7x"47");
    signal r_value : integer range 0 to 15;
begin
    r_value <= to_integer(unsigned(i_value));
    o_segment_a <= DATA_REPRESENTATION(r_value)(6) when i_enable = '1' else '0';
    o_segment_b <= DATA_REPRESENTATION(r_value)(5) when i_enable = '1' else '0';
    o_segment_c <= DATA_REPRESENTATION(r_value)(4) when i_enable = '1' else '0';
    o_segment_d <= DATA_REPRESENTATION(r_value)(3) when i_enable = '1' else '0';
    o_segment_e <= DATA_REPRESENTATION(r_value)(2) when i_enable = '1' else '0';
    o_segment_f <= DATA_REPRESENTATION(r_value)(1) when i_enable = '1' else '0';
    o_segment_g <= DATA_REPRESENTATION(r_value)(0) when i_enable = '1' else '0';
end Behavioral;
