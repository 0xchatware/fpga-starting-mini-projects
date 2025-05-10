----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2025 11:09:10 PM
-- Design Name: 
-- Module Name: Binary_To_7Segment_TB - Behavioral
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
use STD.ENV.FINISH;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Binary_To_7Segment_TB is
--  Port ( );
end Binary_To_7Segment_TB;

architecture Behavioral of Binary_To_7Segment_TB is
    constant CLOCK_PERIOD : time := 10 ns; 

    signal r_clk_tb : std_logic := '0';
    signal r_segment_a, r_segment_b, r_segment_c, 
           r_segment_d, r_segment_e, r_segment_f, r_segment_g : std_logic := '0';
    signal r_value : std_logic_vector (3 downto 0) := "0000";

    component Binary_To_7Segment is
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
    end component Binary_To_7Segment;
begin
    r_clk_tb <= not r_clk_tb after CLOCK_PERIOD/2;
    
    UUT: Binary_To_7Segment
        port map (
            i_value => r_value,
            i_enable => '1',
            o_segment_a => r_segment_a,
            o_segment_b => r_segment_b,
            o_segment_c => r_segment_c,
            o_segment_d => r_segment_d,
            o_segment_e => r_segment_e,
            o_segment_f => r_segment_f,
            o_segment_g => r_segment_g);
            
    Test: process
      variable v_counter : integer range 0 to 15 := 0;
      begin
        for v_counter in 0 to 15 loop
            r_value <= std_logic_vector(to_unsigned(v_counter, r_value'length));
            wait for CLOCK_PERIOD * 2;
        end loop;
        finish;
    end process Test;

end Behavioral;
