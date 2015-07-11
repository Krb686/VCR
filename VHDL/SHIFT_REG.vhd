library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SHIFT_REG is
    Generic (reg_length : integer := 12);
    Port ( clk 			: in  STD_LOGIC;
           rst 			: in  STD_LOGIC;
           en 				: in  STD_LOGIC;
           load 			: in  STD_LOGIC;
			  dir				: in  STD_LOGIC;
           shift_in 		: in  STD_LOGIC;
			  parallel_in 	: in  STD_LOGIC_VECTOR (reg_length - 1 downto 0);
           shift_out 	: out STD_LOGIC;
           parallel_out : out STD_LOGIC_VECTOR (reg_length - 1 downto 0));
end SHIFT_REG;

architecture Behavioral of SHIFT_REG is

	signal internalReg : STD_LOGIC_VECTOR(reg_length - 1 downto 0);

begin
 
	parallel_out 	<= internalReg;
	shift_out 		<= internalReg(0);

	process (rst, clk)
	begin
		if(rst = '1') then
			internalReg <= (others => '0');
		elsif(rising_edge(clk)) then
			if(load = '1') then
				internalReg <= parallel_in;
			elsif(en = '1') then
				-- Shift right
				if(dir = '0') then
					internalReg <= shift_in & internalReg(reg_length - 1 downto 1);
				-- Shift left
				elsif(dir = '1') then
					internalReg <= internalReg(reg_length - 2 downto 0) & shift_in;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

