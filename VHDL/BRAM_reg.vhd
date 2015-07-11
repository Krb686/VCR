library ieee ; 
use ieee.std_logic_1164.all ; 
use ieee.numeric_std.all ; 

entity BRAM_reg is 
	generic (
		AW 		: INTEGER := 13; 	--address width
		DW 		: INTEGER := 8 	--data width
		);
	port ( 
		clk 	: in  std_logic;
		wen 	: in  std_logic;
		addr 	: in  std_logic_vector(AW-1 downto 0);
		d_in 	: in  std_logic_vector(DW-1 downto 0);
		d_out	: out std_logic_vector(DW-1 downto 0)
	) ; 
end entity ;

architecture behavioral of BRAM_reg is 
	type ram_t is array (0 to 2**AW - 1) of std_logic_vector(DW-1 downto 0);
	signal ram : ram_t := (others => (others => '0'));
begin 

PROCESS (clk)
begin
	if rising_edge(clk) then
		if (wen = '1') then
			ram(to_integer(unsigned(addr))) <= d_in;
		end if;
		d_out <= ram(to_integer(unsigned(addr)));
	end if;
	end process;
end behavioral ; 