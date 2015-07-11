----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    04/17/2015 
-- Module Name:    Testing_Cntrl
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: State Machine to control datapath for testing purposes
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


entity Testing_Cntrl is
	Port ( 
		-- SYSTEM IO
		CLK 		: in  STD_LOGIC;
		RESET 		: in  STD_LOGIC;
		
		-- External Inputs
		Button_S, Button_U, Button_D : in  STD_LOGIC;  --for interaction with user
		Switches : in  STD_LOGIC_VECTOR (2 downto 0);		--for interaction with user
		
		-- Output to Start Datapath/Start_End_Detect
		Datapath_En : out  STD_LOGIC;
		
		-- Output to Enable Writing to Command Register
		Command_Reg_Write_En : out  STD_LOGIC;
		
		-- Output to Reset Datapath Temp Registers before performing a new operation
--		System_RST : out STD_LOGIC; -- Reset sample memory, LPC register, match_alg registers
		
		-- Outputs for Adding Commands - Selected Word and Features
		Feature : out  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Address for Command Register Write Add, Sig_Ext_1 Command Register Read Address
		Word : out  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number/Address for Command Register Write Add and Sort_Weight Read Address
		
		-- Status Outputs
		LEDs : out STD_LOGIC_VECTOR (7 downto 0);  -- send to top level for LED control
		Display : out STD_LOGIC_VECTOR (2 downto 0);  -- mux select signal for external display module
		
		-- Control signal for external module to load command register from external memory source
		Load_Commands_En : out STD_LOGIC;
		Write_New_Command : out STD_LOGIC;  -- Sent to module to write new command data to external memory source
		Commands_Loaded : in STD_LOGIC; -- Sent from module that loads command register when it is done
		
		-- Control Inputs from Datapath
		LPCs_Done : in STD_LOGIC; -- Sent from sig ext 1 when LPCs finish
		Start_Detected : in STD_LOGIC; -- Sent from speech_detector when speech found
		Sort_Weight_Done : in STD_LOGIC -- Sent from sort and weight when it is done
		
		-- Output Read Address to Sort_Weight for gettig results
			-- weight_addr_sel : out STD_LOGIC;  -- Done with Word!!!!!
			-- Result : in INTEGER;	-- Send directly to Testing_Display_Generator!!!!!
		);
end Testing_Cntrl;

architecture Behavioral of Testing_Cntrl is

	-- States
	type state is (Mode_Sel,  -- Reset/Initial State.  Wait for mode selection from external inputs.
				   Listening, Processing, Result_Report, Result_Report_Display, Result_Report_Increment,  -- States when testing/listening for utterance
				   Word_Sel, Get_Features, Store_Features, Feature_Increment, Add_Command_Status,  -- States when adding a new command
				   Load_Commands, Load_Commands_Status);  -- States when loading command words from external memory source
	
	-- Signals for State Register
	signal pr_state, nx_state : state :=Mode_Sel;
	
	-- LED Status Constants
	CONSTANT LEDs_OFF : STD_LOGIC_VECTOR (7 downto 0) := "00000000";  -- All LEDs Off
	CONSTANT LEDs_Mode_Sel : STD_LOGIC_VECTOR (7 downto 0) := "00000001";  -- LED 0
	CONSTANT LEDs_Listening : STD_LOGIC_VECTOR (7 downto 0) := "00000010";  -- LED 1
	CONSTANT LEDs_Speech_Detected : STD_LOGIC_VECTOR (7 downto 0) := "00000110";  -- LED 2 & 1
	CONSTANT LEDs_Processing : STD_LOGIC_VECTOR (7 downto 0) := "00000100";  -- LED 2
	CONSTANT LEDs_Result_Report : STD_LOGIC_VECTOR (7 downto 0) := "00001100";  -- LED 3 & 2
	CONSTANT LEDs_Word_Sel : STD_LOGIC_VECTOR (7 downto 0) := "00010000";  -- LED 4
	CONSTANT LEDs_Get_Features : STD_LOGIC_VECTOR (7 downto 0) := "00100000";  -- LED 5
	CONSTANT LEDs_Add_Command_Complete : STD_LOGIC_VECTOR (7 downto 0) := "00110000";  -- LED 5 & 4
	CONSTANT LEDs_Load_Commands : STD_LOGIC_VECTOR (7 downto 0) := "01000000";  -- LED 6
	CONSTANT LEDs_Load_Commands_Complete : STD_LOGIC_VECTOR (7 downto 0) := "11000000";  -- LED 7 & 6
	
	-- Display Constants 7-Segs Data
	CONSTANT Display_Sel_Width : integer :=3;  -- 3 bits allows for Off, 6 Messages and Display Word# in BCD
	CONSTANT Display_Off : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "000";  -- 0 = Display Off
	-- CONSTANT Display_Message_1 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "001";  -- 1 = Display Message 1	
	-- CONSTANT Display_Message_2 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "010";  -- 2 = Display Message 2	
	-- CONSTANT Display_Message_3 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "011";  -- 3 = Display Message 3
	-- CONSTANT Display_Message_4 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "100";  -- 4 = Display Message 4	
	-- CONSTANT Display_Message_5 : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "101";  -- 5 = Display Message 5	
	CONSTANT Display_Result : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "110";  -- 6 = Display Word & Score/100 in BCD
	CONSTANT Display_Word : STD_LOGIC_VECTOR (Display_Sel_Width - 1 downto 0) := "111";  -- 7 = Display Word in BCD
	
	-- Delay Constants
	CONSTANT Delay_Width : integer :=28;
