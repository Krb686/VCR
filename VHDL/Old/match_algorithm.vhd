----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
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
--use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;


entity match_algorithm is
    Port ( signature_feature : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           word_feature : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           start_signal : in  STD_LOGIC;
           feature_request : out  STD_LOGIC_VECTOR (4 downto 0);
           word_request : out  STD_LOGIC_VECTOR (9 downto 0);
           done : out  STD_LOGIC;
           match_score : out  STD_LOGIC_VECTOR (31 downto 0));
end match_algorithm;

architecture Behavioral of match_algorithm is

begin


end Behavioral;

