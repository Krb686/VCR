----------------------------------------------------------------------------------
-- Company: GMU
-- Engineer: Jason Page
-- 
-- Create Date:    12:59:26 02/15/2015 
-- Module Name:    Counter - Behavioral 
-- Project Name: Lab3
-- Target Devices: NEXYS 3
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity Counter_Test is
	generic ( n : integer);
	Port ( rst, clk, en : in  STD_LOGIC;
          Q : out  STD_LOGIC_VECTOR (n-1 downto 0));
end Counter_Test;

architecture Behavioral of Counter_Test is

	signal current_count : std_logic_vector(n-1 downto 0);

begin
-- Counter
process (clk, rst)
	begin	
		if rst = '1' then
			current_count <= (others => '0');
		elsif rising_edge (clk) then
			if en = '1' then
				current_count <= current_count + 1;
			end if;
		end if;
end process;  
	
	Q <= current_count;

end Behavioral;

