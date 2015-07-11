----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    training_cntrl - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: State Machine to change the operating states when in training mode and generate control signals for the user interface.
--
-- Dependencies: system_cntrl, WordCount_Reg, counter_reg
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


entity training_cntrl is
    Port ( CLK : in  STD_LOGIC;
			  Train_On : in  STD_LOGIC;
			  Button_U : in  STD_LOGIC;
			  Button_D : in  STD_LOGIC;
			  Button_S : in  STD_LOGIC;
			  Speech_Flag : in  STD_LOGIC;
--			  total_commands : in integer;
			  Result_Done : in  STD_LOGIC;
			  Result : in  STD_LOGIC_VECTOR (3 downto 0);
			  Train_Done : out  STD_LOGIC;
--			  word_number : out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 7 downto 0);  -- Word number selected by user to add/replace command in Command Register
--			  feature_number : out  STD_LOGIC_VECTOR (5 downto 0);  -- Current Feature to Read From Signature Register and Write to Command Register
--			  command_reg_write_en : out  STD_LOGIC;
			  Display_Train : out STD_LOGIC_VECTOR (Disp_Bits - 1 downto 0);  -- Number of Bits needs to equal (Bits Required to represent all display characters) x Number of Displays/7-Segs.
			  LEDs_Train : out  STD_LOGIC_VECTOR (LEDs - 1 downto 0));
end training_cntrl;

architecture Behavioral of training_cntrl is

	type state is ( Train_Off, Train_Start, Train_Confirm, Train_Speak, Train_NO_Confirm, Train_NO_Word, Train_Processing, Train_Eval_Results, Train_Output, Train_Store_LPCs, Train_Complete );
	signal train_state, train_nxt : state :=Train_Off;
	

	constant Two_Seconds : integer := 200000000;  --(# of clock cycles to create 2 sec. delay. = ClkFreq * DelayPeriod)
--	constant LEDs_Training : STD_LOGIC_VECTOR (3 downto 0) := "0100"; -- Active High: Listen LED | Train LED | Speak LED | other status LEDs
--	constant LEDs_SpeakNow : STD_LOGIC_VECTOR (3 downto 0) := "0110"; -- Active High: Listen LED | Train LED | Speak LED | other status LEDs
--	constant Disp_Bits : integer := 20;   -- Number of Bits needs to equal (Bits Required to represent all display characters) x Number of Displays/7-Segs.
--	constant Disp_Off : STD_LOGIC_VECTOR (Disp_Bits - 1 downto 0);  -- Vector to turn off displays
--	constant Disp_Accepted : STD_LOGIC_VECTOR (Disp_Bits - 1 downto 0);  -- Vector to tell user via displays that word was accepted
--	constant Disp_TooClose : STD_LOGIC_VECTOR (Disp_Bits - 1 downto 0);  -- Vector to tell user via displays that word was too close to existing word
--	constant Disp_NotAWord : STD_LOGIC_VECTOR (Disp_Bits - 1 downto 0);  -- Vector to tell user via displays that word was not understood

begin
-- State Register, Clocked Transitions
process (CLK)
begin
	if rising_edge(CLK) then
		train_state <= train_nxt;
	else
		train_state <= train_state;
	end if;
end process;


-- Next State and Control Signals Output Process
process (train_state, Train_On, Button_U, Button_D, Button_S)
	begin
	
	-- Start All Training Status Bits with a '1'
	Train_Done <= '0';
	Feature_En <= '0';
	Feature_Rst <= '0';
	Word_En <= '0';
	Word_Rst <= '0';
	Result_Request <= <Word_Rank_Top>;
	command_reg_write_en <= '0';
	Display_Train <= Display_OFF;
	LEDs_Train <= LEDs_OFF;
	train_nxt <= train_state;
	
		case pr_state is
			when Train_Off =>
				-- State Variables
				if Train_On = '1' then
					train_nxt <= Train_Start;
				else
					train_nxt <= Train_Off;
				end if;
			
			when Train_Start =>
				-- State Variables
				if Button_S = '1' then
					train_nxt <= Train_Confirm;
				else
					if Button_U = '1' then
						if Word + "01" < Total_Commands then
							Word_Temp <= Word + "01";
						else
							Word_Temp <= Word;
						end if;
					elsif Button_D  = '1' then
						if Word - "01" > Zero then
							Word_Temp <= Word - "01";
						else
							Word_Temp <= Word;
						end if;
					train_nxt <= Train_Start;
					end if;
				end if;
			
			when Train_Confirm =>
				Two_Sec_Count_En <= '1';
				if Confirm_Button = '1' then
					Two_Sec_Count_RST <= '1';
					train_nxt <= Train_Speak;
				elsif Two_Sec_Count_Done = '1' then
					train_nxt <= Train_NO_Confirm;
				else
					train_nxt <= Train_Confirm;
				end if;
				
			when Train_NO_Confirm =>
				Display_Train <= No_Confirmation;
				Train_Done <= '1';
				train_nxt <= Train_Off;			
			
			when Train_Speak =>
				-- State Vars
				Two_Sec_Count_En <= '1';
				if Speech_Flag = '1' then
					Two_Sec_Count_RST <= '1';
					train_nxt <= Train_Processing;
				elsif Two_Sec_Count_Done = '1' then
					train_nxt <= Train_NO_Word;
				else
					train_nxt <= Train_Speak;
				end if;
			
			when Train_NO_Word =>
				Display_Train <= No_Word_Detected;
				Train_Done <= '1';
				train_nxt <= Train_Off;
							
			when Train_Processing =>
				if Result_Done = '1' then
					train_nxt <= Train_Eval_Results;
				else
					train_nxt <= Train_Processing;
				end if;
			
			when Train_Eval_Results =>
				-- State Vars
				if Train_Eval_Condition = '1' then
					train_nxt <= Train_Output;
				else
					train_nxt <= Train_Eval_Results;
				end if;
			
			when Train_Output =>
				Display_Train <= <Result_of_Train_Eval>;
				LEDs_Train <= <Result_of_Train_Eval>;
				if Word_Accepted = '1' then
					train_nxt <= Train_Store_LPCs;
				else
					train_nxt <= Train_Complete;
				end if;
			
			when Train_Store_LPCs =>
				if LPCs_Stored = '1' then
					train_nxt <= Train_Complete;
				else
					train_nxt <= Train_Store_LPCs;
				end if;
			
			when Train_Complete =>
				Train_Done <= '1';
				train_nxt <= Train_Off;			
			
		end case;
	end process;

end Behavioral;

