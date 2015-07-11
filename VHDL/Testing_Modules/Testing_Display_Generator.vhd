--------------------------------------------------------------------------------------------------------------------------
-- Title       : Display_Output_Test
-- Function:   : generates values to be sent to SSD_Driver
-- Comments    : Tested and Works
--------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity Testing_Display_Generator is
	port (
		-- clk      : in    std_logic;
		-- rst 	 : in    std_logic;
		Display : in STD_LOGIC_VECTOR (2 downto 0);  -- mux select signal for external display module
		Word : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number from Control to Display
		Result : in integer;  -- Result from sort and weight module
		SEG_0    : out    std_logic_vector(4 downto 0);
		SEG_1    : out    std_logic_vector(4 downto 0);
		SEG_2    : out    std_logic_vector(4 downto 0);
		SEG_3    : out    std_logic_vector(4 downto 0));
end Testing_Display_Generator;

architecture Behavioral of Testing_Display_Generator is

	-- Display Constants from Control.  Works as a select signal.
	CONSTANT Display_Sel_Width : integer :=3;  -- 3 bits allows for Off, 6 Messages and Display Word# in BCD
	CONSTANT Display_Off : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "000";  -- 0 = Display Off
	-- CONSTANT Display_Message_1 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "001";  -- 1 = Display Message 1	
	-- CONSTANT Display_Message_2 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "010";  -- 2 = Display Message 2	
	-- CONSTANT Display_Message_3 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "011";  -- 3 = Display Message 3
	-- CONSTANT Display_Message_4 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "100";  -- 4 = Display Message 4	
	-- CONSTANT Display_Message_5 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "101";  -- 5 = Display Message 5	
	CONSTANT Display_Result : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "110";  -- 6 = Display Word & Score/100 in BCD
	CONSTANT Display_Word : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "111";  -- 7 = Display Word in BCD
	
	-- BCD Conversion of Result
	signal BCD_Result : std_logic_vector(19 downto 0) :=(others=>'0');  -- Conversion of Result to BCD.  5 bits per BCD value.
	
	-- BCD Conversion signals
	signal BCD_Value : std_logic_vector(9 downto 0):=(others=>'0');  -- Conversion of Word Number to BCD.  5 bits per BCD value.
	signal input_int : integer;
	-- signal thous_int : integer;
	-- signal hund_int : integer;
	signal tens_int : integer;
	signal ones_int : integer;
	-- signal thous_hex : STD_LOGIC_VECTOR (4 downto 0);
	-- signal hund_hex : STD_LOGIC_VECTOR (4 downto 0);
	signal tens_hex : STD_LOGIC_VECTOR (4 downto 0):=(others=>'0');
	signal ones_hex : STD_LOGIC_VECTOR (4 downto 0):=(others=>'0');
	
	signal SSD_Code : STD_LOGIC_VECTOR (19 downto 0):=(others=>'0');

begin

	input_int <= Result when (Display = Display_Result) else TO_INTEGER(unsigned(Word));

-- Convert Word Number to BCD Value
--	input_int <= TO_INTEGER(unsigned(Word));
	-- thous_int <= input_int / 1000;
	-- hund_int <= (input_int mod 1000) / 100;
	tens_int <= (input_int mod 100) / 10;
	ones_int <= input_int mod 10;

	-- thous_hex <= STD_LOGIC_VECTOR(TO_UNSIGNED(thous_int, 5));
	-- hund_hex <= STD_LOGIC_VECTOR(TO_UNSIGNED(hund_int, 5));
	tens_hex <= STD_LOGIC_VECTOR(TO_UNSIGNED(tens_int, 5));
	ones_hex <= STD_LOGIC_VECTOR(TO_UNSIGNED(ones_int, 5));

	BCD_Value <= tens_hex & ones_hex;
	
---- Convert Result to BCD Value
--	BCD_Result <= "00000000010000000001"; -- Need to insert conversion.

	
-- Decode Display signal and send appropriate output to SSD Driver
	with Display select	 
		SSD_Code <= x"FFFFF" when Display_Off,  -- 7-Segs Off
					("1111111111" & BCD_Value) when Display_Word,  -- 7-Segs 3 & 2 -> off, 7-Segs 1 & 0 -> Word in BCD 
					("1111111111" & BCD_Value) when Display_Result,
					x"FFFFF" when others;
					
-- Assign Data for 7 Segs
	SEG_0 <= SSD_Code(4 downto 0);
	SEG_1 <= SSD_Code(9 downto 5);
	SEG_2 <= SSD_Code(14 downto 10);
	SEG_3 <= SSD_Code(19 downto 15);
				
-- x"C0" when "00000", -- 0
-- x"F9" when "00001", -- 1
-- x"A4" when "00010", -- 2
-- x"B0" when "00011", -- 3
-- x"99" when "00100", -- 4
-- x"92" when "00101", -- 5 or S
-- x"82" when "00110", -- 6
-- x"F8" when "00111", -- 7
-- x"80" when "01000", -- 8
-- x"90" when "01001", -- 9
-- x"88" when "01010", -- A
-- x"83" when "01011", -- b
-- x"C6" when "01100", -- c
-- x"A1" when "01101", -- d
-- x"86" when "01110", -- E
-- x"FB" when "01111", -- i
-- x"89" when "10000", -- H
-- x"C7" when "10001", -- L
-- x"AB" when "10010", -- n
-- x"A3" when "10011", -- o
-- x"8C" when "10100", -- P
-- x"87" when "10101", -- t
-- x"E3" when "10110", -- u
-- x"FF" when others; -- others

end Behavioral;