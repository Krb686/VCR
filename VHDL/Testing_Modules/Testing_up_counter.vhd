-------------------------------------------------------------------------------
-- Title    : up_counter
-- Design   : lab3_demo
-- Function	: counting upwards
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity up_counter is
	generic ( SSD_Delay : integer );
	port (
		clk 	: in  std_logic;
		rst   	: in  std_logic;	
		init 	: in  std_logic;
		enable 	: in  std_logic;
		count   : out std_logic_vector(SSD_Delay-1 downto 0));
end up_counter;

architecture arch of up_counter is

	-- intermediate signals
	signal count_sig : std_logic_vector(SSD_Delay-1 downto 0) := (others => '0');
	
begin
		
	counting : process (rst, clk)
	begin
		if rst = '1' then
			count_sig <= (others => '0');
		elsif rising_edge (clk) then
			if init = '1' then
				count_sig <= (others => '0');
			elsif enable = '1' then
				count_sig <= count_sig + 1;
			end if;
		end if;
	end process;  
	
	count <= count_sig;

end arch;