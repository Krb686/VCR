----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:45:57 04/08/2015 
-- Design Name: 
-- Module Name:    Testing_Interface - Behavioral 
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

	-- To Do:
	-- Instantiate Datapath
	-- Add Module to Load and Write from External Memory Source
	-- Create a command register in the datapath
	-- Create UCF
	-- Add Additional Inputs for ADC and UART
	
	-- !!! Not yet tested
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity Testing_Interface is
    Port ( CLK : in  STD_LOGIC;
           Button_S, Button_U, Button_D : in  STD_LOGIC;
           Switches : in  STD_LOGIC_VECTOR (4 downto 0);
           LEDs : out  STD_LOGIC_VECTOR (7 downto 0);
			  SSD_Sel : out  STD_LOGIC_VECTOR (3 downto 0);
           SSD_Data : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  -- ADC signals
			  pmod_sdata : in STD_LOGIC;
			  pmod_ncs : out STD_LOGIC;
			  pmod_sclk : out STD_LOGIC;
			  
			  -- UART
			  uart_tx : out STD_LOGIC;
			  debug_sclk : out STD_LOGIC;
			  debug_clk_781 : out STD_LOGIC;
			  debug_sample_loaded : out STD_LOGIC;
			  debug_uart_tx : out STD_LOGIC);
end Testing_Interface;

architecture Behavioral of Testing_Interface is

	-- Button Signals
	Signal Button_S_Pulse, Button_U_Pulse, Button_D_Pulse : STD_LOGIC;
	
	-- Soft Reset -> Button_U and Button_D;
	signal RST : STD_LOGIC;
	
	-- SSD Display Signals
	signal SEG_0, SEG_1, SEG_2, SEG_3 : std_logic_vector(4 downto 0);
	
	-- Signals from Control
	signal Display : STD_LOGIC_VECTOR (2 downto 0);  -- mux select signal for external display module
	signal Datapath_En : STD_LOGIC;  -- Output to Start Datapath/Start_End_Detect
	signal Command_Reg_Write_En : STD_LOGIC;  -- Output to Enable Writing to Command Register
	signal Feature : STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Address for Command Register Write Add, Sig_Ext_1 Command Register Read Address
	signal Word : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number/Address for Command Register Write Add and Sort_Weight Read Address
	signal Load_Commands_En : STD_LOGIC;  -- Control signal for external module to load command register from external memory source
	signal Write_New_Command : STD_LOGIC;  -- Sent to module to write new command data to external memory source
	signal Commands_Loaded : STD_LOGIC; -- Sent from module that loads command register when it is done
	
	-- Control Inputs from Datapath
	signal LPCs_Done : STD_LOGIC; -- Sent from sig ext 1 when LPCs finish
	signal Start_Detected : STD_LOGIC; -- Sent from speech_detector when speech found
	signal Sort_Weight_Done : STD_LOGIC; -- Sent from sort and weight when it is done
	
	-- Outputs to/from Sort_Weight
	signal Result_Request : integer;  -- Result from sort and weight module
	signal Result : integer;  -- Result from sort and weight module

begin

-- Soft Reset
RST <= Button_U and Button_D;

-- Buttons
Button_S_Debounce: entity work.Debouncer_Test port map ( input => Button_S, rst => '0', clk => CLK, output => Button_S_Pulse );
Button_U_Debounce: entity work.Debouncer_Test port map ( input => Button_U, rst => '0', clk => CLK, output => Button_U_Pulse );
Button_D_Debounce: entity work.Debouncer_Test port map ( input => Button_D, rst => '0', clk => CLK, output => Button_D_Pulse );

-- Module that creates output for 7 Seg Displays
DisplayGen: entity work.Testing_Display_Generator
	port map (
		-- clk      : in    std_logic;
		-- rst 	 : in    std_logic;
		Display => Display, -- in STD_LOGIC_VECTOR (2 downto 0);  -- mux select signal for external display module
		Word => Word, -- in  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number from Control to Display
		Result => Result, -- in integer;  -- Result from sort and weight module
		SEG_0 => SEG_0, -- out    std_logic_vector(4 downto 0);
		SEG_1 => SEG_1, -- out    std_logic_vector(4 downto 0);
		SEG_2 => SEG_2, -- out    std_logic_vector(4 downto 0);
		SEG_3 => SEG_3); -- out    std_logic_vector(4 downto 0));

