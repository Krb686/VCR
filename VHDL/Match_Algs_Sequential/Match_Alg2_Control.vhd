----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:08 04/02/2015 
-- Design Name: 
-- Module Name:    Match_Alg2_Control - Behavioral 
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

entity Match_Alg2_Control is
    Generic ( Mem_Add_Size : integer :=2; -- Log2(Mem Locations)
				  NUM_OPS : integer :=2);
	 Port (  CLK : in  STD_LOGIC;
				Start : in  STD_LOGIC;
				Feature : in STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
				Word : in STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				A_Mux, B_Mux : out STD_LOGIC_VECTOR (1 downto 0);
				OP_SEL : out STD_LOGIC_VECTOR (NUM_OPS - 1 downto 0);
				Write_Mux, Read_0_Mux, Read_1_Mux : out STD_LOGIC_VECTOR (Mem_Add_Size - 1 downto 0);
				Write_En, Mem_Rst : out STD_LOGIC;
				Features_En, Features_Rst : out  STD_LOGIC;
				Words_En, Words_Rst : out  STD_LOGIC;
				Done : out  STD_LOGIC);
end Match_Alg2_Control;

architecture Behavioral of Match_Alg2_Control is

-- State Types
	type main_states is (Off, OPs_Start, OPs_On, Feat_Status, Feat_Inc, Word_Inc, NobleDave, Set_Done, Memory_Reset);
	signal main_state : main_states := Off;
	
	type OPs_states is (OPs_Off, OPs_Subtract, OPs_Absolute, OPs_Add, OPs_Status);
	signal OPs_state, OPs_Nxt_State : OPs_states := OPs_Off;

-- Internal Control Signals	
	signal Start_Ops, OPs_Done : STD_LOGIC := '0';
	signal Features_Done, Words_Done : STD_LOGIC := '0';
	
-- Constants
	-- Operation Constants
	constant Add : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, NUM_OPS));
	constant Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, NUM_OPS));
	constant Absolute : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, NUM_OPS));
	constant No_Op : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, NUM_OPS));
	
	-- Memory Constants (Locations)
	constant Temp_0_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, Mem_Add_Size));
	constant Temp_1_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, Mem_Add_Size));
	constant Temp_2_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, Mem_Add_Size));
	
	-- Constants for Assinging A, B Operands
	constant Signature_Feature : STD_LOGIC_VECTOR(1 downto 0) :="00";
	constant Word_Feature : STD_LOGIC_VECTOR(1 downto 0) :="01";
	constant Read_Data_0 : STD_LOGIC_VECTOR(1 downto 0) :="10";
	constant Read_Data_1 : STD_LOGIC_VECTOR(1 downto 0) :="11";

begin

-- Main State Process
	process (CLK, main_state, Start, Features_Done, Words_Done)
	begin
		if rising_edge(CLK) then	
			case main_state is
				
				when Off =>
					if Start = '1' then
						main_state <= OPs_Start;
					else
						main_state <= Off;
					end if;
					
				when OPs_Start =>
					main_state <= OPs_On;
					
				when OPs_On =>
					if OPs_Done = '1' then
						main_state <= Feat_Status;
					else
						main_state <= OPs_On;
					end if;
					
				when Feat_Status =>
					if Features_Done = '1' then
						main_state <= Word_Inc;
					else
						main_state <= Feat_Inc;
					end if;
				
				when Feat_Inc =>
					main_state <= OPs_Start;
					
				when Word_Inc =>
					main_state <= NobleDave;
					
				when NobleDave =>
					main_state <= Set_Done;
					
				when Set_Done =>
					main_state <= Memory_Reset;
					
				when Memory_Reset =>
					if Words_Done = '1' then
						main_state <= Off;
					else
						main_state <= OPs_Start;
					end if;
					
			end case;
		end if;
	end process;
	
-- Operations State Reg
	process (CLK, OPs_state, OPs_Nxt_State)
	begin
		if rising_edge(CLK) then	
			OPs_state <= OPs_Nxt_State;
		else
			OPs_state <= OPs_State;
		end if;
	end process;
	
	
-- Operations State Process
	process (OPs_state, Start_Ops)
	begin
	
		A_Mux <= Read_Data_0;
		B_Mux <= Word_Feature;
		OP_SEL <= No_Op;
		Write_Mux  <= Temp_0_Add;
		Write_En  <= '0';
		Read_0_Mux <= Temp_2_Add;
		Read_1_Mux <= Temp_1_Add;
		
		case OPs_state is			
			when OPs_Off =>
				if Start_Ops = '1' then
					OPs_Nxt_State <= OPs_Subtract;
				else
					OPs_Nxt_State <= OPs_Off;
				end if;				
			
			when OPs_Subtract =>
				A_Mux <= Signature_Feature;
				B_Mux <= Word_Feature;
				OP_SEL <= Subtract;
				Write_Mux <= Temp_0_Add;
				Write_En <= '1';
				OPs_Nxt_State <= OPs_Absolute;
				
			when OPs_Absolute =>
				A_Mux <= Read_Data_0;
				OP_SEL <= Absolute;
				Write_Mux <= Temp_1_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= OPs_Add;
				
			when OPs_Add =>
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= Add;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_1_Add;
				Read_1_Mux <= Temp_2_Add;
				OPs_Nxt_State <= OPs_Status;
				
			when OPs_Status =>
				OPs_Nxt_State <= OPs_Off;
			
		end case;
	end process;
	
	-- Main Control Signals
	Start_Ops <= '1' when (main_state = Ops_Start) else '0';
	OPs_Done <= '1' when (OPs_state = OPs_Status) else '0';
	
	Features_En <= '1' when (main_state = Feat_Inc) else '0';
	Features_Rst <= '1' when (main_state = Word_Inc) else '0';
	
	Words_En <= '1' when (main_state = Word_Inc) else '0';
	Words_Rst <= '1' when (main_state = Off and Start = '1') else '0';
	
	Mem_Rst <= '1' when (main_state = Memory_Reset) else '0';
	Done <= '1' when (main_state = Set_Done) else '0';

-- Counter Evaluations
	Features_Done <= '1' when (Feature = STD_LOGIC_VECTOR(TO_UNSIGNED(Num_Features - 1, Feature_Add_Width))) else '0';
	Words_Done <= '1' when (Word = STD_LOGIC_VECTOR(TO_UNSIGNED(Total_Commands, Command_Reg_Add_Width))) else '0';


end Behavioral;
	
	
	