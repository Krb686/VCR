----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    match_results_reg - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Sorts the local match scores from the score register and passes them to weighting calcs
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


entity match_results_reg is
    Port ( write_address_1 : in  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
           data_in_1 : in  STD_LOGIC_VECTOR (31 downto 0);
           write_address_2 : in  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
           data_in_2 : in  STD_LOGIC_VECTOR (31 downto 0);
           write_en : in  STD_LOGIC;
           sys_clk : in  STD_LOGIC;
           read_address : in  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end match_results_reg;

architecture Behavioral of match_results_reg is

begin


end Behavioral;

