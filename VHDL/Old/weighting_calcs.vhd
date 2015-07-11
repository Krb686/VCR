----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    weighting_calcs - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Determines appropriate status and control outputs based on input from Match Results registers
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

entity weighting_calcs is
	Port ( 
		results_1 : in  STD_LOGIC_VECTOR (31 downto 0);
		results_2 : in  STD_LOGIC_VECTOR (31 downto 0);
		results_3 : in  STD_LOGIC_VECTOR (31 downto 0);
		results_4 : in  STD_LOGIC_VECTOR (31 downto 0);
		train_mode : in  STD_LOGIC;		-- Flag from system_cntrl indicating system in training mode.  Evaulate results to determine if new word is Accepted, Too Close or Not A Word.
		next_match_1 : out  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
		--next_match_2 : out  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
		--next_match_3 : out  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
		--next_match_4 : out  STD_LOGIC_VECTOR (MR_reg_add_width - 1 downto 0);
		status : out  STD_LOGIC_VECTOR (2 downto 0);
		control : out  STD_LOGIC_VECTOR (7 downto 0);
		train_result : out  STD_LOGIC_VECTOR (3 downto 0)
	);  -- status of entered word.  determined only in training mode (signals when comparison complete on MSB and status on LSBs: Accepted, Too Close, Not A Word)

end weighting_calcs;
	
architecture Behavioral of weighting_calcs is

begin


end Behavioral;

