----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:43:50 03/08/2015 
-- Module Name:    scored_commands_control - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: 	Monitors the changed command word weights and logs thos values. 
-- 					The modified entries will then be sorted and will also be reset to zero upon completion
--
-- Dependencies: 
--
-- Revision: 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity NO_USE_HOMIE is
	Port ( 
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		match_score_in_1 : in  STD_LOGIC_VECTOR (Score_width-1 downto 0);	--simulated score coming in from extraction match datapath 1
        match_score_in_2 : in  STD_LOGIC_VECTOR (Score_width-1 downto 0);	
        match_score_in_3 : in  STD_LOGIC_VECTOR (Score_width-1 downto 0);
        match_score_in_4 : in  STD_LOGIC_VECTOR (Score_width-1 downto 0);
        word_no_in_1     : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width-1 downto 0);			--simulated score identifier - will not necessarily be in sync during the actual running...
        word_no_in_2     : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width-1 downto 0);
        word_no_in_3     : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width-1 downto 0);
        word_no_in_4     : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width-1 downto 0);
        final_reg_ext_addr_req : IN INTEGER;	--reuqest from external module for the word in specified final ranking
        final_reg_ext_Dout : OUT INTEGER;		--word in currently selected ranked position.
        final_best_match : OUT INTEGER			--best word in list, in integer format for ease of transport through connected logic.
	);
end NO_USE_HOMIE;

