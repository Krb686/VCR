----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20 03/29/2015 
-- Design Name: 
-- Module Name:    Control - Behavioral 
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

entity Match_Alg1_Control is
    Generic ( Mem_Add_Size : integer :=3; -- Log2(Mem Locations)
				  NUM_OPS : integer :=3;  -- Bit Width for Op_Sel Signal
				  Delay_Width : integer :=4);  -- Bit Width for Delay Signal
	 Port (  CLK : in  STD_LOGIC;
				Start : in  STD_LOGIC;
				Feature : in STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
				Word : in STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
				Delay : in STD_LOGIC_VECTOR (Delay_Width - 1 downto 0);
				A_Mux, B_Mux : out STD_LOGIC_VECTOR (1 downto 0);
				OP_SEL : out STD_LOGIC_VECTOR (NUM_OPS - 1 downto 0);
				Write_Mux, Read_0_Mux, Read_1_Mux : out STD_LOGIC_VECTOR (Mem_Add_Size - 1 downto 0);
				Write_En, Mem_Rst : out STD_LOGIC;
				Delay_En, Delay_Rst : out  STD_LOGIC;
				Features_En, Features_Rst : out  STD_LOGIC;
				Words_En, Words_Rst : out  STD_LOGIC;
				Done : out  STD_LOGIC);
end Match_Alg1_Control;

architecture Behavioral of Match_Alg1_Control is

-- State Types
	type main_states is (Off, OPs_Start, OPs_On, Word_Inc, NobleDave, Set_Done, Memory_Reset);
	signal main_state : main_states := Off;
	
	type OPs_states is (OPs_Off, Sum_Sig, Sum_Word, Feature_Inc_1,
							  Mean_Sig_Reset, Mean_Sig_Calc, Mean_Word_Reset, Mean_Word_Calc,
							  Sig_Delta, Word_Delta,
							  Covar_Mul, Covar_Sum, Sig_Var_Mul, Sig_Var_Sum, Word_Var_Mul, Word_Var_Sum, Feature_Inc_2,
							  Var_Sig_Delta, Var_Sig_Abs, Var_Word_Delta, Var_Word_Abs, Delta_Sum, OPs_Status,
							  Write_3, Write_4, Write_5);
	signal OPs_state, OPs_Nxt_State : OPs_states := OPs_Off;

-- Internal Control Signals	
	signal Start_Ops, OPs_Done : STD_LOGIC := '0';
	signal Features_Done, Words_Done, Delay_Done : STD_LOGIC := '0';
	
-- Constants
	-- Operation Constants
	constant s_Add : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, NUM_OPS));
	constant s_Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, NUM_OPS));
	constant Divide : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, NUM_OPS));
	constant S_Multiply : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, NUM_OPS));
	constant Absolute : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(4, NUM_OPS));
	constant Increment : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(5, NUM_OPS));
	constant Mem_Reset : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(6, NUM_OPS));
	constant No_Op : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(7, NUM_OPS));
	
	-- Memory Constants (Locations)
	constant Temp_0_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, Mem_Add_Size));
	constant Temp_1_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, Mem_Add_Size));
	constant Temp_2_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, Mem_Add_Size));	
	constant Sig_Mean_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, Mem_Add_Size));
	constant Word_Mean_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(4, Mem_Add_Size));
	constant Covar_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(5, Mem_Add_Size));
	constant Sig_Var_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(6, Mem_Add_Size));
	constant Word_Var_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(7, Mem_Add_Size));
	
	-- Constants for Assinging A, B Operands
	constant Signature_Feature : STD_LOGIC_VECTOR(1 downto 0) :="00";
	constant Word_Feature : STD_LOGIC_VECTOR(1 downto 0) :="01";
	constant Read_Data_0 : STD_LOGIC_VECTOR(1 downto 0) :="10";
	constant Read_Data_1 : STD_LOGIC_VECTOR(1 downto 0) :="11";

begin

