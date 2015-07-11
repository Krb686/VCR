----------------------------------------------------------------------------------
-- Company: GMU
-- Engineer: Jason Page
-- 
-- Create Date:    19:21:42 02/12/2015  
-- Design Name: 
-- Module Name:    RED - Behavioral  
-- Project Name:   Lab3
-- Target Devices: NEXYS 3
-- Revision: 1
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity RED_Test is
    Port ( input, clk, rst : in  STD_LOGIC;
           output : out  STD_LOGIC);
end RED_Test;

architecture Behavioral of RED_Test is

signal prev_input : STD_LOGIC;

begin

process (rst, clk)
begin
	if rst = '1' then
		prev_input <= '0';
	elsif rising_edge(clk) then 
      prev_input <= input;
   end if;
end process;

output <= not(prev_input) and input ;


end Behavioral;

