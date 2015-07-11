----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:34:55 04/04/2015 
-- Design Name: 
-- Module Name:    Test_Module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity Test_Module is
    Port (	CLK 			: in 	STD_LOGIC;
				Start 		: in 	STD_LOGIC;
				Start_sim	: in 	STD_LOGIC;
				RST 			: in  STD_LOGIC;
				Rst_sim		: in	STD_LOGIC;
				threshold_up	: in STD_LOGIC;
				threshold_down : in STD_LOGIC;
				uart_ctl	: in STD_LOGIC_VECTOR(1 downto 0);
				mic_sel	: in STD_LOGIC;
			  
				-- ADC signals
				pmod_sdata	: in STD_LOGIC;
				pmod_ncs		: out STD_LOGIC;
				pmod_sclk	: out STD_LOGIC;
				mcp_sdata	: in STD_LOGIC;
				mcp_ncs		: out STD_LOGIC;
				mcp_sclk		: out STD_LOGIC;
				
				-- UART
				uart_tx					: out STD_LOGIC;
				debug_led_dout			: out STD_LOGIC_VECTOR(7 downto 0);
				debug_sclk				: out STD_LOGIC;
				debug_clk_781			: out STD_LOGIC;
				debug_sample_loaded	: out STD_LOGIC;
				debug_uart_tx			: out STD_LOGIC;
				debug_seg				: out STD_LOGIC_VECTOR(7 downto 0);
				debug_an					: out STD_LOGIC_VECTOR(3 downto 0);
				
			  

				Alg1_Feature_Request : out STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);
				Alg1_Word_Request 	: out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				Alg2_Feature_Request : out STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);
				Alg2_Word_Request 	: out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				Alg3_Feature_Request : out STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);
				Alg3_Word_Request 	: out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				Top_Word 				: out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				Confidence 				: out STD_LOGIC_VECTOR (score_width - 1 downto 0)
           );
end Test_Module;

architecture Behavioral of Test_Module is

	constant KNOWN_CMDS : integer := 2;

-- Speech detector signals
	signal bram_read_addr 	: STD_LOGIC_VECTOR(12 downto 0);
	signal bram_sample_out	: STD_LOGIC_VECTOR(7 downto 0);
	signal lpc_en				: STD_LOGIC;
	signal sample_reg_cntl	: STD_LOGIC;
	
-- LPC signals
	signal extract_1_all_complete_sig : STD_LOGIC;
	
	signal match_algorithms_start_sig : STD_LOGIC;

-- signals from match algorithm 1
	signal alg_1_feature_request_sig : STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);  -- Bus between Match algorithm 1 and signature register and Address_concat_1 with requested feature number
	signal alg_1_word_request_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 1 and score register 1 and Address_concat_1 (output of Address_concat_1 goes to command register)
	signal match_alg_1_done_sig : STD_LOGIC;  -- Wire between match algorithm 1 and score register 1
	signal match_alg_1_score_sig : STD_LOGIC_VECTOR (Score_width - 1 downto 0);  -- Bus between Match algorithm 1 and sort with match score
	signal alg_1_match_word_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 1 and sort, '1' for Clk Cycle when a new score is ready.

-- signals from match algorithm 2
	signal alg_2_feature_request_sig : STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);  -- Bus between Match algorithm 2 and signature register and Address_concat_2  with requested feature number
	signal alg_2_word_request_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 2 and score register 2 and Address_concat_2 (output of Address_concat_2 goes to command register)
	signal match_alg_2_done_sig : STD_LOGIC;  -- Wire between match algorithm 1 and score register 2
	signal match_alg_2_score_sig : STD_LOGIC_VECTOR (Score_width - 1 downto 0);  -- Bus between Match algorithm 2 and sort with match score
	signal alg_2_match_word_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 2 and sort, '1' for Clk Cycle when a new score is ready.

-- signals from match algorithm 3
	signal alg_3_feature_request_sig : STD_LOGIC_VECTOR (Feature_Add_Width -1 downto 0);  -- Bus between Match algorithm 3 and signature register and Address_concat_3  with requested feature number
	signal alg_3_word_request_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 3 and score register 3 and Address_concat_3 (output of Address_concat_3 goes to command register)
	signal match_alg_3_done_sig : STD_LOGIC;  -- Wire between match algorithm 1 and score register 3
	signal match_alg_3_score_sig : STD_LOGIC_VECTOR (Score_width - 1 downto 0);  -- Bus between Match algorithm 3 and sort with match score
	signal alg_3_match_word_sig : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Bus between Match algorithm 3 and sort, '1' for Clk Cycle when a new score is ready.
	
