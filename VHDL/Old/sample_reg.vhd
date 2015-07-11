----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    sample_reg - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Holds samples of most recent detected speech.  Begins to write data when write_en(controlled by speech flag) is high.
--					 Stores sample in location contained in write_address(controlled by speech detector).
--					 Sends samples stored in read_X_address to read_X_out.
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


entity sample_reg is
    Port ( write_en : in  STD_LOGIC;
           write_address : in STD_LOGIC_VECTOR (Sample_Reg_Add_Width - 1 downto 0);
           samples_in : in  STD_LOGIC_VECTOR (ADC_Sample_Width - 1 downto 0);
           sys_clk : in  STD_LOGIC;
			  read_1_address : in  STD_LOGIC_VECTOR (Sample_Reg_Add_Width - 1 downto 0);
           read_2_address : in  STD_LOGIC_VECTOR (Sample_Reg_Add_Width - 1 downto 0);
           read_1_out : out  STD_LOGIC_VECTOR (ADC_Sample_Width - 1 downto 0);
           read_2_out : out  STD_LOGIC_VECTOR (ADC_Sample_Width - 1 downto 0));
end sample_reg;

architecture Behavioral of sample_reg is

   type ram_type is array (0 to (2**Sample_Reg_Add_Width) - 1 ) of std_logic_vector(ADC_Sample_Width - 1 downto 0);
   signal RAM : ram_type := (others => (others => '0'));

begin

	RamProc: process(sys_clk) is
	begin
		if rising_edge(sys_clk) then
			if (write_en = '1') then
				RAM(to_integer(unsigned(write_address))) <= samples_in;
			end if;
			read_1_out <= ram(to_integer(unsigned(read_1_address)));
			read_2_out <= ram(to_integer(unsigned(read_2_address)));
		end if;
	end process RamProc;

end Behavioral;