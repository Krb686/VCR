library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SSD_DRIVER is
	Generic ( k : integer := 21 );
    Port ( HEX0_IN : in  STD_LOGIC_VECTOR (3 downto 0);
           HEX1_IN : in  STD_LOGIC_VECTOR (3 downto 0);
           HEX2_IN : in  STD_LOGIC_VECTOR (3 downto 0);
           HEX3_IN : in  STD_LOGIC_VECTOR (3 downto 0);
           CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           SEG : out  STD_LOGIC_VECTOR (7 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0));
end SSD_DRIVER;

architecture Behavioral of SSD_DRIVER is

	signal counterVal	: STD_LOGIC_VECTOR(k-1 downto 0);
	signal selectSig 	: STD_LOGIC_VECTOR(1 downto 0);
	
	signal preOC		: STD_LOGIC_VECTOR(3 downto 0);
	
	signal muxOut		: STD_LOGIC_VECTOR(3 downto 0);
	
	signal numberSignal : STD_LOGIC_VECTOR(7 downto 0);
	
	--signal blinkState : STD_LOGIC;

begin

	upcount : PROCESS (CLK, RESET)
	BEGIN
		if(RESET = '1') then
			counterVal <=(others => '0');
		elsif(rising_edge(CLK)) then
			if(counterVal = "111111111111111111111") then
				counterVal <= "000000000000000000000";
			else
				counterVal <= STD_LOGIC_VECTOR(unsigned(counterVal) + 1);
			end if;
		end if;
	END PROCESS;
	
	selectSig <= counterVal(k-1 downto k-2);
	
	with selectSig select preOC <=
		"1000" when "00",
		"0100" when "01",
		"0010" when "10",
		"0001" when others;
		
		
	with selectSig select muxOut <=
		HEX3_IN when "00",
		HEX2_IN when "01",
		HEX1_IN when "10",
		HEX0_IN when others;
	
	AN <= not preOC;
	
	with muxOut select numberSignal <=
		x"C0" when x"0",				--0 = 11000000
		x"F9" when x"1",				--1 = 11111001
		x"A4" when x"2",				--2 = 10100100
		x"B0" when x"3",				--3 = 
		x"99" when x"4",
		x"92" when x"5",
		x"82" when x"6",
		x"F8" when x"7",
		x"80" when x"8",
		x"90" when x"9",
		x"88" when x"A",
		x"83" when x"B",
		x"C6" when x"C",
		x"A1" when x"D",
		x"86" when x"E",
		x"8E" when others;
		
		
	SEG <= numberSignal;

end Behavioral;
















