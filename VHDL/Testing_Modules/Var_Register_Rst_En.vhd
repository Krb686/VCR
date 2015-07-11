library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Var_Register_Rst_En is
    Generic ( Width : integer := 8 );  -- Defines Bit Width of Register
	 Port ( CLK, RST, EN : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (Width - 1 downto 0);
           Q : out  STD_LOGIC_VECTOR (Width - 1 downto 0));
end Var_Register_Rst_En;

architecture Behavioral of Var_Register_Rst_En is

begin

	Process (RST, CLK)
	Begin
		if ( RST = '1' ) then
			Q <= (others => '0');
		elsif rising_edge(CLK) then
			if ( EN = '1' ) then
				Q <= D;
			end if;
		end if;
	End Process;

end Behavioral;