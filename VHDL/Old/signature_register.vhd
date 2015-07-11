----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    signature_register - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Stores features from signature extract 1 and 2 and outputs requested features to matching algorithms.
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
use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;


entity signature_register is
    Port ( alg_1_feature_read : in  STD_LOGIC_VECTOR (5 downto 0);  -- Read address from match alg 1
           alg_2_feature_read : in  STD_LOGIC_VECTOR (5 downto 0);  -- Read address from match alg 2
           alg_3_feature_read : in  STD_LOGIC_VECTOR (5 downto 0);  -- Read address from match alg 3
           alg_4_feature_read : in  STD_LOGIC_VECTOR (5 downto 0);  -- Read address from match alg 4
			  command_reg_read : in  STD_LOGIC_VECTOR (5 downto 0);  -- Input Address from training control
           write_data_1 : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data from signature extract 1 
           write_1 : in  STD_LOGIC_VECTOR (5 downto 0);  -- Write address from signature extract 1 
           write_en_1 : in  STD_LOGIC;
           write_data_2 : in  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data from signature extract 2
           write_2 : in  STD_LOGIC_VECTOR (5 downto 0);  -- Write address from signature extract 2
           write_en_2 : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           to_alg_1 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data for match alg 1
           to_alg_2 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data for match alg 2
           to_alg_3 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data for match alg 3
           to_alg_4 : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0);  -- Data for match alg 4
			  to_command_reg : out  STD_LOGIC_VECTOR (Sig_Value_Width - 1 downto 0)  -- Use this output to write data to command register
			  );
end signature_register;

architecture Behavioral of signature_register is

   type ram_type is array (0 to 41) of std_logic_vector(Sig_Value_Width - 1 downto 0);
   signal SIG_FEATURES : ram_type := (others => (others => '0'));


begin

	RamProc: process(sys_clk) is
	begin
		if rising_edge(sys_clk) then
			if (write_en_1 = '1') then
				SIG_FEATURES(to_integer(unsigned(write_1))) <= write_data_1;  -- SIG_FEATURES(0 to 20)
			end if;
			if (write_en_2 = '1') then
				SIG_FEATURES(to_integer(unsigned(write_2))) <= write_data_2;  -- SIG_FEATURES(21 to 41)
			end if;
		-- Read Data Assignments for Match Algorithms
			to_alg_1 <= SIG_FEATURES(to_integer(unsigned(alg_1_feature_read)));  -- Features for Match Algorithm 1.  From SIG_FEATURES(0 to 20)
			to_alg_2 <= SIG_FEATURES(to_integer(unsigned(alg_2_feature_read)));  -- Features for Match Algorithm 2.  From SIG_FEATURES(0 to 20)
			to_alg_3 <= SIG_FEATURES(to_integer(unsigned(alg_3_feature_read)));  -- Features for Match Algorithm 3.  From SIG_FEATURES(21 to 41)
			to_alg_4 <= SIG_FEATURES(to_integer(unsigned(alg_4_feature_read)));  -- Features for Match Algorithm 4.  From SIG_FEATURES(21 to 41)
		-- Read Data Assignments for Command Register
			to_command_reg <= SIG_FEATURES(to_integer(unsigned(command_reg_read)));  -- Features to write to command register.  From SIG_FEATURES(0 to 41)
		end if;
	end process RamProc;


end Behavioral;

