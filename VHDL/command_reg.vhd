----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    -- Module Name:    command_reg - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Stores command words associated with the control output.
--					 Command words correspond to external control signal output which is intended to be fed to an external microcontroller.
--					 Status output provides external acknowledgedment of systems current state to user.
--
-- Dependencies: Lots
--
-- Revision: 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;


entity command_reg is
    Port ( read_word_1 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 1 Requested word
           read_feature_1 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 1 Requested feature
			  read_word_2 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 2 Requested word
           read_feature_2 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 2 Requested feature
			  read_word_3 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Match Alg 3 Requested word
           read_feature_3 : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Match Alg 3 Requested feature
           write_word : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Location to be written to
			  write_feature : in  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Location to be written to
           write_data : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           write_en : in  STD_LOGIC;
           sys_clk : in  STD_LOGIC;
           data_out_1 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           data_out_2 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           data_out_3 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0)
	);
end command_reg;

architecture Behavioral of command_reg is

   type FEATURES is array (0 to Num_features - 1) of std_logic_vector(Sig_Value_Width - 1 downto 0);  -- Array of features.  42 Features in total per word, 21 Features from each algorithm
   type WORDS is array (0 to Total_Commands - 1) of FEATURES;  -- Array of words
   signal COMMANDS : WORDS := (others => (others => (others => '0')));
	signal read_word_1_sig, read_word_2_sig, read_word_3_sig, write_word_sig : integer;
	signal read_feature_1_sig, read_feature_2_sig, read_feature_3_sig, write_feature_sig : integer;

begin

	RamProc: process(sys_clk) is
	begin
		if rising_edge(sys_clk) then
			if (write_en = '1') then
				COMMANDS(write_word_sig)(write_feature_sig) <= write_data;
			end if;
		-- Read Data Assignments for Match Algorithms
			data_out_1 <= COMMANDS(read_word_1_sig)(read_feature_1_sig);  -- Command word features for Match Algorithm 1.
			data_out_2 <= COMMANDS(read_word_2_sig)(read_feature_2_sig);  -- Command word features for Match Algorithm 2.
			data_out_3 <= COMMANDS(read_word_3_sig)(read_feature_3_sig);  -- Command word features for Match Algorithm 3.
		end if;
	end process RamProc;
	
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

