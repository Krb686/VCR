----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    12:20 03/29/2015 
-- Module Name:    match_algorithm - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Determines match score for signature feature against word feature.  Outputs final match score for word.
--					 Computes Euclidean Distance of Input Vectors
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


entity Match_Alg1 is
	 Generic (Mem_Add_Size : integer := 3;    -- LOG2(Number of Memory Locations)
				 Mem_Addresses : integer := 8;  -- Number of Memory Locations
				 NUM_OPS : integer := 3;  -- Defines Bit Width for OP_SEL
				 Delay_Width : integer :=4);  -- Bit width for Delay Counter
    Port ( CLK : in  STD_LOGIC;
			  signature_feature : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           word_feature : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           start_signal : in  STD_LOGIC;
           feature_request : out  STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
           word_request : out  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
           done : out  STD_LOGIC;
           match_score : out  STD_LOGIC_VECTOR (Score_width - 1 downto 0);
			  match_word : out  STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0));
end Match_Alg1;

architecture Behavioral of Match_Alg1 is

	-- Constant for Match Word Output
	constant one : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0) := ( 0 => '1', others => '0');
	
	-- Memory Signals
	signal DATA_IN, DATA_OUT_1, DATA_OUT_2 : STD_LOGIC_VECTOR (Sig_Value_Width*2 - 1 downto 0);
	signal WRITE_ADD, READ_ADD_1, READ_ADD_2 : STD_LOGIC_VECTOR (Mem_Add_Size - 1 downto 0);
	signal WRITE_EN, MEM_RST : STD_LOGIC;
	
	-- Operation Signals
	signal Op_A, Op_B : STD_LOGIC_VECTOR(Sig_Value_Width*2 - 1 downto 0);
	signal OP_SEL : STD_LOGIC_VECTOR (NUM_OPS - 1 downto 0);
	
	-- Constants Operand Selection
	constant Signature_Feature_Sel : STD_LOGIC_VECTOR(1 downto 0) :="00";
	constant Word_Feature_Sel : STD_LOGIC_VECTOR(1 downto 0) :="01";
	constant Read_Data_0 : STD_LOGIC_VECTOR(1 downto 0) :="10";
	constant Read_Data_1 : STD_LOGIC_VECTOR(1 downto 0) :="11";
	
	-- O extended inputs of sig feature and word feature
	signal signature_feature_Ext, word_feature_Ext : STD_LOGIC_VECTOR(Sig_Value_Width*2 - 1 downto 0):=(others=>'0');
	
	-- Control Signals
	signal Delay : STD_LOGIC_VECTOR (Delay_Width - 1 downto 0) :=(others => '0');
	signal Feature : STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0) :=(others => '0');
	signal Word : STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0) :=(others => '0');
	signal A_Mux, B_Mux : STD_LOGIC_VECTOR(1 downto 0) :="00";
	signal Delay_En, Delay_Rst : STD_LOGIC;
	signal Features_En, Features_Rst : STD_LOGIC;
	signal Words_En, Words_Rst : STD_LOGIC;
	
begin

-- Local Memory
	LocalMem : entity work.Match_Alg1_Mem
		 Generic map (Width => Sig_Value_Width*2,  -- Width of Data
					 Mem_Add_Size => Mem_Add_Size,  -- LOG2(Number of Memory Locations)
					 N => Mem_Addresses)  -- Number of Memory Locations
		 Port map ( CLK => CLK,
					   RST => MEM_RST,
						DATA_IN => DATA_IN,
					   WRITE_ADD => WRITE_ADD,
					   WRITE_EN => WRITE_EN,
					   READ_ADD_1 => READ_ADD_1,
					   READ_ADD_2 => READ_ADD_2,
					   DATA_OUT_1 => DATA_OUT_1,
					   DATA_OUT_2 => DATA_OUT_2);
						
