----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    signature_extract_2 - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Receives samples from sample register and calculates LPCCs or possibly a different kind of signature for a spoken word.
--					 Sends current feature magnitude and current feature number to signature register.
--					 feature_complete is pulsed when a feature is complete.  all_complete_flag is pulsed when all features for a word have been extracted.
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


entity signature_extract_2 is
    Port ( sample_in : in  STD_LOGIC_VECTOR (ADC_Sample_Width - 1 downto 0);
           start_calc_flag : in  STD_LOGIC;
           sample_address : out  STD_LOGIC_VECTOR (Sample_Reg_Add_Width - 1 downto 0);
           feature_value : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);
           feature_number : out  STD_LOGIC_VECTOR (4 downto 0);
           feature_complete : out  STD_LOGIC;
           all_complete_flag : out  STD_LOGIC);
end signature_extract_2;

architecture Behavioral of signature_extract_2 is

begin


end Behavioral;

