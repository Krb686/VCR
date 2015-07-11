----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:34:45 03/06/2015 
-- Design Name: 
-- Module Name:    Var_Counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

entity Var_Counter is
    Generic ( Width : integer := 8);  -- Bit Width of Counter
	 Port ( CLK, RST, EN : in  STD_LOGIC;
           Count : out  STD_LOGIC_VECTOR (Width - 1 downto 0));
end Var_Counter;

architecture Behavioral of Var_Counter is

	signal Count_Sig : STD_LOGIC_VECTOR (Width - 1 downto 0):=(others=>'0');

begin
Process (RST, CLK)
	Begin
	if RST = '1' then
		Count_Sig <= (others => '0');
	elsif rising_edge(CLK) then
		if EN = '1' then
			Count_Sig <= STD_LOGIC_VECTOR(unsigned(Count_Sig) + 1);
		end if;
	end if;
end Process;

Count <= Count_Sig;
	
end Behavioral;