-- Main State Process
	process (CLK, main_state, Start, Words_Done)
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
						main_state <= Word_Inc;
					else
						main_state <= OPs_On;
					end if;
					
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
	process (OPs_state, Start_Ops, Delay_Done, Features_Done)
	begin
	
		A_Mux <= Read_Data_0;
		B_Mux <= Read_Data_1;
		OP_SEL <= No_Op;
		Write_Mux <= Temp_2_Add;
		Write_En <= '0';
		Read_0_Mux <= Temp_0_Add;
		Read_1_Mux <= Temp_1_Add;
		Delay_En <= '0';
		Delay_Rst <= '0';
		Features_En <= '0';
		Features_Rst <= '0';
		Ops_Done <= '0';
		
		case OPs_state is			
			when OPs_Off =>
				if Start_Ops = '1' then
					OPs_Nxt_State <= Sum_Sig;
				else
					OPs_Nxt_State <= OPs_Off;
				end if;
				
			when Sum_Sig =>
				A_Mux <= Read_Data_0;
				B_Mux <= Signature_Feature;
				OP_SEL <= S_Add;
				Write_Mux <= Temp_0_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= Sum_Word;
				
			when Sum_Word =>
				A_Mux <= Read_Data_1;
				B_Mux <= Word_Feature;
				OP_SEL <= S_Add;
				Write_Mux <= Temp_1_Add;
				Write_En <= '1';
				Read_1_Mux <= Temp_1_Add;
				Delay_Rst <= '1';
				if Features_Done = '1' then
					OPs_Nxt_State <= Mean_Sig_Reset;
				else
					OPs_Nxt_State <= Feature_Inc_1;
				end if;
				
			when Feature_Inc_1 =>				
				Features_En <= '1';
				OPs_Nxt_State <= Sum_Sig;
				
			when Mean_Sig_Reset =>
				OP_SEL <= Mem_Reset;
				Write_Mux <= Sig_Mean_Add;
				Write_En <= '1';
				OPs_Nxt_State <= Mean_Sig_Calc;
				
			when Mean_Sig_Calc =>
				A_Mux <= Read_Data_0;
				OP_SEL <= Divide;
				Write_Mux <= Sig_Mean_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= Mean_Word_Reset;
				
			when Mean_Word_Reset =>
				Features_RST <= '1';
				OP_SEL <= Mem_Reset;
				Write_Mux <= Word_Mean_Add;
				Write_En <= '1';
				OPs_Nxt_State <= Mean_Word_Calc;
				
			when Mean_Word_Calc =>
				A_Mux <= Read_Data_0;
				OP_SEL <= Divide;
				Write_Mux <= Word_Mean_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_1_Add;
				OPs_Nxt_State <= Sig_Delta;
							
			when Sig_Delta =>
				A_Mux <= Signature_Feature;
				B_Mux <= Read_Data_0;
				OP_SEL <= S_Subtract;
				Write_Mux <= Temp_0_Add;
				Write_En <= '1';
				Read_0_Mux <= Sig_Mean_Add;
				OPs_Nxt_State <= Word_Delta;
				
			when Word_Delta =>	
				A_Mux <= Word_Feature;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Subtract;
				Write_Mux <= Temp_1_Add;
				Write_En <= '1';
				Read_1_Mux <= Word_Mean_Add;
				Delay_Rst <= '1';
				OPs_Nxt_State <= Covar_Mul;
				
			when Covar_Mul =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '0';
				Read_0_Mux <= Temp_0_Add;
				Read_1_Mux <= Temp_1_Add;
				Delay_En <= '1';
				if Delay_Done = '1' then
					OPs_Nxt_State <= Write_3;
				else
					OPs_Nxt_State <= Covar_Mul;
				end if;
				
			when Write_3 =>
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_0_Add;
				Read_1_Mux <= Temp_1_Add;
				OPs_Nxt_State <= Covar_Sum;
				
			when Covar_Sum =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Add;
				Write_Mux <= Covar_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_2_Add;
				Read_1_Mux <= Covar_Add;
				Delay_Rst <= '1';
				OPs_Nxt_State <= Sig_Var_Mul;
				
			when Sig_Var_Mul =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_0;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '0';
				Read_0_Mux <= Temp_0_Add;
				Delay_En <= '1';
				if Delay_Done = '1' then
					OPs_Nxt_State <= Write_4;
				else
					OPs_Nxt_State <= Sig_Var_Mul;
				end if;
				
			when Write_4 =>
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_0;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= Sig_Var_Sum;
				
			when Sig_Var_Sum =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Add;
				Write_Mux <= Sig_Var_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_2_Add;
				Read_1_Mux <= Sig_Var_Add;
				Delay_Rst <= '1';
				OPs_Nxt_State <= Word_Var_Mul;
				
			when Word_Var_Mul =>	
				A_Mux <= Read_Data_1;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '0';
				Read_1_Mux <= Temp_1_Add;
				Delay_En <= '1';
				if Delay_Done = '1' then
					OPs_Nxt_State <= Write_5;
				else
					OPs_Nxt_State <= Word_Var_Mul;
				end if;
				
			when Write_5 =>
				A_Mux <= Read_Data_1;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Multiply;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_1_Mux <= Temp_1_Add;
				OPs_Nxt_State <= Word_Var_Sum;
				
			when Word_Var_Sum =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Add;
				Write_Mux <= Word_Var_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_2_Add;
				Read_1_Mux <= Word_Var_Add;
				if Features_Done = '1' then
					OPs_Nxt_State <= Var_Sig_Delta;
				else
					OPs_Nxt_State <= Feature_Inc_2;
				end if;
				
			when Feature_Inc_2 =>				
				Features_En <= '1';
				OPs_Nxt_State <= Sig_Delta;
				
			when Var_Sig_Delta =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Subtract;
				Write_Mux <= Temp_1_Add;
				Write_En <= '1';
				Read_0_Mux <= Sig_Var_Add;
				Read_1_Mux <= Covar_Add;
				OPs_Nxt_State <= Var_Sig_Abs;
				
			when Var_Sig_Abs =>	
				A_Mux <= Read_Data_0;
				OP_SEL <= Absolute;
				Write_Mux <= Temp_1_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_1_Add;
				OPs_Nxt_State <= Var_Word_Delta;
				
			when Var_Word_Delta =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Subtract;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_0_Mux <= Word_Var_Add;
				Read_1_Mux <= Covar_Add;
				OPs_Nxt_State <= Var_Word_Abs;
				
			when Var_Word_Abs =>	
				A_Mux <= Read_Data_0;
				OP_SEL <= Absolute;
				Write_Mux <= Temp_2_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_2_Add;
				OPs_Nxt_State <= Delta_Sum;			
			
			when Delta_Sum =>	
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Add;
				Write_Mux <= Temp_0_Add;
				Write_En <= '1';
				Read_0_Mux <= Temp_1_Add;
				Read_1_Mux <= Temp_2_Add;
				OPs_Nxt_State <= OPs_Status;		
				
			when OPs_Status =>
				Ops_Done <= '1';
				Features_Rst <= '1';
				OPs_Nxt_State <= OPs_Off;
			
		end case;
	end process;

	
--------------------------------------------------------------------------------------------------------------------
	-- Main Control Signals
	Start_Ops <= '1' when (main_state = Ops_Start) else '0';
	
	Words_En <= '1' when (main_state = Word_Inc) else '0';
	Words_Rst <= '1' when (main_state = Off and Start = '1') else '0';
	
	Mem_Rst <= '1' when (main_state = Memory_Reset) else '0';
	Done <= '1' when (main_state = Set_Done) else '0';

-- Counter Evaluations
	Delay_Done <= '1' when (Delay = "1111") else '0'; -- Delay of 16 Clock Cycles.  May need to modify.
	Features_Done <= '1' when (Feature = STD_LOGIC_VECTOR(TO_UNSIGNED(Num_Features - 1, Feature_Add_Width))) else '0';
	Words_Done <= '1' when (Word = STD_LOGIC_VECTOR(TO_UNSIGNED(Total_Commands, Command_Reg_Add_Width))) else '0';

end Behavioral;