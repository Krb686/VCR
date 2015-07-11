----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:26:19 03/29/2015 
-- Design Name: 
-- Module Name:    Match_Alg1_Mem - Behavioral 
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

entity Match_Alg1_Mem is
    Generic (Width : Integer :=8;  -- Width of Data
				 Mem_Add_Size : integer := 3;  -- LOG2(Number of Memory Locations)
				 N : Integer :=8);  -- Number of Memory Locations
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC; 
			  DATA_IN : in  STD_LOGIC_VECTOR(Width - 1 downto 0);
			  WRITE_ADD : in  STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0);
			  WRITE_EN : in  STD_LOGIC;
			  READ_ADD_1 : in  STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0);
			  READ_ADD_2 : in  STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0);
			  DATA_OUT_1 : out  STD_LOGIC_VECTOR(Width - 1 downto 0);
			  DATA_OUT_2 : out  STD_LOGIC_VECTOR(Width - 1 downto 0));
end Match_Alg1_Mem;

architecture Behavioral of Match_Alg1_Mem is

   type ram_type is array (0 to N-1) of std_logic_vector(Width-1 downto 0);
   signal RAM : ram_type := (others => (others => '0'));

begin

	RamProc: process(RST, CLK) is
	begin
		if RST = '1' then
			RAM <= (others => (others => '0'));
		elsif rising_edge(CLK) then
			if (WRITE_EN = '1') then
				RAM(to_integer(unsigned(WRITE_ADD))) <= DATA_IN;
			end if;
		end if;
	end process RamProc;
	
	DATA_OUT_1 <= ram(to_integer(unsigned(READ_ADD_1)));
	DATA_OUT_2 <= ram(to_integer(unsigned(READ_ADD_2)));

end Behavioral;

