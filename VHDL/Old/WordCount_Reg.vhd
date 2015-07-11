----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    WordCount_Reg - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Keeps track of word selection entered by user
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

entity WordCount_Reg is
    Port ( D : in integer;
           CLK : in  STD_LOGIC;
           SET : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           Q : out integer);
end WordCount_Reg;

architecture Behavioral of WordCount_Reg is

begin

-- State Register, Clocked Transitions
process (SET, CLK)
begin
	if (SET = '1') then
		Q <= 1;
	elsif rising_edge(CLK) then
		if (EN = '1') then
			Q <= D;
		end if;
	end if;
end process;


end Behavioral;

