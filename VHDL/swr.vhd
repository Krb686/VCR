library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.VCR_Package.ALL;


entity swr is
	Port (
		clk			:	in	STD_LOGIC;
		rst			:	in	STD_LOGIC;
		score1		:	in	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
		score2		:	in	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
		score3		:	in	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
		done1			:	in	STD_LOGIC;
		done2			:	in	STD_LOGIC;
		done3			:	in	STD_LOGIC;
		result_addr	:	in	STD_LOGIC_VECTOR(Command_Reg_Add_Width	+ 1 downto 0);
		result_score:	out	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
		result_word	:	out	STD_LOGIC_VECTOR(Command_Reg_Add_Width	- 1 downto 0)
	);
end swr;

architecture Behavioral of swr is

	type 		state_type 		is (S_WAIT, S_SUB_SORT, S_WEIGHTING, S_RANKING, S_DONE);
	type 		substate_type	is (S_WAIT, S_LOAD_OUTER, S_COMPARE, S_INC_INDEX1, S_INC_INDEX2, S_SWAP1, S_SWAP2, S_SWAP3, S_SUB_DONE, S_DELAY1, S_DELAY2, S_DELAY3, S_WEIGHT_MULT, S_WEIGHT_TRANSFER, S_WEIGHT_SLICE);
	type		word_order		is array (Total_Commands - 1 downto 0) of STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	
	type		word_order_final_reg is array ((Total_Commands * 3) - 1 downto 0) of STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	
	
	signal 	current_state 	: state_type;
	
	
	
	--====================================================
	-- Register 1
	------ Combinational
	signal reg1_addr				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg1_din				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg1_dout				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg1_dout_uns			:	unsigned(Score_Width - 1 downto 0);
	signal reg1_en					:	STD_LOGIC;
	signal score1_smallest_uns	:	unsigned(Score_Width - 1 downto 0);

	
	
	------ Registered
	signal score1_write_addr				:	integer;
	signal reg1_index1_int					:	integer;
	signal reg1_index1_vector				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg1_index2_int					:	integer;
	signal reg1_index2_vector				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score1_smallest					:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score1_temp						:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score1_temp_ext					:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal score1_smallest_index_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score1_smallest_index_int		:	integer;
	signal score1_smallest_index_temp	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal substate1							:	substate_type;
	signal word_order1						:	word_order;
	signal word_no_temp1						:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	--====================================================
	
	
	
	--====================================================
	-- Register 2
	-- Combinational
	signal reg2_addr				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg2_din				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg2_dout				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg2_dout_uns			:	unsigned(Score_Width - 1 downto 0);
	signal reg2_en					:	STD_LOGIC;
	signal score2_smallest_uns	:	unsigned(Score_Width - 1 downto 0);
	
	-- Registered
	signal score2_write_addr		:	integer;
	signal reg2_index1_int			:	integer;
	signal reg2_index1_vector		:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg2_index2_int			:	integer;
	signal reg2_index2_vector		:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score2_smallest			:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score2_temp				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score2_temp_ext					:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal score2_smallest_index_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score2_smallest_index_int	:	integer;
	signal score2_smallest_index_temp	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal substate2					:	substate_type;
	signal word_order2				:	word_order;
	signal word_no_temp2				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	--====================================================
	
	
	
	--====================================================
	-- Register 3
	-- Combinational
	signal reg3_addr				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg3_din				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg3_dout				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal reg3_dout_uns			:	unsigned(Score_Width - 1 downto 0);
	signal reg3_en					:	STD_LOGIC;
	signal score3_smallest_uns	:	unsigned(Score_Width - 1 downto 0);

	-- Registered
	signal score3_write_addr		:	integer;
	signal reg3_index1_int			:	integer;
	signal reg3_index1_vector		:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal reg3_index2_int			:	integer;
	signal reg3_index2_vector		:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score3_smallest			:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score3_temp				:	STD_LOGIC_VECTOR(Score_Width - 1 downto 0);
	signal score3_temp_ext					:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal score3_smallest_index_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal score3_smallest_index_int	:	integer;
	signal score3_smallest_index_temp	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	signal substate3					:	substate_type;
	signal word_order3				:	word_order;
	signal word_no_temp3				:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1 downto 0);
	--====================================================
	
	
	type unsigned_lut	is	array(0 to Total_Commands - 1) of unsigned(7 downto 0);
	
	constant weight_lut	:	unsigned_lut := (
		x"64", x"8D", x"AD", x"C8"
	);	--, 224, 245, 283, 300, 316, 332, 346, 360, 
		
	
		
	signal weight_index				:	integer;
	signal weight_delay_counter	:	integer;
	signal transfer_counter			:	integer range 0 to 3;
	signal transfer_val				:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	
	
	--====================================================
	-- Ranking Reg
	signal rank_reg_en	:	STD_LOGIC;
	signal rank_reg_addr	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width+1 downto 0);
	signal rank_reg_din	:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal rank_reg_dout	:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal rank_reg_dout_uns	:	unsigned(Score_Width_Ext - 1 downto 0);
	
	signal rank_index_int			:	integer range 0 to (Total_Commands * 3) - 1;
	signal rank_index_vector		:	STD_LOGIC_VECTOR(Command_Reg_Add_Width+1 downto 0);
	
	signal	word_order_final	:	word_order_final_reg;
	
	signal 	final_score_smallest_index_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width+1 downto 0);
	signal	final_score_temp		:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	
	signal	final_reg_index1_int	:	integer;
	signal	final_reg_index2_int	:	integer;
	signal	final_reg_index1_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width+1 downto 0);
	signal	final_reg_index2_vector	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width+1 downto 0);
	
	signal	final_reg_smallest		:	STD_LOGIC_VECTOR(Score_Width_Ext - 1 downto 0);
	signal	final_reg_smallest_uns	:	unsigned(Score_Width_Ext - 1 downto 0);
	
	signal 	final_score_smallest_index_temp	:	STD_LOGIC_VECTOR(Command_Reg_Add_Width - 1  downto 0);
	signal	final_score_smallest_index_int	:	integer;
	--====================================================
	