--	CONSTANT One_Second : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) := "0101111101011110000100000000";
--	CONSTANT Two_Second : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) := "1011111010111100001000000000";
	CONSTANT One_Second : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) := "0000000000000000000000001000";
	CONSTANT Two_Second : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) := "0000000000000000000000001111";

	-- Register Signals
	SIGNAL Word_Reg_RST, Word_Reg_En : STD_LOGIC := '0';
	SIGNAL Word_Next, Word_Reg : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0):= (others=>'0');  -- Word Number
	SIGNAL Feature_RST, Feature_En : STD_LOGIC := '0';
	SIGNAL Feature_Reg : STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0):= (others=>'0');  -- Feature Number
	SIGNAL Delay_RST, Delay_En : STD_LOGIC := '0';
	SIGNAL Delay : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) := (others=>'0');  -- 
	
	-- Signals for Mode Selection. Tied to Switches Test=0 | Add=1 | Load=2.
	SIGNAL Test_System, Add_Command, Load_Commands_Sig : STD_LOGIC;
	
	-- Word Register Comparison
	CONSTANT Zero : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0) := (others=>'0');  --
	CONSTANT One : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0) := (0 => '1', others=>'0');  --
	CONSTANT Four : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0) := (2 => '1', others=>'0');  --
	
	-- Constants Dave May Need
	-- CONSTANT READY 		: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT LISTENING 	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT PROCESSING	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT MATCH 		: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT NO_MATCH 	: STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT TRAINING   : STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT TRAIN_COMP : STD_LOGIC_VECTOR (7 downto 0) := x"00";
	-- CONSTANT MATCH_THRESHOLD : INTEGER := 174*3;	--the maximum score which will be considered a positive match

begin

-- External Inputs
	-- Control Mode Selection
	Test_System <= Switches(0);
	Add_Command <= Switches(1);
	Load_Commands_Sig <= Switches(2);
	
-- Registers to store word, feature, delay count
	Word_register : entity work.Var_Register_Rst_En
		Generic map ( Width => Command_Reg_Add_Width )  -- Defines Bit Width of Register
		Port map ( CLK => CLK, RST => Word_Reg_RST, EN => Word_Reg_En, D => Word_Next, Q => Word_REG);

	Feature_register : entity work.Var_Counter
		Generic map ( Width => Feature_Add_Width )  -- Defines Bit Width of Register
		Port map ( CLK => CLK, RST => Feature_RST, EN => Feature_En, Count => Feature_Reg);
		
	Delay_Counter : entity work.Var_Counter
		Generic map ( Width => Delay_Width )  -- Bit Width of Counter
		Port map ( CLK => CLK, RST => Delay_RST, EN => Delay_En, Count => Delay);
		
	-- output assignment
	Feature <= Feature_Reg;
	Word <= Word_Reg;