-- Done Signal for Sort Weight Rank
	signal sort_weight_START : STD_LOGIC_VECTOR (2 downto 0);  -- concatenation of done flags for each match alg. START <= DONE( 1 & 2 & 3 )
	signal sort_weight_start_flag	: STD_LOGIC;
	signal sort_weight_done_flag	: STD_LOGIC;

-- signals that control the final register output
	signal Final_results_rank_request : INTEGER := 0; 	--request address (rank) from the final sort register. Address 0 will be the best composite match
	signal final_results_word_and_score			: STD_LOGIC_VECTOR(Command_Reg_Add_Width + Score_width-1 downto 0);
	signal Final_results_word_and_score_int	: integer;

-- signals from sig_ext_1
	signal alg_1_signature_sig: STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
	signal alg_2_signature_sig:STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
	signal alg_3_signature_sig:STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
--	signal alg_4_signature_sig:STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
	signal Operand:unsigned (7 downto 0):=(others=>'0');
	signal  InputDataMemoryADR: std_logic_vector(25 downto 0);
	
	
	signal alg_1_word_sig	:	STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
	signal alg_2_word_sig	:	STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
	signal alg_3_word_sig	:	STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
--	signal alg_4_word_sig	:	STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);



	signal final_result_addr	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width + 1 downto 0)	:= (others => '0');
	signal final_result_score	:	STD_LOGIC_VECTOR(Score_width - 1 downto 0);
	signal final_result_word	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);

begin

	--final_results_word_and_score <= STD_LOGIC_VECTOR(to_unsigned(final_results_word_and_score_int, Command_Reg_Add_Width + Score_width));
	
	Top_Word 	<= final_result_word;
	Confidence 	<= final_result_score;

	

	SPEECH_DETECTOR_1: entity work.speech_detector PORT MAP(
		clk 						=> CLK,
		rst 						=> rst,
		rst_sim					=> Rst_sim,
		start 					=> Start,
		start_sim				=> Start_sim,
		t_up 						=> threshold_up,
		t_down 					=> threshold_down,
		uart_ctl 				=> uart_ctl,
		pmod_sdata 				=> pmod_sdata,
		pmod_ncs 				=> pmod_ncs,
		pmod_sclk 				=> pmod_sclk,
		bram_read_addr 		=> bram_read_addr,
		bram_sample_out 		=> bram_sample_out,
		lpc_en 					=> lpc_en,
		uart_tx 					=> uart_tx,
		debug_SCLK 				=> debug_sclk,
		debug_CLK_781 			=> debug_clk_781,
		debug_sampleLoaded 	=> debug_sample_loaded,
		debug_UART_TX 			=> debug_uart_tx
	);
								

	 SIG_EXT_1			:	entity work.signature_extract_1(Behavioral) --signature_extract_1
									 PORT MAP( 
										 rst						=> rst_sim,
										 start_calc_flag		=> lpc_en,
										 all_complete_flag	=> match_algorithms_start_sig,
								  		 lpc_addr_0 			=> alg_1_feature_request_sig,
										 lpc_addr_1 			=> alg_2_feature_request_sig,
										 lpc_addr_2 			=> alg_3_feature_request_sig,
										 lpc_addr_3				=> alg_3_feature_request_sig,
										 lpc_out_0 				=> alg_1_signature_sig,
										 lpc_out_1 				=> alg_2_signature_sig,
										 lpc_out_2 				=> alg_3_signature_sig,
--										 lpc_out_3				=> alg_4_signature_sig,
										 sample_clock			=> CLK,
										 InputDataMemoryADR 	=> bram_read_addr,		
										 Operand 				=> unsigned(bram_sample_out)
									 );
									 

									 
