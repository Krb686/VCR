----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:54 03/29/2015 
-- Design Name: 
-- Module Name:    Match_Alg1_OP - Behavioral 
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


entity Match_Alg1_OPs is
    Generic (Width : Integer :=64;  -- Width of Data  *SHOULD BE 2*FEATURE SIZE!!!!!
				 NUM_OPS : Integer :=3);  -- Log2(Number of Operations), Width of OP_SEL signal
    Port ( A : in  STD_LOGIC_VECTOR(Width - 1 downto 0);
           B : in  STD_LOGIC_VECTOR(Width - 1 downto 0);
			  OP_SEL : in  STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0);
			  Y : out  STD_LOGIC_VECTOR(Width - 1 downto 0));
end Match_Alg1_OPs;

architecture Behavioral of Match_Alg1_OPs is

	-- Operation Constants
	constant s_Add : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, NUM_OPS));
	constant s_Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, NUM_OPS));
	constant Divide : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, NUM_OPS));
	constant S_Multiply : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, NUM_OPS));
	constant Absolute : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(4, NUM_OPS));
	constant Increment : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(5, NUM_OPS));
	constant Mem_Reset : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(6, NUM_OPS));
--	constant No_Op : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(7, NUM_OPS));
	
	signal Y_ADD : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_SUB : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_MULT : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_DIV : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_ABS : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_INC : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	constant Zero : STD_LOGIC_VECTOR(Width - 1 downto 0):=(others => '0');
--	constant Twenty : STD_LOGIC_VECTOR(Width - 1 downto 0):=(4 downto 0 => "10100", others => '0');

begin

with OP_SEL select
	Y <= Y_ADD when s_Add,
		  Y_SUB when s_Subtract,
		  Y_DIV when Divide,
		  Y_MULT when S_Multiply,
		  Y_ABS when Absolute,
		  Y_INC when Increment,
		  Zero when Mem_Reset,
		  A when others;  -- For No_Op
		  
	
-- Operations
	-- Add
	Y_ADD <= STD_LOGIC_VECTOR(signed(A) + signed(B));
	
	-- Subract
	Y_SUB <= STD_LOGIC_VECTOR(signed(A) - signed(B));
	
	-- Multiply
	Y_MULT <= STD_LOGIC_VECTOR(signed(A(Width/2 - 1 downto 0)) * signed(B(Width/2 - 1 downto 0)));
	
	-- Divide
--	Y_DIV <= STD_LOGIC_VECTOR(unsigned(A) - to_unsigned(Num_Features, Width));
	Y_DIV <= x"00000000" & A(36 downto 5);
	
	-- Absolute
	Y_ABS <= STD_LOGIC_VECTOR(unsigned(not(A)) + "01") when (A(Width - 1) = '1') else A;
	
	-- Increment
	Y_INC <= STD_LOGIC_VECTOR(unsigned(A) + to_unsigned(1, Width));

end Behavioral;

