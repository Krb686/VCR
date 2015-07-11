library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REG is
	 Generic(width : integer := 8);
    Port ( clk 	: in  STD_LOGIC;
           rst 	: in  STD_LOGIC;
           en 		: in  STD_LOGIC;
           din 	: in  STD_LOGIC_VECTOR (width - 1 downto 0);
           dout 	: out  STD_LOGIC_VECTOR (width - 1 downto 0));
end REG;

architecture Behavioral of REG is
begin
	
	process (rst, clk)
	begin
		if(rst = '1') then
			dout <= (others => '0');
		elsif(rising_edge(clk)) then
			if(en = '1') then
				dout <= din;
			end if;
		end if;
	end process;
	
end Behavioral;