-- State Register, Clocked Transitions
	process (CLK)
	begin
		if (RESET = '1') then
			pr_state <= Mode_Sel;
		elsif rising_edge(CLK) then
			pr_state <= nx_state;
		end if;
	end process;

-- NX_State and Output Logic
	Testing_Cntrl : process(pr_state, Test_System, Add_Command, Load_Commands_Sig, Button_S, Button_U, Button_D, LPCs_Done, start_detected, Commands_Loaded, Sort_Weight_Done, Delay, Feature_Reg, Word_Reg)
	begin
		-- Default State Conditions
		nx_state <= pr_state;  -- Just to be safe, assign nx_state a value
		Word_Reg_RST <= '0';  -- Internal Register
		Word_Reg_En <= '0';  -- Internal Register
		Word_Next <= Word_Reg;
		Feature_RST <= '0';  -- Internal Register
		Feature_En <= '0';  -- Internal Register
		Delay_RST <= '0';  -- Internal Register
		Delay_En <= '0';  -- Internal Register
		Display <= Display_Off; -- Output for 7_Seg Displays
		LEDs <= LEDs_OFF; -- Constant, Std_logic_Vector
		Datapath_En <= '0';  -- Control Signal to Start Datapath Operations (to Speech_Detector)
--		System_RST <= '0'; -- Reset sample memory, LPC register, match_alg registers
		Load_Commands_En <= '0'; -- Control signal for external module to load command register from external memory source
		Write_New_Command <= '0';  -- Sent to module to write new command data to external memory source
		-- File_Write_En <= '0';  -- Can be used to write status to PC
		-- File_Write_Location <= ;  -- Can be used to write status to PC
		-- File_Write_Data <= ;  -- Can be used to write status to PC
		
		----  Signals Dave may need
		-- data_out <= match_word;
		-- data_sel	<= '0';
		-- stat_sel	<= '0';
		-- weight_addr_sel <= '0';
	
		case pr_state is
		
			when Mode_Sel =>  -- Reset/Initial State.  Wait for mode selection from external inputs.
				LEDs <= LEDs_Mode_Sel;
				Delay_RST <= '1';
				Word_Reg_RST <= '1';
				Feature_RST <= '1';
--				System_RST <= '1'; -- Reset sample memory, LPC register, match_alg registers
				if Add_Command = '1' then
					nx_state <= Word_Sel;
					Word_Reg_RST <= '1';  -- Word_Reg Stores Selected Word Entered by Button Presses when in Word_Sel state.
					-- Datapath_En <= '1';  -- Control Signal to Start Datapath Operations (to Speech_Detector)
				elsif Load_Commands_Sig = '1' then
					nx_state <= Load_Commands;
				elsif Test_System = '1' then
					nx_state <= Listening;
					-- Datapath_En <= '1';  -- Control Signal to Start Datapath Operations (to Speech_Detector)
				else
					nx_state <= Mode_Sel;
				end if;


