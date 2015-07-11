----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    sorting_algorithm - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: 	Finds the proper location for the incoming score and places in the sor register, each placement takes 11 clock cycles.
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

entity sorting_algorithm is
    Port ( 
	    	clk 		 : in  STD_LOGIC;
			rst      	 : in  STD_LOGIC;
	    	word_no_in 	 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width-1 downto 0);							--input data; the currently scored word
			score_in	 : in  STD_LOGIC_VECTOR (Score_width-1 downto 0);
			start_sort   : in  STD_LOGIC;											--signals when to start the sorting operation on the current input
			data_reg	 : in  STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0);	--data from downstream register, [ word | score ]
			dest_address : out STD_LOGIC_VECTOR (sort_addr_width - 1 downto 0);	--address of read/write for downstream register
			dest_data  	 : out STD_LOGIC_VECTOR (Command_Reg_Add_Width + Score_width-1 downto 0);	--data for downstream register, [ word | score ]
			dest_wen	 : out STD_LOGIC; 									--write enable for downstream register
			ready_flag 	 : out STD_LOGIC; 		 									--alert preceeding and following modules of done status		
			done_flag    : out STD_LOGIC	
		);
end sorting_algorithm;

architecture mixed of sorting_algorithm is
	TYPE SORT_STATES IS (ready, find_position);--, insert);
	SIGNAL STATE : SORT_STATES := ready;

	SIGNAL bit_under_review : INTEGER := sort_addr_width-1; 
	SIGNAL address_mod 		: STD_LOGIC_VECTOR (sort_addr_width +1 downto 0);
	SIGNAL target_add 		: STD_LOGIC_VECTOR (sort_addr_width +1 downto 0);	--target insertion address
	SIGNAL score_comp		: STD_LOGIC_VECTOR (Score_width-1 downto 0);
	SIGNAL GL_flag			: STD_LOGIC; --debug value alerts when incoming is greater than compare score

BEGIN
	score_comp  <= data_reg(Score_width-1 downto 0);	--extract the score from the register data requested
	dest_data 	<= word_no_in & score_in;
	dest_address <= target_add(target_add'LENGTH -2 downto 1);

SORTER: PROCESS (clk, start_sort)
BEGIN
	IF (rst = '1') THEN		--reset state
		ready_flag   <= '1';
		dest_wen 	 <= '0';
		bit_under_review <= target_add'LENGTH - 1;
		target_add <= (target_add'length - 1 => '1', OTHERS => '0');	
		STATE <= ready;
	ELSE	--we're in the operational mode, act on the next clock edge
		IF falling_edge(clk) THEN
			CASE STATE IS
			WHEN ready	=>
				--get ready to the first datapoint to compare our sort algorithm with
				ready_flag   <= '1';
				done_flag    <= '0';
				dest_wen 	 <= '0';				
				bit_under_review <= target_add'LENGTH -1 ;				
				address_mod <= (target_add'LENGTH  -1 => '1', OTHERS => '0');
				target_add  <= (target_add'length - 2 => '1', OTHERS => '0');	
				IF (start_sort = '1') THEN
					state <= find_position;
				END IF;				
			WHEN find_position =>
				ready_flag   <= '0';
				bit_under_review <= bit_under_review-1;				
				address_mod <= '0' & address_mod(address_mod'LENGTH-1 downto 1);--(bit_under_review=>'1', OTHERS =>'0');
				--create the destination read/write address, comparisons are against the last requested data
				IF (address_mod = STD_LOGIC_VECTOR(to_unsigned(0, address_mod'LENGTH))) THEN
					IF (score_in > score_comp)	THEN 					
						target_add <= STD_LOGIC_VECTOR(unsigned(target_add) + to_unsigned(1, address_mod'LENGTH));
					END IF;
					--write the data
					dest_wen 	 <= '1';
					--and reset, wait for next incoming signal
					state <= ready;
					done_flag <= '1';
				ELSE
					IF (score_in < score_comp)	THEN --if less, switch the one we just added 'off'					
						target_add <= (target_add XOR address_mod(address_mod'length-2 downto 0)&'0') OR (address_mod);	--toggle the next bit on --toggle the last bit off
						GL_flag <= '0';
					ELSE
						target_add <= target_add OR address_mod;	--toggle the next bit on
						GL_flag <= '1';
					END IF;			

				END IF;
			
			END CASE;
		END IF;
	END IF;
	END PROCESS;
end mixed;