-- Operation Module
	Operations : entity work.Match_Alg1_OPs
    Generic map ( Width => Sig_Value_Width*2, -- SHOULD BE FEATURE SIZE*2!!!!!
						NUM_OPS => NUM_OPS) -- Integer :=3)  -- Log2(Number of Operations), Width of OP_SEL signal
    Port map ( A => Op_A, -- in  STD_LOGIC_VECTOR(Width - 1 downto 0)
					B => Op_B, -- in  STD_LOGIC_VECTOR(Width - 1 downto 0)
					OP_SEL => OP_SEL, -- in  STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0)
					Y => DATA_IN); -- out  STD_LOGIC_VECTOR(Width - 1 downto 0)

-- Controller
	Control : entity work.Match_Alg1_Control
    Generic map ( Mem_Add_Size => Mem_Add_Size, -- Log2(Mem Locations)
						NUM_OPS => NUM_OPS,
						Delay_Width => Delay_Width)
	 Port map ( CLK => CLK,
					Start => start_signal,
					Feature => Feature, -- in STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
					Word => Word, -- in STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0);
					Delay => Delay,
					A_Mux => A_Mux, -- 
					B_Mux => B_Mux, --
					OP_SEL => OP_SEL, -- out STD_LOGIC_VECTOR (NUM_OPS - 1 downto 0);
					Write_Mux => WRITE_ADD, -- 
					Read_0_Mux => READ_ADD_1, -- 
					Read_1_Mux => READ_ADD_2, -- out STD_LOGIC_VECTOR (Mem_Add_Size - 1 downto 0);
					Write_En => Write_En, -- 
					Mem_Rst => Mem_Rst, -- out STD_LOGIC;
					Delay_En => Delay_En,
					Delay_Rst => Delay_Rst,
					Features_En => Features_En, -- 
					Features_Rst => Features_Rst, -- out  STD_LOGIC;
					Words_En => Words_En, -- 
					Words_Rst => Words_Rst,
					Done => Done); -- out  STD_LOGIC
					
-- Counters
	Counter_Modules : entity work.Match_Alg1_Counters
    Generic map (Delay_Width => Delay_Width)  -- Bit width for Delay Counter
	 Port map ( CLK => CLK,
					Delay_En => Delay_En, -- 
					Delay_Rst => Delay_Rst, -- out  STD_LOGIC;
					Features_En => Features_En, -- 
					Features_Rst => Features_Rst, -- out  STD_LOGIC;
					Words_En => Words_En, -- 
					Words_Rst => Words_Rst,
					Delay => Delay,
					Feature => Feature, --(Feature_Add_Width - 1 downto 0);
					Word => Word); --(Command_Reg_Add_Width - 1 downto 0));
					
-- A Operand Assignment
	with A_Mux select
		Op_A <= signature_feature_Ext when Signature_Feature_Sel,
				  word_feature_Ext when Word_Feature_Sel,
				  DATA_OUT_1 when Read_Data_0,
				  DATA_OUT_2 when Read_Data_1;
				  
-- B Operand Assignment
	with B_Mux select
		Op_B <= signature_feature_Ext when Signature_Feature_Sel,
				  word_feature_Ext when Word_Feature_Sel,
				  DATA_OUT_1 when Read_Data_0,
				  DATA_OUT_2 when Read_Data_1;
				  
	signature_feature_Ext(Sig_Value_Width - 1 downto 0) <= signature_feature;
	word_feature_Ext(Sig_Value_Width - 1 downto 0) <= word_feature;
	
-- Output Assignment
	feature_request <= Feature;
	word_request <= Word;
	match_word <= STD_LOGIC_VECTOR(unsigned(Word) - unsigned(One));
 
-- Score Register 
	process (CLK, Words_En)
	begin
		if rising_edge(CLK) then
			if words_en = '1' then
				match_score <= DATA_OUT_1(Score_width - 1 downto 0);
			end if;
		end if;
	end process;
	
end Behavioral;

