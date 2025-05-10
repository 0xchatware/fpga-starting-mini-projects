----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2025 11:58:18 PM
-- Design Name: 
-- Module Name: Clock_Enable_Generator - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clock_Enable_Generator is
  Generic (
    CLKS_PER_SEC : integer := 125000000; -- 10 for simulation
    DESIRED_CLKS_PER_SEC : integer := 1);
  Port (
    i_clk : in std_logic;
    o_clk_en : out std_logic);
end Clock_Enable_Generator;

architecture Behavioral of Clock_Enable_Generator is
    constant COUNTER_MAX_VALUE : integer := (CLKS_PER_SEC / DESIRED_CLKS_PER_SEC / 2) - 1;
    signal r_clk_en : std_logic := '0';
    signal r_counter : integer range 0 to COUNTER_MAX_VALUE := 0;
begin
    clock_enable: process (i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (r_counter < COUNTER_MAX_VALUE) then
                r_counter <= r_counter + 1;
            else
                r_counter <= 0;
                r_clk_en <= not r_clk_en;
            end if;
        end if;
    end process clock_enable;

    o_clk_en <= r_clk_en;
end Behavioral;