--	 COMMAND_REG_1: entity work.command_reg PORT MAP(
--										read_word_1 			=> alg_1_word_request_sig,
--										read_feature_1 		=> alg_1_feature_request_sig,
--										read_word_2 			=> alg_2_word_request_sig,
--										read_feature_2 		=> alg_2_feature_request_sig,
--										read_word_3 			=> alg_3_word_request_sig,
--										read_feature_3 		=> alg_3_feature_request_sig,
--										write_word 				=> "0000000",
--										write_feature 			=> "00000",
--										write_data 				=> x"00000000",
--										write_en 				=> '0',
--										sys_clk 					=> CLK,
--										data_out_1 				=> alg_1_signature_sig,
--										data_out_2 				=> alg_2_signature_sig,
--										data_out_3 				=> alg_3_signature_sig
--		);
		
	FAKE_COMMAND_REG_1: entity work.FAKE_COMMAND_REG PORT MAP(
										read_word_1 			=> alg_1_word_request_sig,
										read_feature_1 		=> alg_1_feature_request_sig,
										read_word_2 			=> alg_2_word_request_sig,
										read_feature_2 		=> alg_2_feature_request_sig,
										read_word_3 			=> alg_3_word_request_sig,
										read_feature_3 		=> alg_3_feature_request_sig,
										write_word 				=> "0000000",
										write_feature 			=> "00000",
										write_data 				=> x"00000000",
										write_en 				=> '0',
										clk 						=> CLK,
										rst						=> rst,
										data_out_1 				=> alg_1_word_sig,
										data_out_2 				=> alg_2_word_sig,
										data_out_3 				=> alg_3_word_sig
	);
									 
	 MATCH_ALG_1			:	entity work.Match_Alg1(Behavioral) --Match_Algorithm_1, Computes Variance/Covariance
									 Port MAP(
										 CLK						=> CLK,
										 signature_feature	=> alg_1_signature_sig,
										 word_feature			=> alg_1_word_sig,
										 start_signal			=> match_algorithms_start_sig,
										 feature_request		=> alg_1_feature_request_sig,
										 word_request			=> alg_1_word_request_sig,
										 done						=> match_alg_1_done_sig,
										 match_score			=>	match_alg_1_score_sig,
										 match_word				=>	alg_1_match_word_sig
									 );
									
	 MATCH_ALG_2			:	entity work.Match_Alg2(Behavioral) -- Match_Algorithm_2, Computes Euclidean Distance
									 Port MAP(
										 CLK						=> CLK,
										 signature_feature	=> alg_2_signature_sig,
										 word_feature			=> alg_2_word_sig,
										 start_signal			=> match_algorithms_start_sig,
										 feature_request		=> alg_2_feature_request_sig,
										 word_request			=> alg_2_word_request_sig,
										 done						=> match_alg_2_done_sig,
										 match_score			=>	match_alg_2_score_sig,
										 match_word				=>	alg_2_match_word_sig
									 );
									 
									
	 MATCH_ALG_3			:	entity work.Match_Alg3 -- Match_Algorithm_3, Evaulautes Similiraties in change of feature magnitude
									 Port MAP(
										 CLK						=> CLK,
										 signature_feature	=> alg_3_signature_sig,
										 word_feature			=> alg_3_word_sig,
										 start_signal			=> match_algorithms_start_sig,
										 feature_request		=> alg_3_feature_request_sig,
										 word_request			=> alg_3_word_request_sig,
										 done						=> match_alg_3_done_sig,
										 match_score			=>	match_alg_3_score_sig,
										 match_word				=>	alg_3_match_word_sig
									 );
									 

--	SORT_WEIGHT_RANK		: 	entity work.sort_and_weight_module 
--										PORT MAP(
--											clk => clk,
--											rst => rst_sim,
--											--ready => ,
--											start => sort_weight_start_flag,
--											done  => sort_weight_done_flag,
--											match_score_in_1 => match_alg_1_score_sig,
--											match_score_in_2 => match_alg_2_score_sig,
--											match_score_in_3 => match_alg_3_score_sig,
--											match_score_in_4 => x"0000",
--											match_done_1	=> match_alg_1_done_sig,
--											match_done_2	=> match_alg_2_done_sig,
--											match_done_3	=> match_alg_3_done_sig,
--											match_done_4	=> '0',
--											word_no_in_1 => alg_1_match_word_sig,
--											word_no_in_2 => alg_2_match_word_sig,
--											word_no_in_3 => alg_3_match_word_sig,
--											word_no_in_4 => "0000000",
--											known_cmd_no => KNOWN_CMDS,
--											final_reg_ext_addr_req => Final_results_rank_request,
--											final_reg_ext_Dout => Final_results_word_and_score_int
----											--final_best_match => --not currently in use
--										);

	SORT_WEIGHT_RANK	: entity work.swr PORT MAP(
											clk 				=> clk,
											rst 				=> rst_sim,
											score1 			=> match_alg_1_score_sig,
											score2 			=> match_alg_2_score_sig,
											score3 			=> match_alg_3_score_sig,
											done1 			=> match_alg_1_done_sig,
											done2 			=> match_alg_2_done_sig,
											done3 			=> match_alg_3_done_sig,
											result_addr 	=> final_result_addr,
											result_score 	=> final_result_score,
											result_word 	=> final_result_word
	);
										
										
-- Output Assignments
	Alg1_Feature_Request <= alg_1_feature_request_sig;
	Alg1_Word_Request <= alg_1_word_request_sig;
	Alg2_Feature_Request <= alg_2_feature_request_sig;
	Alg2_Word_Request <= alg_2_word_request_sig;
	Alg3_Feature_Request <= alg_3_feature_request_sig;
	Alg3_Word_Request <= alg_3_word_request_sig;
	
	--sort_weight_START 		<= match_alg_1_done_sig and match_alg_2_done_sig and match_alg_3_done_sig;
	sort_weight_start_flag 	<= match_alg_1_done_sig and match_alg_2_done_sig and match_alg_3_done_sig;
	
end Behavioral;

