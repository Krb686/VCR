library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RED is
    Port ( input : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           output : out  STD_LOGIC);
end RED;

architecture Behavioral of RED is

	signal ff1Out : STD_LOGIC := '0';
	signal ff2Out : STD_LOGIC := '0';

begin
	
	RED : process(clk, reset)
	begin
		if(reset = '1') then
			ff1Out <= '0';
			ff2Out <= '0';
		elsif(rising_edge(clk)) then
			ff1Out <= input;
			ff2Out <= ff1Out;
		end if;
	end process;
	
	output <= input and not (ff1Out and ff2Out);
	
end Behavioral;

