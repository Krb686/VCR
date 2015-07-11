----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    train_status_reg - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Status of results within training module
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

entity train_status_reg is
    Port ( D : in  STD_LOGIC_VECTOR (2 downto 0);
           CLK : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (2 downto 0));
end train_status_reg;

architecture Behavioral of train_status_reg is

begin

-- State Register, Clocked Transitions
process (CLK)
begin
	if rising_edge(CLK) then
		if (EN = '1') then
			Q <= D;
		end if;
	end if;
end process;


end Behavioral;



