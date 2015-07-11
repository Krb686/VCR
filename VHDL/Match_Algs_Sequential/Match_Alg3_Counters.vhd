----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:18 04/02/2015 
-- Design Name: 
-- Module Name:    Counters - Behavioral 
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

use work.VCR_Package.ALL;

entity Match_Alg3_Counters is
    Port ( CLK : in  STD_LOGIC;
			  Features_Rst : in  STD_LOGIC;
			  Features_Offset : in  STD_LOGIC_VECTOR(1 downto 0);
			  Words_En, Words_Rst : in  STD_LOGIC;
           Feature : out STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
			  Word : out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0));
end Match_Alg3_Counters;

architecture Behavioral of Match_Alg3_Counters is

begin

-- Feature Counter and Feature Control Signals
	FeatureCounter: entity work.Var_Inc_Counter
		Generic map( Width => Feature_Add_Width)  -- Bit Width of Counter
		Port map( CLK => CLK, RST => Features_Rst, OFFSET => Features_Offset , Count => Feature);
	
-- Word Counter and Word Control Signals
	WordCounter: entity work.Var_Counter
		Generic map( Width => Command_Reg_Add_Width)  -- Bit Width of Counter
		Port map( CLK => CLK, RST => Words_Rst, EN => Words_En, Count => Word);

end Behavioral;