architecture Behavioral of NO_USE_HOMIE is
	--signal concatenation types
	TYPE ScoreIn IS ARRAY (1 to 4) OF STD_LOGIC_VECTOR(Score_width-1 downto 0);				--scores from matching modules addressed as an array
		SIGNAL score_array      : ScoreIn := (OTHERS => (OTHERS => '0'));
	TYPE WordsIn IS ARRAY (1 to 4) OF STD_LOGIC_VECTOR(Command_Reg_Add_Width-1 downto 0);	--word numbers from matching modules addressed as an array
		SIGNAL words_array      : WordsIn := (OTHERS => (OTHERS => '0'));
	--generated interconnect types
	TYPE RegFlag IS ARRAY (1 to 4) OF STD_LOGIC;								--flags used by score sorting modules
	TYPE RegData IS ARRAY (1 to 4) OF STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0);
	TYPE RegAddr IS ARRAY (1 to 4) OF STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);

	--interconnect signals for sort_scores_module TO sorted_scores_register (x4, one for each extraction match pair)
		SIGNAL score_sort_F_ready  	: RegFlag := (OTHERS => '0');	--the sort_scores_module is ready to begin
		SIGNAL score_sort_F_done   	: RegFlag := (OTHERS => '0');	--the sort_scores_module has completed all sorts
		SIGNAL score_sort_start    	: RegFlag := (OTHERS => '0');	--input to sort_scores_module telling to start/enable sorting
		SIGNAL score_reg_en        	: RegFlag := (OTHERS => '0');	--enable write on the sorted_scores_register
		SIGNAL T_score_reg_en       : RegFlag := (OTHERS => '0');	--temp signal for routing the above
		SIGNAL score_sort_addr_req 	: RegAddr := (OTHERS => (OTHERS => '0'));	--requested address, by sort_scores_module, requesting data from sorted_scores_register
		SIGNAL score_reg_addr_in   	: RegAddr := (OTHERS => (OTHERS => '0'));	--address operated on by the sorted scores register (mux output)
		SIGNAL score_reg_Dout      	: RegData := (OTHERS => (OTHERS => '0'));	--data read from the sorted_scores_register
		SIGNAL score_reg_Din       	: RegData := (OTHERS => (OTHERS => '0'));	--data to be wrtitten to the sorted_scores_register
		SIGNAL T_score_reg_Din      : RegData := (OTHERS => (OTHERS => '0'));	--temp signal for routing the above

	--control signals for sorted_scores_register
		SIGNAL score_reg_addr_SEL   : RegFlag := (OTHERS => '0');	--used for selecting whether sort_scores_module or weight_scores_module has control over address request of sorted_scores_register
		SIGNAL prev_cmd_in			: WordsIn := (OTHERS => (OTHERS => '0'));	--allows for comparison of last word sorted, to know when we've been updated.

	--interconnect signals for (x4) sorted_scores_registers TO weight_scores_module
		SIGNAL weight_Din		  	: STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0) := (OTHERS => '0');	--mux output into weight_scores_module
		SIGNAL weight_Din_SEL       : STD_LOGIC_VECTOR (1 downto 0) := (OTHERS => '0');			--controls the mux selecting which extraction/match module in inputting to the weight module
		SIGNAL weight_score_addr_req: STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0) := (OTHERS => '0');

	--interconnect signals for weight_scores_module TO unsorted_weights_register
		SIGNAL weight_F_start   	: STD_LOGIC := '0';
		SIGNAL weight_F_ready   	: STD_LOGIC := '0';
		SIGNAL weight_F_done    	: STD_LOGIC := '0';
		SIGNAL weight_reg_Dout  	: STD_LOGIC_VECTOR (Score_width-1 downto 0)			:= (OTHERS => '0');
		SIGNAL weight_reg_Din   	: STD_LOGIC_VECTOR (Score_width-1 downto 0)			:= (OTHERS => '0');
		SIGNAL weight_reg_en    	: STD_LOGIC := '0';
		SIGNAL weight_reg_addr_in  	: STD_LOGIC_VECTOR (MR_reg_add_width-1 downto 0)		:= (OTHERS => '0');
		SIGNAL weight_weight_addr_req : STD_LOGIC_VECTOR (MR_reg_add_width-1 downto 0)	:= (OTHERS => '0');

	--control signals for unsorted_weights_register
		SIGNAL weight_reg_RST     	: STD_LOGIC := '0';	--controls a reset for the register in between each cycle
		SIGNAL weight_reg_addr_SEL	: STD_LOGIC := '0';	--allows control to be selected as from weight_scores_module or final_sort_module
	
	--data and control signals for modified_word_register, most signals are shared with unsorted_weights_register
		SIGNAL mod_reg_addr_SEL 	: STD_LOGIC := '0';
		SIGNAL mod_reg_addr_in  	: STD_LOGIC_VECTOR (6 downto 0)	:= (OTHERS => '0');
		SIGNAL mod_reg_Dout			: STD_LOGIC_VECTOR (MR_reg_add_width-1 downto 0)	:= (OTHERS => '0');

	--interconnect signals for unsorted_weights_register TO final_sort_module
		SIGNAL final_weight_addr_req : STD_LOGIC_VECTOR (MR_reg_add_width-1 downto 0)	:= (OTHERS => '0');

	--interconnect signals for final_sort_module TO final_ranking_register
		SIGNAL final_F_start		: STD_LOGIC := '0';		
		SIGNAL final_F_ready		: STD_LOGIC := '0';
		SIGNAL final_F_done			: STD_LOGIC := '0';
		SIGNAL final_reg_Din 		: STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0) := (OTHERS => '0');
		SIGNAL T_final_reg_Din 		: STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0) := (OTHERS => '0');
		SIGNAL final_reg_Dout		: STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0) := (OTHERS => '0');
		SIGNAL final_reg_en			: STD_LOGIC := '0';
		SIGNAL T_final_reg_en			: STD_LOGIC := '0';
		SIGNAL final_reg_addr_in    : STD_LOGIC_VECTOR (6 downto 0) := (OTHERS => '0');
		SIGNAL final_sort_addr_req  : STD_LOGIC_VECTOR (6 downto 0) := (OTHERS => '0');

	--control signals for final_ranking_register
		SIGNAL final_reg_addr_SEL   : STD_LOGIC := '0';