------------------------  Add Command States  ---------------------------------------
				
			when Word_Sel =>  -- State to choose command word location (buttons Select, Up, Down)
				LEDs <= LEDs_Word_Sel;
				Display <= Display_Word;
				if Button_S = '1' then
					nx_state <= Get_Features;
				elsif Button_U = '1' then
					if std_logic_vector(unsigned(Word_Reg) + "01") < std_logic_vector(to_unsigned(Total_Commands + 8, Command_Reg_Add_Width))  then  -- Need to store Total_Commands Somewhere.
						Word_Next <= std_logic_vector(unsigned(Word_Reg) + "01");  -- Increment Word_Reg if up button pressed
						Word_Reg_En <= '1';
					end if;
				elsif Button_D = '1' then
					if Word_Reg > One then  -- One, constant
						Word_Next <= std_logic_vector(unsigned(Word_Reg) - "01");  -- Decrement Word_Reg if up button pressed
						Word_Reg_En <= '1';
					end if;
				end if;
				
			when Get_Features =>  -- Turn on Datapath, Wait for LPC Module to finish
				LEDs <= LEDs_Get_Features;
				-- Datapath_En <= '1';  -- Control Signal to Start Datapath Operations (to Speech_Detector)
				if LPCs_Done = '1' then
					nx_state <= Store_Features;
					Feature_RST <= '1';
				end if;
				
			when Store_Features =>  -- Store features in Command_Memory/BRAM.  Wait for Feature = Num_Features - 1.
				Command_Reg_Write_En <= '1';
				if Feature_Reg = std_logic_vector(to_unsigned(Num_Features - 1, Feature_Add_Width)) then
					nx_state <= Add_Command_Status;  -- All features Stored, move on.
				else
					nx_state <= Feature_Increment;  -- Alternates Feature Increment and Write Enable.  Allows two clock cycles also.
				end if;
				
			when Feature_Increment =>  -- Increment feature number.  Alternate Feature Increment and Write Enable.
				Feature_En <= '1';
				Command_Reg_Write_En <= '0';
				nx_state <= Store_Features;  -- Always goes back to store_features.  Alternates Feature Increment and Write Enable.  Allows two clock cycles also.

			when Add_Command_Status =>
				LEDs <= LEDs_Add_Command_Complete;
				Delay_En <= '1';
				-- Write LPC values of new command word to word location on memory source
				Write_New_Command <= '1';
				if Delay = One_Second then -- Needs to be long enough for writing to external memory source and to let us know operation was successful via LED.
					nx_state <= Mode_Sel;
				else
					nx_state <= Add_Command_Status;
				end if;

------------------------  Load Command States  ---------------------------------------
					
			when Load_Commands =>
				Load_Commands_En <= '1';  -- Control Signal to Module that writes to BRAM from Memory Source (USB/Flash/PC). Initiates module/process to start.
				LEDs <= LEDs_Load_Commands;
				if (Commands_Loaded = '1') then -- Control Signal from module/process that writes to BRAM from Memory Source (USB/Flash/PC)
												-- 		\-> Commands_Loaded <= '1' when (All Commands Have Been Loaded) else '0';
					nx_state <= Load_Commands_Status;
				else
					nx_state <= Load_Commands;
				end if;
			
			when Load_Commands_Status =>
				Delay_En <= '1';
				LEDs <= LEDs_Load_Commands_Complete;
				if Delay = One_Second then -- Needs to be long enough to let us know operation was successful via LED.
					nx_state <= Mode_Sel;
				else
					nx_state <= Load_Commands_Status;
				end if;

				
------------------------  Listen/Test States  ---------------------------------------	

			when Listening =>
				LEDs <= LEDs_Listening;
				if (start_detected = '1') then
					nx_state <= Processing;
				else
					nx_state <= Listening;
				end if;
				
			when Processing =>
				LEDs <= LEDs_Processing;
				if (Sort_Weight_Done = '1') then	--wait for the done signal from sort/weight/match module
					nx_state <= result_report;
					Word_Reg_RST <= '1';  -- Reset Word Register to 0.
				else
					nx_state <= Processing;
				end if;				

			when Result_Report =>
				LEDs <= LEDs_Result_Report;  -- LED 3 & 2
				if Word_Reg = Four then	-- Display result 0 then 1 then 2 then 3 then stop.
					nx_state <= Mode_Sel;				
				else
					Delay_RST <= '1';
					nx_state <= Result_Report_Display;
				end if;
				
			when Result_Report_Display =>
				Delay_En <= '1';
				Display <= Display_Result;  -- Display Word and Score on 7-Segs
				LEDs <= LEDs_Result_Report;  -- LED 3 & 2
				if (Delay = Two_Second) then	-- Hold in this state for two seconds, so we can observe output
					nx_state <= Result_Report_Increment;				
				else
					nx_state <= Result_Report_Display;
				end if;

			when Result_Report_Increment =>
				Word_Reg_En <= '1';  -- Internal Register
				Word_Next <= std_logic_vector(unsigned(Word_Reg) + "01");  -- Increment Word_Reg
				nx_state <= Result_Report;
				
		end case;
	end process;
	
end Behavioral;