-- Seven Segments Display Driver
SSD_Driver: entity work.ssd_driver_Test port map (rst => RST, clk => CLK, SEG_0 => SEG_0, SEG_1 => SEG_1,
															SEG_2 => SEG_2, SEG_3 => SEG_3, seg => SSD_Data, an => SSD_Sel);

-- Control Instantiation
Control: entity work.Testing_Cntrl
	Port map(
		CLK => CLK,
		RESET => RST,
		
		-- External Inputs
		Button_S => Button_S_Pulse, Button_U => Button_U_Pulse, Button_D => Button_D_Pulse,
		Switches => Switches(2 downto 0),
		
		-- Output to Start Datapath/Start_End_Detect
		Datapath_En => Datapath_En,
		
		-- Output to Enable Writing to Command Register
		Command_Reg_Write_En => Command_Reg_Write_En,
		
		---------------  Probably Don't Need  ---------------
		-- Output to Reset Datapath Temp Registers before performing a new operation
		-- System_RST : out STD_LOGIC; -- Reset sample memory, LPC register, match_alg registers
		
		-- Outputs for Adding Commands - Selected Word and Features
		Feature => Feature,  -- out  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Address for Command Register Write Add, Sig_Ext_1 Command Register Read Address
		Word => Word,  -- out  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number/Address for Command Register Write Add and Sort_Weight Read Address
		
		-- Status Outputs
		LEDs => LEDs, -- out STD_LOGIC_VECTOR (7 downto 0);  -- send to top level for LED control
		Display => Display,  -- out STD_LOGIC_VECTOR (2 downto 0);  -- mux select signal for external display module
		
		-- Control signal for external module to load command register from external memory source
		Load_Commands_En => Load_Commands_En, -- out STD_LOGIC;
		Write_New_Command => Write_New_Command, -- out STD_LOGIC;  -- Sent to module to write new command data to external memory source
		Commands_Loaded => Commands_Loaded, -- in STD_LOGIC; -- Sent from module that loads command register when it is done
		
		-- Control Inputs from Datapath
		LPCs_Done => LPCs_Done, -- in STD_LOGIC; -- Sent from sig ext 1 when LPCs finish
		Start_Detected => Start_Detected, -- in STD_LOGIC; -- Sent from speech_detector when speech found
		Sort_Weight_Done => Sort_Weight_Done -- in STD_LOGIC -- Sent from sort and weight when it is done
		
		-----------  Probably Don't Need -> Output Read Address to Sort_Weight for gettig results
			-- weight_addr_sel : out STD_LOGIC;  -- Done with Word!!!!!
			-- Result : in INTEGER;	-- Send directly to Testing_Display_Generator!!!!!
		);

-- Datapth Instantiation
	Datapath: entity work.Testing_Datapath
    Port map (	CLK => CLK, -- in 	STD_LOGIC;
				Start => Datapath_En,
				Start_sim => '0', -- in 	STD_LOGIC;
				RST => RST,
				Rst_sim => '0', -- in	STD_LOGIC;
				threshold_up => '0', -- in STD_LOGIC;
				threshold_down => '0', -- in STD_LOGIC;
				uart_ctl => Switches(4 downto 3), -- in STD_LOGIC_VECTOR(1 downto 0);
			  
				-- ADC signals
				pmod_sdata => pmod_sdata, -- in STD_LOGIC;
				pmod_ncs => pmod_ncs, -- out STD_LOGIC;
				pmod_sclk => pmod_sclk, -- out STD_LOGIC;
				
				-- UART
				uart_tx => uart_tx, -- out STD_LOGIC;
				debug_sclk => debug_sclk, -- out STD_LOGIC;
				debug_clk_781 => debug_clk_781, -- out STD_LOGIC;
				debug_sample_loaded => debug_sample_loaded, -- out STD_LOGIC;
				debug_uart_tx => debug_uart_tx, -- : out STD_LOGIC;
				
				-- Control Inputs and Outputs
				Command_Reg_Write_En => Command_Reg_Write_En, --in STD_LOGIC;  -- Output to Enable Writing to Command Register
				Control_Feature => Feature, --in STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);  -- Feature Address for Command Register Write Add, Sig_Ext_1 Command Register Read Address
				Control_Word => Word, --in STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);  -- Word Number/Address for Command Register Write Add and Sort_Weight Read Address
				Final_results_rank_request => Result_Request,
			 	Result => Result -- out Integer (From Sort & Weight);
           );

Result_Request <= to_integer(unsigned(word));

end Behavioral;