begin
	--rename incoming signals to parts of the array used in generate statement above
	score_array(1) <= match_score_in_1;		words_array(1) <= word_no_in_1;
	score_array(2) <= match_score_in_2;		words_array(2) <= word_no_in_2;
	score_array(3) <= match_score_in_3;		words_array(3) <= word_no_in_3;
	score_array(4) <= match_score_in_4;		words_array(4) <= word_no_in_4;

	final_reg_ext_Dout <= to_integer(unsigned(final_reg_Dout));

	SORTING_ALGORITHMS:
	FOR i in 1 to 4 generate
		sort_scores_module: entity work.sorting_algorithm 
		PORT MAP(
			clk 		 => clk,
			rst 		 => rst,
			word_no_in 	 => words_array(i),
			score_in 	 => score_array(i),
			start_sort 	 => score_sort_start(i),
			data_reg 	 => score_reg_Dout(i),
			dest_address => score_sort_addr_req(i),
			dest_data 	 => T_score_reg_Din(i),
			dest_wen 	 => T_score_reg_en(i),
			ready_flag 	 => score_sort_F_ready,
			done_flag	 => score_sort_F_done
		 );

		sorted_scores_register: entity work.reg_with_insert 
		PORT MAP(
			clk 		=> clk,
			rst 		=> rst,
			address 	=> score_reg_addr_in,
			w_data 		=> score_reg_Din,
			w_en 		=> score_reg_en,
			data_out_1 	=> score_reg_Dout
		);		
		--sorted_scores_reg address select mux
		score_reg_addr_in(i) <= (others => '0') WHEN state = reset_sorting_reg
			ELSE score_sort_addr_req(i) WHEN (score_reg_addr_SEL(i) = '0') 
			ELSE weight_score_addr_req;
		score_reg_Din(i) <= (others => '1') WHEN state = reset_sorting_reg
			ELSE T_score_reg_Din(i); 
		score_reg_en(i) <= '1' WHEN state = reset_sorting_reg
			ELSE T_score_reg_en;
	END generate;

	weight_scores_module: entity work.weight_results 
	PORT MAP( 
		clk => clk,
		rst => rst,
		start_sig 		=> weight_F_start,
		RS_data 		=> weight_Din,
		RS_req_address	=> weight_score_addr_req,
		weight_address 	=> weight_weight_addr_req,
		ex_match_src 	=> weight_Din_SEL,		
		curr_weight 	=> weight_reg_Dout,
		result_weight	=> weight_reg_Din,
		result_write    => weight_reg_en,
		ready_flag 		=> weight_F_ready,
		done_flag 		=> weight_F_done
	 );
		WITH weight_Din_SEL SELECT weight_Din <=
			score_reg_Dout(1) WHEN "00",
			score_reg_Dout(2) WHEN "01",
			score_reg_Dout(3) WHEN "10",
			score_reg_Dout(4) WHEN OTHERS;

	unsorted_weights_register: entity work.weighting_results_reg 
	GENERIC MAP(
		AW => Command_Reg_Add_Width,
		DW => Score_width
		) 
	 PORT MAP(
		rst => weight_reg_RST,
		clk => clk,
		w_en => weight_reg_en,
		addr => weight_reg_addr_in,
		d_in => weight_reg_Din,
		d_out => weight_reg_Dout
	 );
	 	weight_reg_addr_in <= (weight_weight_addr_req) WHEN (weight_reg_addr_SEL = '0') ELSE (mod_reg_Dout);

	--keep track of which registers in the word list were modified
	modified_word_register: entity work.weighting_results_reg 
	GENERIC MAP(
		AW => 7,
		DW => Command_Reg_Add_Width
		) 
	 PORT MAP(
		rst => weight_reg_RST,
		clk => clk,
		w_en => weight_reg_en,
		addr => mod_reg_addr_in,
		d_in => weight_score_addr_req,	
		d_out => mod_reg_Dout
	 );
	 	mod_reg_addr_in <= (weight_Din_SEL & weight_score_addr_req(4 downto 0)) WHEN (mod_reg_addr_SEL = '0') ELSE (final_weight_addr_req);

	final_sort_module: entity work.sorting_algorithm 
		PORT MAP(
			clk 		 => clk,
			rst 		 => rst,
			word_no_in 	 => mod_reg_Dout,
			score_in 	 => weight_reg_Dout,
			start_sort 	 => final_F_start,
			data_reg 	 => final_reg_Dout,
			dest_address => final_sort_addr_req,
			dest_data 	 => T_final_reg_Din,
			dest_wen 	 => T_final_reg_en,
			ready_flag 	 => final_F_ready,
			done_flag	 => final_F_done
		 );

	final_ranking_register: entity work.reg_with_insert 
		PORT MAP(
			clk 		=> clk,
			rst 		=> rst,
			address 	=> final_reg_addr_in,
			w_data 		=> final_reg_Din,
			w_en 		=> final_reg_en,
			data_out_1 	=> final_reg_Dout
		);		
		final_reg_addr_in <= (OTHERS => '0') WHEN state = reset_final_reg	--inserts a string of zeros into the first position, shifts all others down.
			ELSE (final_sort_addr_req) WHEN (final_reg_addr_SEL = '0') 
			ELSE (final_reg_ext_addr_req);
		final_reg_Din <= (others => '1') WHEN state = reset_final_reg
			ELSE T_final_reg_Din;
		final_reg_en <= '1' WHEN state = reset_final_reg
			ELSE T_final_reg_en;

