----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    counter_two_sec - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Used to Count to Two Seconds for states in train module
--
-- Dependencies: Lots
--
-- Revision: 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_two_sec is
    Port ( D : in integer;
           CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           Q : out integer);
end counter_two_sec;

architecture Behavioral of counter_two_sec is

begin

-- State Register, Clocked Transitions
process (RESET, CLK)
begin
	if (RESET = '1') then
		Q <= 0;
	elsif rising_edge(CLK) then
		if (EN = '1') then
			Q <= D;
		end if;
	end if;
end process;


end Behavioral;

