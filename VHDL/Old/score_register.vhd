----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    score_register - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Stores list of words and their associated match scores.  Input is the output of corresponding matching algorithm.
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
--use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;


entity score_register is
    Port ( word : in  STD_LOGIC_VECTOR (9 downto 0);
           score : in  STD_LOGIC_VECTOR (31 downto 0);
           enable : in  STD_LOGIC;
           word_out : out  STD_LOGIC_VECTOR (9 downto 0);
           score_out : out  STD_LOGIC_VECTOR (31 downto 0));
end score_register;

architecture Behavioral of score_register is

begin


end Behavioral;

