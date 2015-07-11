----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    address_concat - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Receives current requested feature and word for matching algorithms.  Outputs read address of that location to word list.
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


entity address_concat is
    Port ( feature_no : in  STD_LOGIC_VECTOR (4 downto 0);
           word_no : in  STD_LOGIC_VECTOR (9 downto 0);
           address_out : out  STD_LOGIC_VECTOR (Word_List_Add_Width - 1 downto 0));
end address_concat;

architecture Behavioral of address_concat is

begin


end Behavioral;

