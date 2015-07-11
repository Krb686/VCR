library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BIN2BCD is
    Port ( BIN : in  STD_LOGIC_VECTOR (15 downto 0);
           BCD : out  STD_LOGIC_VECTOR (15 downto 0));
end BIN2BCD;

architecture Behavioral of BIN2BCD is
	
	signal digit_out0 : STD_LOGIC_VECTOR(15 downto 0);
	signal digit_out1 : STD_LOGIC_VECTOR(15 downto 0);
	signal digit_out2 : STD_LOGIC_VECTOR(15 downto 0);
	signal digit_out3 : STD_LOGIC_VECTOR(15 downto 0);
	
begin

	digit_out0 <= STD_LOGIC_VECTOR(unsigned(BIN) / 1000);
	digit_out1 <= STD_LOGIC_VECTOR((unsigned(BIN) mod 1000) / 100);
	digit_out2 <= STD_LOGIC_VECTOR((unsigned(BIN) mod 100) / 10);
	digit_out3 <= STD_LOGIC_VECTOR((unsigned(BIN) mod 10));
	
	BCD <= digit_out0(3 downto 0) & digit_out1(3 downto 0) & digit_out2(3 downto 0) & digit_out3(3 downto 0);

end Behavioral;