----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2025 09:38:46 PM
-- Design Name: 
-- Module Name: Blinking_Led_1Hz - Behavioral
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

entity Blinking_Led is
  Generic (
    CLKS_PER_SEC : integer := 125000000;
    DESIRED_CLKS_PER_SEC : integer := 1);
  Port (
    i_clk: in std_logic;
    o_led: out std_logic);
end Blinking_Led;

architecture Behavioral of Blinking_Led is
    constant COUNTER_MAX_VALUE : integer := (CLKS_PER_SEC / DESIRED_CLKS_PER_SEC / 2) - 1;
    signal r_clock_en : std_logic := '0';
    signal r_counter : integer range 0 to COUNTER_MAX_VALUE := 0;
begin

    clock_enable: process (i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (r_counter < COUNTER_MAX_VALUE) then
                r_counter <= r_counter + 1;
            else
                r_counter <= 0;
                r_clock_en <= not r_clock_en;
            end if;
        end if;
    end process clock_enable;

    led_blink: process (i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (r_clock_en = '1') then
                o_led <= '1';
            else
                o_led <= '0';
            end if;
        end if;
    end process led_blink;

end Behavioral;
