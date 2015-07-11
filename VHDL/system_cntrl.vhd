----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    system_cntrl - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: State Machine to change the operating states when in training mode and generate control signals for the user interface.
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
--use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;


entity system_cntrl is
	Port ( 
		-- SYSTEM IO
		CLK 		: in  STD_LOGIC;
		--buttons_in  : in  STD_LOGIC_VECTOR (4 downto 0);		--for interaction with user 
		status_out		: out STD_LOGIC_VECTOR (7 downto 0);		--status indication bits (word, below threshold, error)
		data_out	: out STD_LOGIC_VECTOR (7 downto 0);		--data out bits, indicates word recognized
		-- Sorting and weighting enable & state control
--		extr_done	: in  STD_LOGIC_VECTOR (1 downto 0);		--one input for each extraction module
--		match_done	: in  STD_LOGIC_VECTOR (3 downto 0);		--one input for each match module
--		rank_done	: in  STD_LOGIC_VECTOR (3 downto 0);		--score ranking
--		weight_done	: in  STD_LOGIC;							--composite weighting
--		vcr_done	: in  STD_LOGIC;							--final weight ranking complete
--		start_match : out STD_LOGIC_VECTOR (3 downto 0);		--tells each of the (4) modules to start 
--		start_weight: out STD_LOGIC;							--start weighting of ranked scores
--		start_final : out STD_LOGIC;							--start the final ranking of calculated weights 
		-- Register control
--		weight_sel	: out STD_LOGIC;							--controls the read address mux for the register
--		guess_sel 	: out STD_LOGIC;							--controls the final ranked weights register address mux

		-- Other IO for training mode
		button_main : in  STD_LOGIC;
		train_done 	: in  STD_LOGIC;
		LEDs_Train 	: in  STD_LOGIC_VECTOR (3 downto 0); 		-- output from training_cntrl with status for LEDs
		LEDs 		: out STD_LOGIC_VECTOR (3 downto 0);  		-- send to top level with control signal for LEDs
		train_en 	: out STD_LOGIC;
		--top level mux control
		led_sel		: out STD_LOGIC;
		disp_sel	: out STD_LOGIC;
		data_sel	: out STD_LOGIC;
		stat_sel	: out STD_LOGIC;
		weight_addr_sel : out STD_LOGIC;
		--
		match_score_in : in INTEGER;	--the best match word;
		match_word_in : in INTEGER	--the best match word;
		);
end system_cntrl;

architecture Behavioral of system_cntrl is

	type state is (ready, listening, processing, result_report, training);
	signal pr_state, nx_state : state;
	
	constant LEDs_Listening : STD_LOGIC_VECTOR (3 downto 0) := "1000"; -- Active High: Listen LED | Train LED | Speak LED | other status LEDs
--	TYPE STATUS_opts is (ready, listening, processing, match, no_match, training, train_success);
--	signal status : STATUS_opts := ready;

	CONSTANT READY 		: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT LISTENING 	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT PROCESSING	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT MATCH 		: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT NO_MATCH 	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT TRAINING   : STD_LOGIC_VECTOR (7 downto 0) := x"00";
	CONSTANT TRAIN_COMP : STD_LOGIC_VECTOR (7 downto 0) := x"00";

	CONSTANT MATCH_THRESHOLD : INTEGER := 174*3;	--the maximum score which will be considered a positive match

begin

-- State Register, Clocked Transitions
process (CLK)
begin
--	if (RESET = '1') then
--		pr_state <= Listen_State;
	if rising_edge(CLK) then
		pr_state <= nx_state;
	end if;
end process;

-- training request register/process
train_request : process(clk, pr_state, button_train)
	begin
		if rising_edge(clk) then
			if (pr_state = '1') then
				train_request_flag <= '0';
			elsif (button_train = '1') then
				train_request_flag <= '1';
			end if;
		end if;
	end process;

	match_result <= MATCH when (match_score_in < MATCH_THRESHOLD) else NO_MATCH;
	data_out <= std_logic_vector(to_unsigned(match_word_in, data_out'LENGTH));

-- state control & output setup
process (button_main, train_done, pr_state)
	begin
		--default values
		Train_En <= '0';  -- control signal for training_cntrl.  will be reset to '0' in training_cntrl when training done.
		LEDs <= std_logic_vector(to_unsigned(0,LEDs'LENGTH)); -- Constant, Std_logic_Vector
		data_out <= match_word;	
		led_sel		<= '0';
		disp_sel	<= '0';
		data_sel	<= '0';
		stat_sel	<= '0';
		weight_addr_sel <= '0';

		case pr_state is
			when ready =>
				status <= match_result;	--status will remain equal to the previous match/no match value
				if (train_request_flag = '1') then
					nx_state <= training;
				else
					nx_state <= listening;
				end if;
				
			when Listening => 
				status <= listening;				
				if (start_detected = '1') then
					nx_state <= Processing;
				end if;
				
			when Processing =>
				status <= processing;
				if () then	--wait for the done signal from sort/weight/match module
					nx_state <= ready;
				end if;				

			when result_report =>
				--tell the data output module that the list is ready for evaluation - within that module...
					--request word # zero from the sort/weight/match module
					--report match word
					--if the match value is above the determination threshold, declare output as 
				--we don't actually ever get here...
				nx_state <= ready;
				
			when Train_State => 
				--top level mux control... send control over to the training module
					--status output from within the training mode will all be with a leading one
				led_sel		<= '1';
				disp_sel	<= '1';
				data_sel	<= '1';
				stat_sel	<= '1';
				weight_addr_sel <= '1';

				status <= training;
				Train_En <= '1';  -- control signal for training_cntrl.  will be reset to '0' in training_cntrl when training done.
				
				-- assert any additonal control/logic signals when in training operation
				if (train_done = '1') then
					nx_state <= ready;
				end if;

		end case;
end process;


end Behavioral;
