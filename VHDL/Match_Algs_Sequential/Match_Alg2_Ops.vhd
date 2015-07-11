----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:54:44 04/02/2015 
-- Design Name: 
-- Module Name:    Match_Alg2_Ops - Behavioral 
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

entity Match_Alg2_Ops is
    Generic (Width : Integer :=37;  -- Width of Data  *SHOULD BE FEATURE SIZE + 5!!!!!
				 NUM_OPS : Integer :=2);  -- Log2(Number of Operations), Width of OP_SEL signal
    Port ( A : in  STD_LOGIC_VECTOR(Width - 1 downto 0);
           B : in  STD_LOGIC_VECTOR(Width - 1 downto 0);
			  OP_SEL : in  STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0);
			  Y : out  STD_LOGIC_VECTOR(Width - 1 downto 0));
end Match_Alg2_Ops;

architecture Behavioral of Match_Alg2_Ops is

	-- Operation Constants
	constant Add : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(0, NUM_OPS));
	constant Subtract : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(1, NUM_OPS));
	constant Absolute : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(2, NUM_OPS));
--	constant No_Op : STD_LOGIC_VECTOR(NUM_OPS - 1 downto 0) :=STD_LOGIC_VECTOR(to_unsigned(3, NUM_OPS));
	
	signal Y_ADD : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_SUB : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');
	signal Y_ABS : STD_LOGIC_VECTOR(Width - 1 downto 0) :=(others => '0');

begin

with OP_SEL select
	Y <= Y_ADD when Add,
		  Y_SUB when Subtract,
		  Y_ABS when Absolute,
		  A when others;
		  
-- Operations
	-- Add
	Y_ADD <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
	
	-- Subract
	Y_SUB <= STD_LOGIC_VECTOR(unsigned(A) - unsigned(B));
	
	-- Absolute
	Y_ABS <= STD_LOGIC_VECTOR(unsigned(not(A)) + "01") when (A(Width - 1) = '1') else A;


end Behavioral;

