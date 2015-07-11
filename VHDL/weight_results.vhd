----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    weight_ranked_scores - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Combines sorted match results into a common register with weighting applied. Further sorting of these results done 
--       by the subsequent module, weighted_ranking
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
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity weight_ranked_scores is
		Port ( clk : in STD_LOGIC;
				rst : in STD_LOGIC;
				start_sig : in STD_LOGIC;				
				RS_data        : in  STD_LOGIC_VECTOR (MR_reg_data_width -1 downto 0); --Ranked Score data - bits 25-10 are score, 9-0 are next link
				RS_req_address : out STD_LOGIC_VECTOR (sort_addr_width - 1 downto 0); --Ranked Score read address
				weight_address : out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0); --Ranked Score read address
				ex_match_src   : out STD_LOGIC_VECTOR (1 downto 0);                   --ex/match pair register we're currently on
				curr_weight    : in  STD_LOGIC_VECTOR (Score_width-1 downto 0); --the current weight of the word before updating
				result_weight  : out STD_LOGIC_VECTOR (Score_width-1 downto 0); --updated weight
				result_write   : out STD_LOGIC;	--enable writing to the output register
				ready_flag     : out STD_LOGIC;
				done_flag      : out STD_LOGIC
			);

end weight_ranked_scores;
	
architecture Behavioral of weight_ranked_scores is
	TYPE weight_states IS (ready, calculate, write_data, next_source, complete);
	SIGNAL STATE : weight_states;
	
	TYPE SCORES IS ARRAY (0 to 24) OF INTEGER;
	SIGNAL rank_score_LUT : SCORES := ( -- =sqrt(rank*10,000)
		100, 141, 173, 200, 224, 245, 283, 300, 316, 332, 
		346, 360, 374, 387, 400, 412, 424, 436, 447, 458, 
		469, 480, 490, 500, 510);
	
	SIGNAL current_rank : INTEGER := 0; --holds the current rank we're looking at for calculation purposes
	SIGNAL score_adder  : INTEGER;
	SIGNAL T_ex_match_src : STD_LOGIC_VECTOR(1 downto 0) := "00"; --the currently under review pair

	SIGNAL T_result_weight  : STD_LOGIC_VECTOR (Score_width-1 downto 0);  --holds the summation of the current word's weight

BEGIN
	ex_match_src   <= T_ex_match_src;
	RS_req_address <= STD_LOGIC_VECTOR(to_unsigned(current_rank, RS_req_address'LENGTH));  --request address is simply the rank
	weight_address <= RS_data(MR_reg_data_width - 1 downto MR_reg_data_width - MR_reg_add_width);  
		--the address to store the result into is simply the ranked word #
	result_weight  <= T_result_weight;
	score_adder    <= rank_score_LUT(current_rank) WHEN (current_rank < 24)
		ELSE 1000;	
		--calculate the weighting value to add to the word's score
	
st_machine :
	PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN
			ready_flag <= '1';
			state <= ready;
			current_rank <= 0;
			T_ex_match_src <= "00";
			--T_result_weight <= (OTHERS => '0'); --sets the link to zero for the time being.
			T_result_weight <= STD_LOGIC_VECTOR(unsigned(curr_weight) --...
					+ to_unsigned(score_adder, T_result_weight'LENGTH) ); --doing one word/pair at a time to make sure we don't double dip
		ELSE 
			
			IF rising_edge(clk) THEN	--set up as falling edge to allow time for results to propogate to the register addresses and return data to appear
				T_result_weight <= STD_LOGIC_VECTOR(unsigned(curr_weight) --...
					+ to_unsigned(score_adder, T_result_weight'LENGTH) ); --doing one word/pair at a time to make sure we don't double dip
				CASE STATE is

					WHEN ready =>
						result_write <='0';
						current_rank <= 0;
						done_flag <= '0';
						T_ex_match_src <= "00";
						--T_result_weight <= (OTHERS => '0');
						--wait for start signal (complete signal from sorting algorithm)
						IF (start_sig = '1') THEN
							--advance state to calculate
							STATE <= calculate;
							ready_flag <= '0';
						ELSE 
							ready_flag <= '1';
						END IF;

					WHEN calculate =>
						ready_flag <= '0';
						
						IF  (current_rank = 24) THEN --if we're done with all the interesting ranks
							current_rank <= 0;
							result_write <='0';
							--T_result_weight <= (OTHERS => '0');
							IF (T_ex_match_src = "10") THEN   --if all match pairs are done
								--send out done flag
								state <= ready;
								T_ex_match_src <= "00";
								done_flag <='1';                
							ELSE
								T_ex_match_src <= STD_LOGIC_VECTOR(unsigned(T_ex_match_src) + "01");
								state <= next_source;
							END IF;
						ELSE
							--with the currently loaded word/rank/link
							--add the current rank to the word's composite score
							result_write <='1';							
							current_rank <= current_rank + 1;
							state <= write_data;
						END IF;

					WHEN write_data =>
						result_write <='0';
						state <= calculate;

					WHEN next_source =>	--gives a 1 cycle pause to allow next data to load...
						state <= calculate;

					WHEN OTHERS =>
						null;

				END CASE;
			END IF;
		END IF;
	 END PROCESS;
end Behavioral;