begin

	
							
	result_score	<=	rank_reg_dout;
	result_word		<= (others => '0');
	
	


	-- ========================================================================
	-- Reg1 Combinational
	reg1_addr 	<= 	STD_LOGIC_VECTOR(to_unsigned(score1_write_addr, Command_Reg_Add_Width)) 	when current_state = S_WAIT else
							STD_LOGIC_VECTOR(to_unsigned(reg1_index1_int, Command_Reg_Add_Width)) 		when current_state = S_SUB_SORT and substate1 = S_LOAD_OUTER else
							STD_LOGIC_VECTOR(to_unsigned(reg1_index1_int, Command_Reg_Add_Width))		when current_state = S_SUB_SORT and substate1 = S_SWAP1 else
							score1_smallest_index_vector																when current_state = S_SUB_SORT and substate1 = S_SWAP3 else
							STD_LOGIC_VECTOR(to_unsigned(weight_index, Command_Reg_Add_Width))			when current_state = S_WEIGHTING else
							STD_LOGIC_VECTOR(to_unsigned(reg1_index2_int, Command_Reg_Add_Width));
						
	reg1_din		<=		score1 				when current_state = S_WAIT else
							score1_smallest 	when current_state = S_SUB_SORT and substate1 = S_SWAP1 else
							score1_temp			when current_state = S_SUB_SORT and substate1 = S_SWAP3 else	
							(others => '0');
							
	reg1_dout_uns <= unsigned(reg1_dout);
						
	reg1_en <= 	done1 	when current_state = S_WAIT else
					'1'		when current_state = S_SUB_SORT and substate1 = S_SWAP1 else
					'1'		when current_state = S_SUB_SORT and substate1 = S_SWAP3 else
					'0';
					
	score1_smallest_uns <= unsigned(score1_smallest);
	score1_smallest_index_int <= to_integer(unsigned(score1_smallest_index_vector));
	
	reg1_index1_vector	<= STD_LOGIC_VECTOR(to_unsigned(reg1_index1_int, Command_Reg_Add_Width));
	reg1_index2_vector	<=	STD_LOGIC_VECTOR(to_unsigned(reg1_index2_int, Command_Reg_Add_Width));
	-- ========================================================================
	
	
	
	-- ========================================================================
	-- Reg2 Combinational
	reg2_addr 	<= 	STD_LOGIC_VECTOR(to_unsigned(score2_write_addr, Command_Reg_Add_Width)) 	when current_state = S_WAIT else
							STD_LOGIC_VECTOR(to_unsigned(reg2_index1_int, Command_Reg_Add_Width)) 		when current_state = S_SUB_SORT and substate2 = S_LOAD_OUTER else
							STD_LOGIC_VECTOR(to_unsigned(reg2_index1_int, Command_Reg_Add_Width))		when current_state = S_SUB_SORT and substate2 = S_SWAP1 else
							score2_smallest_index_vector																when current_state = S_SUB_SORT and substate1 = S_SWAP3 else
							STD_LOGIC_VECTOR(to_unsigned(weight_index, Command_Reg_Add_Width))			when current_state = S_WEIGHTING else
							STD_LOGIC_VECTOR(to_unsigned(reg2_index2_int, Command_Reg_Add_Width));
						
	reg2_din		<=		score2 				when current_state = S_WAIT else
							score2_smallest 	when current_state = S_SUB_SORT and substate2 = S_SWAP1 else
							score2_temp			when current_state = S_SUB_SORT and substate2 = S_SWAP3 else
							(others => '0');
							
	reg2_dout_uns <= unsigned(reg2_dout);
						
	reg2_en <= 	done2 	when current_state = S_WAIT else
					'1'		when current_state = S_SUB_SORT and substate2 = S_SWAP1 else
					'1'		when current_state = S_SUB_SORT and substate2 = S_SWAP3 else
					'0';
					
	score2_smallest_uns <= unsigned(score2_smallest);
	score2_smallest_index_int <= to_integer(unsigned(score2_smallest_index_vector));
	
	reg2_index1_vector	<= STD_LOGIC_VECTOR(to_unsigned(reg2_index1_int, Command_Reg_Add_Width));
	reg2_index2_vector	<=	STD_LOGIC_VECTOR(to_unsigned(reg2_index2_int, Command_Reg_Add_Width));
	-- ========================================================================
	
	
	-- ========================================================================
	-- Reg3 Combinational
	reg3_addr 	<= 	STD_LOGIC_VECTOR(to_unsigned(score3_write_addr, Command_Reg_Add_Width)) 	when current_state = S_WAIT else
							STD_LOGIC_VECTOR(to_unsigned(reg3_index1_int, Command_Reg_Add_Width)) 		when current_state = S_SUB_SORT and substate3 = S_LOAD_OUTER else
							STD_LOGIC_VECTOR(to_unsigned(reg3_index1_int, Command_Reg_Add_Width))		when current_state = S_SUB_SORT and substate3 = S_SWAP1 else
							score3_smallest_index_vector																when current_state = S_SUB_SORT and substate1 = S_SWAP3 else
							STD_LOGIC_VECTOR(to_unsigned(weight_index, Command_Reg_Add_Width))			when current_state = S_WEIGHTING else
							STD_LOGIC_VECTOR(to_unsigned(reg3_index2_int, Command_Reg_Add_Width));
						
	reg3_din		<=		score3 				when current_state = S_WAIT else
							score3_smallest 	when current_state = S_SUB_SORT and substate3 = S_SWAP1 else
							score3_temp			when current_state = S_SUB_SORT and substate3 = S_SWAP3 else
							(others => '0');
							
	reg3_dout_uns <= unsigned(reg3_dout);
						
	reg3_en <= 	done3 	when current_state = S_WAIT else
					'1'		when current_state = S_SUB_SORT and substate3 = S_SWAP1 else
					'1'		when current_state = S_SUB_SORT and substate3 = S_SWAP3 else
					'0';
					
	score3_smallest_uns <= unsigned(score3_smallest);
	score3_smallest_index_int <= to_integer(unsigned(score3_smallest_index_vector));
	
	reg3_index1_vector	<= STD_LOGIC_VECTOR(to_unsigned(reg3_index1_int, Command_Reg_Add_Width));
	reg3_index2_vector	<=	STD_LOGIC_VECTOR(to_unsigned(reg3_index2_int, Command_Reg_Add_Width));
	-- ========================================================================
	
	
	-- ========================================================================
	-- Rank Register
	
	rank_index_vector <= STD_LOGIC_VECTOR(to_unsigned(rank_index_int, Command_Reg_Add_Width+2));
	
	
	
	rank_reg_addr 	<= STD_LOGIC_VECTOR(to_unsigned(final_reg_index1_int, Command_Reg_Add_Width+2)) 		when current_state = S_RANKING and substate1 = S_LOAD_OUTER else
							STD_LOGIC_VECTOR(to_unsigned(final_reg_index1_int, Command_Reg_Add_Width+2))		when current_state = S_RANKING and substate1 = S_SWAP1 else
							final_score_smallest_index_vector																when current_state = S_RANKING and substate1 = S_SWAP3 else
							rank_index_vector 																					when current_state = S_WEIGHTING else
							result_addr 																							when current_state = S_DONE else
							STD_LOGIC_VECTOR(to_unsigned(final_reg_index2_int, Command_Reg_Add_Width+2));
							
	rank_reg_din	<= score1_temp_ext				when substate1 = S_WEIGHT_TRANSFER and transfer_counter = 0 else
							score2_temp_ext				when substate1 = S_WEIGHT_TRANSFER and transfer_counter = 1 else
							score3_temp_ext				when substate1 = S_WEIGHT_TRANSFER and transfer_counter = 2 else
							final_reg_smallest 	when current_state = S_RANKING and substate1 = S_SWAP1 else
							final_score_temp		when current_state = S_RANKING and substate1 = S_SWAP3 else
							(others => '0');
							
	rank_reg_dout_uns <= unsigned(rank_reg_dout);
	
	
	rank_reg_en <= '1' when current_state = S_WEIGHTING and substate1 = S_WEIGHT_TRANSFER else
						'1' when current_state = S_RANKING and substate1 = S_SWAP1 else
						'1' when current_state = S_RANKING and substate1 = S_SWAP3 else
						'0';
	
	
	final_reg_smallest_uns 				<= unsigned(final_reg_smallest);
	final_score_smallest_index_int	<= to_integer(unsigned(final_score_smallest_index_vector));
							
							
	final_reg_index1_vector <= STD_LOGIC_VECTOR(to_unsigned(final_reg_index1_int, Command_Reg_Add_Width+2));
	final_reg_index2_vector <= STD_LOGIC_VECTOR(to_unsigned(final_reg_index2_int, Command_Reg_Add_Width+2));
	
	-- ========================================================================

	SCORE_REG1: entity work.BRAM_reg 
	GENERIC MAP (
		AW => Command_Reg_Add_Width,
		DW => Score_Width
	)
	PORT MAP(
		clk 	=> clk,
		wen 	=> reg1_en,
		addr 	=> reg1_addr,
		d_in 	=> reg1_din,
		d_out => reg1_dout
	);

	SCORE_REG2: entity work.BRAM_reg 
	GENERIC MAP (
		AW => Command_Reg_Add_Width,
		DW => Score_Width
	)
	PORT MAP(
		clk 	=> clk,
		wen 	=> reg2_en,
		addr 	=> reg2_addr,
		d_in 	=> reg2_din,
		d_out => reg2_dout
	);
	
	SCORE_REG3: entity work.BRAM_reg 
	GENERIC MAP (
		AW => Command_Reg_Add_Width,
		DW => Score_Width
	)
	PORT MAP(
		clk 	=> clk,
		wen 	=> reg3_en,
		addr 	=> reg3_addr,
		d_in 	=> reg3_din,
		d_out => reg3_dout
	);
	
	RANKING_REG: entity work.BRAM_reg 
	GENERIC MAP (
		AW => Command_Reg_Add_Width+2,
		DW => Score_Width_Ext
	)
	PORT MAP(
		clk 	=> clk,
		wen 	=> rank_reg_en,
		addr 	=> rank_reg_addr,
		d_in 	=> rank_reg_din,
		d_out => rank_reg_dout
	);
	
	process(clk, rst)
	begin
		if(rst = '1') then
		
			current_state <= S_WAIT;
		
			-- ====================
			-- Reg1 Resets
			score1_write_addr 				<= 0;
			reg1_index1_int 					<= 0;
			reg1_index2_int 					<= 0;
			score1_smallest 					<= (others => '0');
			score1_temp							<= (others => '0');
			score1_temp_ext					<= (others => '0');
			score1_smallest_index_vector 	<= (others => '0');
			score1_smallest_index_temp		<= (others => '0');
			substate1 							<= S_WAIT;
			word_order1							<= (others => (others => '0'));
			-- ====================
			
			-- ====================
			-- Reg2 Resets
			score2_write_addr 				<= 0;
			reg2_index1_int 					<= 0;
			reg2_index2_int 					<= 0;
			score2_smallest 					<= (others => '0');
			score2_temp							<= (others => '0');
			score2_temp_ext					<= (others => '0');
			score2_smallest_index_vector 	<= (others => '0');
			score2_smallest_index_temp		<= (others => '0');
			substate2 							<= S_WAIT;
			word_order2							<= (others => (others => '0'));
			-- ====================
			
			-- ====================
			-- Reg3 Resets
			score3_write_addr 				<= 0;
			reg3_index1_int 					<= 0;
			reg3_index2_int 					<= 0;
			score3_smallest 					<= (others => '0');
			score3_temp							<= (others => '0');
			score3_temp_ext					<= (others => '0');
			score3_smallest_index_vector	<= (others => '0');
			score3_smallest_index_temp 	<= (others => '0');
			substate3 							<= S_WAIT;
			word_order3							<= (others => (others => '0'));
			-- ====================
			
			
			-- ====================
			-- Final Reg Resets
			weight_index 								<= 0;
			weight_delay_counter 					<= 0;
			transfer_counter 							<= 0;
			transfer_val 								<= (others => '0');
			word_no_temp1 								<= (others => '0');
			word_no_temp2 								<= (others => '0');
			word_no_temp3 								<= (others => '0');
			
			rank_index_int 							<= 0;
			final_score_temp							<= (others => '0');
			final_score_smallest_index_vector 	<= (others => '0');
			final_score_smallest_index_temp		<= (others => '0');
			final_reg_index1_int 					<= 0;
			final_reg_index2_int 					<= 0;
			-- ====================
			
		elsif(rising_edge(clk)) then
			if(done1 = '1') then
				if(score1_write_addr < 15) then
					score1_write_addr <= score1_write_addr + 1;
					word_order1(score1_write_addr)  <= STD_LOGIC_VECTOR(to_unsigned(score1_write_addr, Command_Reg_Add_Width));
				else
					score1_write_addr <= 0;
				end if;
			end if;
			
			if(done2 = '1') then
				if(score2_write_addr < 15) then
					score2_write_addr <= score2_write_addr + 1;
					word_order2(score2_write_addr) <= STD_LOGIC_VECTOR(to_unsigned(score2_write_addr, Command_Reg_Add_Width));
				else
					score2_write_addr <= 0;
				end if;
			end if;
			
			if(done3 = '1') then
				if(score3_write_addr < 15) then
					score3_write_addr <= score3_write_addr + 1;
					word_order3(score3_write_addr) <= STD_LOGIC_VECTOR(to_unsigned(score3_write_addr, Command_Reg_Add_Width));
				else
					score3_write_addr <= 0;
				end if;
			end if;
			
			-- ============================================
			-- State Machine
			case current_state is
			
				when S_WAIT =>
					if(score1_write_addr = Total_Commands and score2_write_addr = Total_Commands and score3_write_addr = Total_Commands) then
						current_state <= S_SUB_SORT;
					end if;
					
				when S_SUB_SORT =>
					
					case substate1 is
					
						when S_WAIT =>
							substate1 <= S_LOAD_OUTER;
							substate2 <= S_LOAD_OUTER;
							substate3 <= S_LOAD_OUTER;
							
						when S_LOAD_OUTER =>
							
							score1_smallest_index_vector <= reg1_index1_vector;
							substate1 <= S_DELAY1;
							
							score2_smallest_index_vector <= reg2_index1_vector;
							substate2 <= S_DELAY1;
							
							score3_smallest_index_vector <= reg3_index1_vector;
							substate3 <= S_DELAY1;
							
						when S_DELAY1 =>
							score1_smallest <= reg1_dout;
							substate1 <= S_COMPARE;
							
							score2_smallest <= reg2_dout;
							substate2 <= S_COMPARE;
							
							score3_smallest <= reg3_dout;
							substate3 <= S_COMPARE;
							
						when S_COMPARE =>
							if(reg1_dout_uns < score1_smallest_uns) then
								score1_smallest <= reg1_dout;
								score1_smallest_index_vector <= reg1_index2_vector;
							end if;
							
							substate1 <= S_INC_INDEX2;
							
							if(reg2_dout_uns < score2_smallest_uns) then
								score2_smallest <= reg2_dout;
								score2_smallest_index_vector <= reg2_index2_vector;
							end if;
							
							substate2 <= S_INC_INDEX2;
							
							if(reg3_dout_uns < score3_smallest_uns) then
								score3_smallest <= reg3_dout;
								score3_smallest_index_vector <= reg3_index2_vector;
							end if;
							
							substate3 <= S_INC_INDEX2;
							
						when S_INC_INDEX2 =>
							if(reg1_index2_int < Total_Commands - 1) then
								reg1_index2_int <= reg1_index2_int + 1;
								substate1 <= S_DELAY2;
							else
								substate1 <= S_SWAP1;
							end if;
							
							if(reg2_index2_int < Total_Commands - 1) then
								reg2_index2_int <= reg2_index2_int + 1;
								substate2 <= S_DELAY2;
							else
								substate2 <= S_SWAP1;
							end if;
							
							if(reg3_index2_int < Total_Commands - 1) then
								reg3_index2_int <= reg3_index2_int + 1;
								substate3 <= S_DELAY2;
							else
								substate3 <= S_SWAP1;
							end if;
						
						when S_DELAY2 =>
							substate1 <= S_COMPARE;
							substate2 <= S_COMPARE;
							substate3 <= S_COMPARE;
							
						when S_SWAP1 =>
							
							if(reg1_index1_int /= Total_Commands - 1) then
								word_order1(reg1_index1_int) <= word_order1(score1_smallest_index_int);
								score1_smallest_index_temp <= word_order1(reg1_index1_int);
							end if;
							substate1 <= S_SWAP2;
							
							if(reg2_index1_int /= Total_Commands - 1) then
								word_order2(reg2_index1_int) <= word_order2(score2_smallest_index_int);
								score2_smallest_index_temp <= word_order2(reg2_index1_int);
							end if;
							substate2 <= S_SWAP2;
							
							
							if(reg3_index1_int /= Total_Commands - 1) then
								word_order3(reg3_index1_int) <= word_order3(score3_smallest_index_int);
								score3_smallest_index_temp <= word_order3(reg3_index1_int);
							end if;
							substate3 <= S_SWAP2;
							
						when S_SWAP2 =>
							substate1 <= S_SWAP3;
							score1_temp <= reg1_dout;
							
							substate2 <= S_SWAP3;
							score2_temp <= reg2_dout;
							
							substate3 <= S_SWAP3;
							score3_temp <= reg3_dout;
							
						when S_SWAP3 =>
						
							if(reg1_index1_int /= Total_Commands - 1) then
								word_order1(score1_smallest_index_int) <= score1_smallest_index_temp;
							end if;
							substate1 <= S_DELAY3;
							
							if(reg2_index1_int /= Total_Commands - 1) then
								word_order2(score2_smallest_index_int) <= score2_smallest_index_temp;
							end if;
							substate2 <= S_DELAY3;
							
							if(reg3_index1_int /= Total_Commands - 1) then
								word_order3(score3_smallest_index_int) <= score3_smallest_index_temp;
							end if;
							substate3 <= S_DELAY3;
						
						when S_DELAY3 =>
							substate1 <= S_INC_INDEX1;
							substate2 <= S_INC_INDEX1;
							substate3 <= S_INC_INDEX1;
							
						when S_INC_INDEX1 =>
							if(reg1_index1_int < Total_Commands - 1) then
								reg1_index1_int <= reg1_index1_int + 1;
								reg1_index2_int <= reg1_index1_int + 1;
								substate1 <= S_LOAD_OUTER;
							else
								reg1_index1_int <= 0;
								reg1_index2_int <= 0;
								substate1 <= S_SUB_DONE;
							end if;
							
							if(reg2_index1_int < Total_Commands - 1) then
								reg2_index1_int <= reg2_index1_int + 1;
								reg2_index2_int <= reg2_index1_int + 1;
								substate2 <= S_LOAD_OUTER;
							else
								reg2_index1_int <= 0;
								reg2_index2_int <= 0;
								substate2 <= S_SUB_DONE;
							end if;
							
							if(reg3_index1_int < Total_Commands - 1) then
								reg3_index1_int <= reg3_index1_int + 1;
								reg3_index2_int <= reg3_index1_int + 1;
								substate3 <= S_LOAD_OUTER;
							else
								reg3_index1_int <= 0;
								reg3_index2_int <= 0;
								substate3 <= S_SUB_DONE;
							end if;
							
						when S_SUB_DONE =>
							current_state <= S_WEIGHTING;
							
							substate1 <= S_DELAY1;
							substate2 <= S_DELAY1;
							substate3 <= S_DELAY1;
						
						when others =>
					end case;
					
				
				when S_WEIGHTING =>
					
					case substate1 is
					
						when S_DELAY1 =>
							substate1 <= S_DELAY2;
							substate2 <= S_DELAY2;
							substate3 <= S_DELAY2;
						
						when S_DELAY2 =>
							score1_temp <=	reg1_dout;
							score2_temp <=	reg2_dout;
							score3_temp <= reg3_dout;
							
							word_no_temp1 <=	word_order1(weight_index);
							word_no_temp2 <=	word_order2(weight_index);
							word_no_temp3 <=	word_order3(weight_index);
						
							substate1 <= S_WEIGHT_MULT;
							substate2 <= S_WEIGHT_MULT;
							substate3 <= S_WEIGHT_MULT;
							
						when S_WEIGHT_MULT =>
							score1_temp_ext <=  STD_LOGIC_VECTOR(unsigned(score1_temp) * weight_lut(weight_index));
							score2_temp_ext <=  STD_LOGIC_VECTOR(unsigned(score2_temp) * weight_lut(weight_index));
							score3_temp_ext <=  STD_LOGIC_VECTOR(unsigned(score3_temp) * weight_lut(weight_index));
							
							substate1 <= S_WEIGHT_SLICE;
							substate2 <= S_WEIGHT_SLICE;
							substate3 <= S_WEIGHT_SLICE;
							
						when S_WEIGHT_SLICE =>
							--score1_temp <= score1_temp_ext;
							--score2_temp <= score2_temp_ext;
							--score3_temp <= score3_temp_ext;
							
							
							substate1	<= S_WEIGHT_TRANSFER;
							substate2	<= S_WEIGHT_TRANSFER;
							substate2	<= S_WEIGHT_TRANSFER;
						when S_WEIGHT_TRANSFER =>
						
							if(transfer_counter = 0) then
								transfer_val <= score1_temp_ext;
								transfer_counter <= transfer_counter + 1;
								
								word_order_final(rank_index_int) <= word_no_temp1;
								rank_index_int <= rank_index_int + 1;
							elsif(transfer_counter = 1) then
								transfer_val <= score2_temp_ext;
								transfer_counter <= transfer_counter + 1;
								
								word_order_final(rank_index_int) <= word_no_temp2;
								rank_index_int <= rank_index_int + 1;
							elsif(transfer_counter = 2) then
								transfer_val <= score3_temp_ext;
								transfer_counter <= transfer_counter + 1;
								
								word_order_final(rank_index_int) <= word_no_temp3;
								rank_index_int <= rank_index_int + 1;
							elsif(transfer_counter = 3) then
								transfer_counter <= 0;
								
								if(weight_index < Total_Commands - 1) then
									weight_index <= weight_index + 1;
								
									substate1 <= S_DELAY1;
									substate2 <= S_DELAY2;
									substate3 <= S_DELAY3;
								else
									weight_index <= 0;
									current_state <= S_RANKING;
									substate1 <= S_WAIT;
								end if;
							end if;
						when others =>
					end case;
					
				
				when S_RANKING =>
					case substate1 is
						
						when S_WAIT =>
							substate1 <= S_LOAD_OUTER;
						
						when S_LOAD_OUTER =>
						
							final_score_smallest_index_vector <= final_reg_index1_vector;
							substate1 <= S_DELAY1;
						
						when S_DELAY1 =>
						
							final_reg_smallest <= rank_reg_dout;
							substate1 <= S_COMPARE;
						
						when S_COMPARE =>
						
							if(rank_reg_dout_uns < final_reg_smallest_uns) then
								final_reg_smallest <= rank_reg_dout;
								final_score_smallest_index_vector <= final_reg_index2_vector;
							end if;
							
							substate1 <= S_INC_INDEX2;
						
						when S_INC_INDEX2 =>
							if(final_reg_index2_int < (Total_Commands*3) - 1) then
								final_reg_index2_int <= final_reg_index2_int + 1;
								substate1 <= S_DELAY2;
							else
								substate1 <= S_SWAP1;
							end if;
						
						when S_DELAY2 =>
							substate1 <= S_COMPARE;
						
						when S_SWAP1 =>
							if(final_reg_index1_int /= (Total_Commands*3) - 1) then
								word_order_final(final_reg_index1_int) <= word_order_final(final_score_smallest_index_int);
								final_score_smallest_index_temp <= word_order_final(final_reg_index1_int);
							end if;
							substate1 <= S_SWAP2;
						
						when S_SWAP2 =>
							substate1 <= S_SWAP3;
							final_score_temp <= rank_reg_dout;
						
						when S_SWAP3 =>
							if(final_reg_index1_int /= (Total_Commands*3) - 1) then
								word_order_final(final_score_smallest_index_int) <= final_score_smallest_index_temp;
							end if;
							substate1 <= S_DELAY3;
						
						when S_DELAY3 =>
							substate1 <= S_INC_INDEX1;
						
						when S_INC_INDEX1 =>
							if(final_reg_index1_int < (Total_Commands*3) - 1) then
								final_reg_index1_int <= final_reg_index1_int + 1;
								final_reg_index2_int <= final_reg_index1_int + 1;
								substate1 <= S_LOAD_OUTER;
							else
								final_reg_index1_int <= 0;
								final_reg_index2_int <= 0;
								substate1 <= S_SUB_DONE;
							end if;
							
						when S_SUB_DONE =>
							current_state <= S_DONE;
					
						when others =>
						
					end case;
				
				when S_DONE =>
				
				
				
			end case;
			
		end if;
	end process;
end Behavioral;

