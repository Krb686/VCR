library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DEBOUNCER is
	--Generic ( counter_width : integer := 21 );
    Port ( input : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           output : out  STD_LOGIC);
end DEBOUNCER;

architecture Behavioral of DEBOUNCER is

	signal previous_input 	: STD_LOGIC;
	signal x1 					: STD_LOGIC;
	signal x2					: STD_LOGIC;
	signal countEn 			: STD_LOGIC;
	signal counterOut			: STD_LOGIC_VECTOR(20 downto 0);
	signal ddOut				: STD_LOGIC;
	signal rstSig				: STD_LOGIC;
	signal muxOut				: STD_LOGIC;
	signal outSig 				: STD_LOGIC;
	signal setSig				: STD_LOGIC;
	
	signal ff1 : STD_LOGIC;
	signal ff2 : STD_LOGIC;
	signal ff3 : STD_LOGIC;
	
	signal oneConst : STD_LOGIC_VECTOR(0 downto 0) := "1";

begin

	FF1_PROC : PROCESS(clk)
	BEGIN
		if rising_edge(clk) then
			ff1 <= input;
		end if;
	END PROCESS;
	
	FF2_PROC : PROCESS(clk)
	BEGIN
		if(rising_edge(clk)) then
			ff2 <= muxOut;
		end if;
	END PROCESS;	

	FF3_PROC : PROCESS(clk, rstSig)
	BEGIN
		if(rstSig = '1') then
			ff3 <= '0';
		else 
			if(rising_edge(clk)) then
				if(setSig = '1') then
					ff3 <= '1';
				else
					ff3 <= countEn;
				end if;
			end if;	
		end if;
	END PROCESS;
	
	COUNTER_PROC : PROCESS(clk, rstSig)
	BEGIN
		if(rstSig = '1') then
			counterOut <= (others => '0');
		else
			if(rising_edge(clk))then
				if(countEn = '1') then
					if(counterOut = '1' & x"FFFFF") then
						counterOut <= '0' & x"00000";
					else
						counterOut <= STD_LOGIC_VECTOR(unsigned(counterOut) +1);
					end if;
				end if;
				
				
			end if;
		end if;
	END PROCESS;
	
	previous_input <= ff1;
	
	x1 <= previous_input XOR input;
	
	setSig <= x1 and not countEn;
	
	with countEn select muxOut <=
		input when '0',
		outSig when others;
		
	outSig <= ff2;
	output <= ff2;
	
	countEn <= ff3;
	
	with counterOut select ddOut <=
		'1' when '0' & x"B71B0",
		'0' when others;
	
	rstSig <= reset OR ddOut;
end Behavioral;