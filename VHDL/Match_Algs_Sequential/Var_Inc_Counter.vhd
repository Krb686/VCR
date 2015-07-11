----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:31:50 04/03/2015 
-- Design Name: 
-- Module Name:    Var_Inc_Counter - Behavioral 
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

entity Var_Inc_Counter is
	 Generic ( Width : integer := 8);  -- Bit Width of Counter
	 Port ( CLK, RST : in  STD_LOGIC;
           OFFSET : in  STD_LOGIC_VECTOR (1 downto 0);
			  Count : out  STD_LOGIC_VECTOR (Width - 1 downto 0));
end Var_Inc_Counter;

architecture Behavioral of Var_Inc_Counter is

	signal Count_Sig : STD_LOGIC_VECTOR (Width - 1 downto 0):=(others=>'0');
	
	constant No_Offset : STD_LOGIC_VECTOR (1 downto 0):="00";
	constant Decriment2 : STD_LOGIC_VECTOR (1 downto 0):="01";
	constant Decriment1 : STD_LOGIC_VECTOR (1 downto 0):="10";
	constant Incriment2 : STD_LOGIC_VECTOR (1 downto 0):="11";

begin
Process (RST, CLK)
	Begin
	if RST = '1' then
		Count_Sig <= (others => '0');
	elsif rising_edge(CLK) then
		if OFFSET = Incriment2 then
			Count_Sig <= STD_LOGIC_VECTOR(unsigned(Count_Sig) + 2);
		elsif OFFSET = Decriment2 then
			Count_Sig <= STD_LOGIC_VECTOR(unsigned(Count_Sig) - 2);
		elsif OFFSET = Decriment1 then
			Count_Sig <= STD_LOGIC_VECTOR(unsigned(Count_Sig) - 1);
		else
			Count_Sig <= Count_Sig;
		end if;
	end if;
end Process;

Count <= Count_Sig;


end Behavioral;

