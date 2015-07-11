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

entity Match_Alg1_Counters is
    Generic (Delay_Width : integer :=4);  -- Bit width for Delay Counter
	 Port ( CLK : in  STD_LOGIC;
			  Features_En, Features_Rst : in  STD_LOGIC;
			  Words_En, Words_Rst : in  STD_LOGIC;
			  Delay_En, Delay_Rst : in  STD_LOGIC;
			  Delay : out STD_LOGIC_VECTOR (Delay_Width - 1 downto 0);
           Feature : out STD_LOGIC_VECTOR (Feature_Add_Width - 1 downto 0);
			  Word : out STD_LOGIC_VECTOR (Command_Reg_Add_Width - 1 downto 0));
end Match_Alg1_Counters;

architecture Behavioral of Match_Alg1_Counters is

begin

-- Delay Counter and Delay Control Signals
	DelayCounter: entity work.Var_Counter
		Generic map( Width => Delay_Width)  -- Bit Width of Counter
		Port map( CLK => CLK, RST => Delay_Rst, EN => Delay_En, Count => Delay);

-- Feature Counter and Feature Control Signals
	FeatureCounter: entity work.Var_Counter
		Generic map( Width => Feature_Add_Width)  -- Bit Width of Counter
		Port map( CLK => CLK, RST => Features_Rst, EN => Features_En, Count => Feature);
	
-- Word Counter and Word Control Signals
	WordCounter: entity work.Var_Counter
		Generic map( Width => Command_Reg_Add_Width)  -- Bit Width of Counter
		Port map( CLK => CLK, RST => Words_Rst, EN => Words_En, Count => Word);

end Behavioral;

