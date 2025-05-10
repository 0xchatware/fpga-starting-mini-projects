----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2025 11:56:58 PM
-- Design Name: 
-- Module Name: Counter_7Segment - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Counter_7Segment is
  Port (
    i_sys_clk : in std_logic;
    o_segment_a : out std_logic;
    o_segment_b : out std_logic;
    o_segment_c : out std_logic;
    o_segment_d : out std_logic;
    o_segment_e : out std_logic;
    o_segment_f : out std_logic;
    o_segment_g : out std_logic);
end Counter_7Segment;

architecture Behavioral of Counter_7Segment is

    signal r_clk_en_7segment : std_logic;
    signal r_clk_en_7segment_re : std_logic := '0';
    signal r_value_7segment : std_logic_vector (3 downto 0) := (others => '0');

    component Clock_Enable_Generator is
      Generic (
        CLKS_PER_SEC : integer := 125000000; -- 10 for simulation
        DESIRED_CLKS_PER_SEC : integer := 1);
      Port (
        i_clk : in std_logic;
        o_clk_en : out std_logic);
    end component Clock_Enable_Generator;
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

    Clock_Generator_Inst : Clock_Enable_Generator
        port map (
            i_clk => i_sys_clk,
            o_clk_en => r_clk_en_7segment);
            
    Segment_Inst : Binary_To_7Segment
        port map (
            i_value => r_value_7segment,
            i_enable => '1',
            o_segment_a => o_segment_a,
            o_segment_b => o_segment_b,
            o_segment_c => o_segment_c,
            o_segment_d => o_segment_d,
            o_segment_e => o_segment_e,
            o_segment_f => o_segment_f,
            o_segment_g => o_segment_g);
            
     current_value : process (i_sys_clk)
        begin
            if (rising_edge(i_sys_clk)) then
                r_clk_en_7segment_re <= r_clk_en_7segment;
                if (r_clk_en_7segment_re /= r_clk_en_7segment and r_clk_en_7segment_re = '0') then
                    r_value_7segment <= std_logic_vector(unsigned(r_value_7segment) + 1);
                end if;
            end if;
        end process current_value;

end Behavioral;
