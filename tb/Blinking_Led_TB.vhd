----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2025 10:11:08 PM
-- Design Name: 
-- Module Name: Blinking_Led_1Hz_TB - Behavioral
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

entity Blinking_Led_TB is
--  Port ();
end Blinking_Led_TB;

architecture Behavioral of Blinking_Led_TB is
    constant CLKS_PER_SEC : integer := 20;
    constant DESIRED_CLKS_PER_SEC : integer := 1;
    
    signal r_clk : std_logic := '0';
    signal r_led : std_logic := '0';
    
    component Blinking_Led
      Generic (
        CLKS_PER_SEC : integer := 125000000;
        DESIRED_CLKS_PER_SEC : integer := 1);
      Port (
        i_clk: in std_logic;
        o_led: out std_logic);
    end component Blinking_Led;
begin
    r_clk <= not r_clk after 1 ns;

    UUT : Blinking_Led
        generic map(
            CLKS_PER_SEC => CLKS_PER_SEC,
            DESIRED_CLKS_PER_SEC => DESIRED_CLKS_PER_SEC
        )
        port map(
            i_clk => r_clk,
            o_led => r_led
        );
end Behavioral;
