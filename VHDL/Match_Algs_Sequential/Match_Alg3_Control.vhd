----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:08 04/02/2015 
-- Design Name: 
-- Module Name:    Match_Alg3_Control - Behavioral 
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

entity Match_Alg3_Control is
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
				Features_Rst : out  STD_LOGIC;
				Features_Offset : out STD_LOGIC_VECTOR (1 downto 0);
				Words_En, Words_Rst : out  STD_LOGIC;
				Done : out STD_LOGIC);
end Match_Alg3_Control;

architecture Behavioral of Match_Alg3_Control is

-- State Types
	type main_states is (Off, OPs_Start, OPs_On, Feat_Status, Feat_Inc, Word_Inc, NobleDave, Set_Done, Memory_Reset);
	signal main_state : main_states := Off;
	
	type OPs_states is (OPs_Off, Load_Sig, Delta_Sig, Load_Word, Delta_Word, Delta_Dif, Delta_Abs, Delta_Sum, OPs_Status, NobleDave0, NobleDave1, NobleDave2);
	signal OPs_state, OPs_Nxt_State : OPs_states := OPs_Off;

-- Internal Control Signals	
	signal Start_Ops, OPs_Done : STD_LOGIC := '0';
	signal Features_Done, Words_Done : STD_LOGIC := '0';
	
-- Constants
	-- Operation Constants
	constant Add : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, NUM_OPS));
	constant U_Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, NUM_OPS));
	constant S_Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, NUM_OPS));
	constant Absolute : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, NUM_OPS));
	
	-- Memory Constants (Locations)
	constant Temp_0_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, Mem_Add_Size));
	constant Sig_Delta_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, Mem_Add_Size));
	constant Word_Delta_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, Mem_Add_Size));
	constant Delta_Sum_Add : STD_LOGIC_VECTOR(Mem_Add_Size - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, Mem_Add_Size));
	
	-- Constants for Assinging A, B Operands
	constant Signature_Feature : STD_LOGIC_VECTOR(1 downto 0) :="00";
	constant Word_Feature : STD_LOGIC_VECTOR(1 downto 0) :="01";
	constant Read_Data_0 : STD_LOGIC_VECTOR(1 downto 0) :="10";  -- A Mux Operand Only
	constant Zero : STD_LOGIC_VECTOR(1 downto 0) :="10";  -- B Mux Operand Only
	constant Read_Data_1 : STD_LOGIC_VECTOR(1 downto 0) :="11";
	
	-- Constants for Incrimenting Feature Counter
	constant No_Offset : STD_LOGIC_VECTOR (1 downto 0):="00";
	constant Decriment2 : STD_LOGIC_VECTOR (1 downto 0):="01";
	constant Decriment1 : STD_LOGIC_VECTOR (1 downto 0):="10";
	constant Incriment2 : STD_LOGIC_VECTOR (1 downto 0):="11";

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
		B_Mux <= Signature_Feature;
		OP_SEL <= Add;
		Write_Mux  <= Temp_0_Add;
		Write_En  <= '0';
		Read_0_Mux <= Delta_Sum_Add;
		Read_1_Mux <= Sig_Delta_Add;
		Features_Offset <= No_Offset;
		Ops_Done <= '0';
		
		case OPs_state is			
			when OPs_Off =>
				if Start_Ops = '1' then
					OPs_Nxt_State <= Load_Sig;
				else
					OPs_Nxt_State <= OPs_Off;
				end if;				
			
			when Load_Sig =>
				A_Mux <= Signature_Feature;
				B_Mux <= Zero;
				OP_SEL <= Add;
				Write_Mux  <= Temp_0_Add;
				Write_En  <= '1';
				Features_Offset <= Incriment2;
				OPs_Nxt_State <= NobleDave0;
				
			when NobleDave0 =>
				OPs_Nxt_State <= Delta_Sig;
			
			when Delta_Sig =>
				A_Mux <= Read_Data_0;
				B_Mux <= Signature_Feature;
				OP_SEL <= U_Subtract;
				Write_Mux  <= Sig_Delta_Add;
				Write_En  <= '1';
				Read_0_Mux <= Temp_0_Add;
				Features_Offset <= Decriment2;
				OPs_Nxt_State <= NobleDave1;
				
			when NobleDave1 =>
				OPs_Nxt_State <= Load_Word;
			
			when Load_Word =>
				A_Mux <= Word_Feature;
				B_Mux <= Zero;
				OP_SEL <= Add;
				Write_Mux  <= Temp_0_Add;
				Write_En  <= '1';
				Features_Offset <= Incriment2;
				OPs_Nxt_State <= NobleDave2;
				
			when NobleDave2 =>
				OPs_Nxt_State <= Delta_Word;
			
			when Delta_Word =>
				A_Mux <= Read_Data_0;
				B_Mux <= Word_Feature;
				OP_SEL <= U_Subtract;
				Write_Mux  <= Word_Delta_Add;
				Write_En  <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= Delta_Dif;
			
			when Delta_Dif =>
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= S_Subtract;
				Write_Mux  <= Temp_0_Add;
				Write_En  <= '1';
				Read_0_Mux <= Sig_Delta_Add;
				Read_1_Mux <= Word_Delta_Add;
				OPs_Nxt_State <= Delta_Abs;
			
			when Delta_Abs =>
				A_Mux <= Read_Data_0;
				OP_SEL <= Absolute;
				Write_Mux  <= Temp_0_Add;
				Write_En  <= '1';
				Read_0_Mux <= Temp_0_Add;
				OPs_Nxt_State <= Delta_Sum;
			
			when Delta_Sum =>
				A_Mux <= Read_Data_0;
				B_Mux <= Read_Data_1;
				OP_SEL <= Add;
				Write_Mux  <= Delta_Sum_Add;
				Write_En  <= '1';
				Read_0_Mux <= Temp_0_Add;
				Read_1_Mux <= Delta_Sum_Add;
				OPs_Nxt_State <= OPs_Status;
				
			when OPs_Status =>
				Features_Offset <= Decriment1;
				Ops_Done <= '1';
				OPs_Nxt_State <= OPs_Off;
			
		end case;
	end process;
	
	-- Main Control Signals	
	Start_Ops <= '1' when (main_state = Ops_Start) else '0';
	
	Features_Rst <= '1' when (main_state = Word_Inc) else '0';
	
	Words_En <= '1' when (main_state = Word_Inc) else '0';
	Words_Rst <= '1' when (main_state = Off and Start = '1') else '0';
	
	Mem_Rst <= '1' when (main_state = Memory_Reset) else '0';
	Done <= '1' when (main_state = Set_Done) else '0';

-- Counter Evaluations
	Features_Done <= '1' when (Feature = STD_LOGIC_VECTOR(TO_UNSIGNED(Num_Features - 2, Feature_Add_Width))) else '0';
	Words_Done <= '1' when (Word = STD_LOGIC_VECTOR(TO_UNSIGNED(Total_Commands, Command_Reg_Add_Width))) else '0';


end Behavioral;
	
	
	