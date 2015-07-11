library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.VCR_Package.ALL;


entity FAKE_COMMAND_REG is
				Port ( 	read_word_1 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 1 Requested word
							read_feature_1 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 1 Requested feature
							read_word_2 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 2 Requested word
							read_feature_2 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 2 Requested feature
							read_word_3 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 3 Requested word
							read_feature_3 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 3 Requested feature
							write_word : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Location to be written to
							write_feature : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Location to be written to
							write_data : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
							write_en : in  STD_LOGIC;
							clk : in  STD_LOGIC;
							rst : in STD_LOGIC;
							data_out_1 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
							data_out_2 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
							data_out_3 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0)
	);
end FAKE_COMMAND_REG;

architecture Behavioral of FAKE_COMMAND_REG is

	type FEATURES is array (0 to Num_features - 1) of std_logic_vector(Sig_Value_Width - 1 downto 0);
	type WORDS is array (0 to Total_Commands) of FEATURES;
	
	
	signal WORD_ROM_1	: FEATURES	:= (
		x"00160B3E", x"0004AB2B", x"00039018", x"0003E0F9",	-- UP 
		x"000565CF", x"00007440", x"00001AC4", x"000070E9",
		x"0000B717", x"0001F5AF", x"00000D7B", x"000176E3",
		x"000062A8", x"0000639D", x"00007019", x"0001C488",
		x"0001135B", x"00001D97", x"000039E5", x"000075FD"
	);
	
	
	signal WORD_ROM_2	: FEATURES	:= (
		x"00109481", x"00054920", x"00041E0A", x"0001AABC",	-- DOWN
		x"00008949", x"0001081B", x"0000A2A3", x"000003F9",
		x"0002CCD8", x"000010B6", x"0000D1F6", x"00011C5F",
		x"00021A50", x"0000059F", x"0000F877", x"000124F2",
		x"0000FD95", x"000052FD", x"0001A354", x"0001B90A"
	);
	
	signal WORD_ROM_3	: FEATURES	:= (
		x"000F6B79", x"000302CF", x"00058167", x"000113A1",	-- LEFT
		x"000422AD", x"0001ABBD", x"0000E55D", x"000139B8",
		x"00028642", x"00003E58", x"0000E050", x"00007768",
		x"0000367C", x"0000A01F", x"00007227", x"00000C8A",
		x"0000E6A9", x"00007D1C", x"00007280", x"00014CA1"
	);

	
	signal WORD_ROM_4	: FEATURES	:= (
		x"000EA378", x"00035C2F", x"000159CC", x"00014098",	-- RIGHT
		x"0002B185", x"00047E55", x"00024DA0", x"00009387",
		x"00010121", x"00012C4F", x"000034EE", x"00004752",
		x"00001625", x"00009AC0", x"0000DD14", x"00005757",
		x"00004363", x"00001D2D", x"000055A3", x"00000C66"
	);
	
	signal WORD_ROM_5	: FEATURES	:= (
		x"00000000", x"00000000", x"00000000", x"00000000",	-- not even used
		x"00000000", x"00000000", x"00000000", x"00000000",
		x"00000000", x"00000000", x"00000000", x"00000000",
		x"00000000", x"00000000", x"00000000", x"00000000",
		x"00000000", x"00000000", x"00000000", x"00000000"
	);
	
	
	signal COMMANDS : WORDS := (
		WORD_ROM_1, WORD_ROM_2, WORD_ROM_3, WORD_ROM_4, WORD_ROM_5
	);
	
	signal	read_word_1_sig		:	integer range 0 to Total_Commands-1;
	signal	read_word_2_sig		:	integer range 0 to Total_Commands-1;
	signal	read_word_3_sig		:	integer range 0 to Total_Commands-1;
	
	signal	read_feature_1_sig	:	integer range 0 to Num_Features-1;
	signal	read_feature_2_sig	:	integer range 0 to Num_Features-1;
	signal	read_feature_3_sig	:	integer range 0 to Num_Features-1;
	
	signal	write_word_sig			:	integer range 0 to Total_Commands-1;
	signal	write_feature_sig		:	integer range 0 to Num_Features-1;

begin
	process (clk)
	begin
		if(rst = '1') then
		
		elsif(rising_edge(clk)) then
			data_out_1 <= COMMANDS(read_word_1_sig)(read_feature_1_sig);  -- Command word features for Match Algorithm 1.
			data_out_2 <= COMMANDS(read_word_2_sig)(read_feature_2_sig);  -- Command word features for Match Algorithm 2.
			data_out_3 <= COMMANDS(read_word_3_sig)(read_feature_3_sig);  -- Command word features for Match Algorithm 3.
		end if;
	end process;
	
	-- Convert inputs to integers for indexing of arrays
	read_word_1_sig <= to_integer(unsigned(read_word_1));
	read_word_2_sig <= to_integer(unsigned(read_word_2));
	read_word_3_sig <= to_integer(unsigned(read_word_3));
	write_word_sig <= to_integer(unsigned(write_word));
	
	read_feature_1_sig <= to_integer(unsigned(read_feature_1));
	read_feature_2_sig <= to_integer(unsigned(read_feature_2));
	read_feature_3_sig <= to_integer(unsigned(read_feature_3));
	write_feature_sig <= to_integer(unsigned(write_feature));
	
end Behavioral;