--score sorting start signal generation and register control
	process (clk, rst)
	begin
		IF (rst = '1') THEN 
			state <= ready;
		ELSIF rising_edge(clk) THEN

			CASE state IS
				WHEN ready =>
					if (prev_cmd_in(1) /= words_array(1)) then  --wait for any word to change
						state <= sorting;		--on change go to sorting
						master_done_F <= '0';
					end if ;
					score_reg_addr_SEL <= '0';	--toggle sort register control to scores module ('0')
					final_reg_addr_SEL <= '1';	--toggle final ranking control to external request ('1')
				
				WHEN sorting =>
				 
						check_for_update : for i in 1 to 4 generate  
						if (prev_cmd_in(i) /= word_no_in_1) then  --wait for any word to change
							if (score_sort_F_ready(i) = '1')	--if alg is ready
								score_sort_start(i) <= '1';		--send start flag to sorting alg n
							else 
								--error condition
							end if;
						elsif score_sort_F_done(i) = '1' then 
							if words_array(i) = known_cmd_no then 
								master_done_F(i) <= '1';	--let the system know we're ready to move into weighting
							else --only done with this one word
								--do anything?
							end if ;
						end if;
					end generate ; -- check_for_update
					--check if all are done & advance state
					if master_done_F = "1111" then
						state <= reset_final_reg;
						counter <= 0;
					end if;
					--wait for done flag
						--if word # == known_cmd_no for all 
							--go to waiting // reset final reg
				
				WHEN reset_final_reg =>	
					counter <= counter + 1;
					if counter = 128 then 
						state <= weighting;
						counter <= 0;
					end if ;
					--reset final register...how?
						--use a counter, on each clk period, update register 0 to all zeros
						--do this for as many entries as there are in the register... (1000 clk cycles...)
				
				WHEN weighting =>
					score_reg_addr_SEL  <= '1';			--toggle sort register control to weight module ('1')
					weight_reg_addr_SEL <= '0';			--toggle weight register control to weight module ('0')
					weight_Din_SEL      <= '0';
					mod_reg_addr_SEL    <= '0';			--toggle updated word register control to weight module ('0')
					if weight_F_done = '1' then
						state <= ranking;
					end if ; --wait for done flag from weight module
						--on done, advance to final ranking
				
				WHEN ranking =>					
					weight_reg_addr_SEL <= '1';
					weight_Din_SEL      <= '1'; 		--toggle weight register control to final module ('1')
					mod_reg_addr_SEL    <= '1'; 		--toggle updated word register control to final module ('1')
					final_reg_addr_SEL  <= '0'; 		--toggle final register control to final module ('0')
				
				WHEN reset_sorting_reg =>
					counter	<= counter + 1;
					if counter = 2**Command_Reg_Add_Width then 
						state <= weighting;
						counter <= 0;
					end if ;
					--reset final register...how?
						--use a counter, on each clk period, update register 0 to all zeros
						--do this for as many entries as there are in the register... (1000 clk cycles...)
					--reset weighting registers as well.
			END CASE;
		END IF;
	end process;

end Behavioral;