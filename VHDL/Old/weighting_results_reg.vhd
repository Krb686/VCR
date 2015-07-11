----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    weighting_results_register - register (structural)
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
use IEEE.NUMERIC_STD.ALL;
use work.VCR_Package.ALL;

entity weighting_results_reg is
	GENERIC (
		DW : INTEGER := Command_Reg_Add_Width + 16; 	-- data width, word number + match result score
		AW : INTEGER := 7 	-- address width, 128 slot register file
		);
    Port ( 
          rst   : IN   STD_LOGIC;
			 clk   : IN   STD_LOGIC;
          w_en  : IN   STD_LOGIC;          
          addr  : IN   STD_LOGIC_VECTOR(AW-1 downto 0);
          d_in  : IN   STD_LOGIC_VECTOR(DW-1 downto 0);
          d_out : OUT  STD_LOGIC_VECTOR(DW-1 downto 0)
      );

end weighting_results_reg;
	
architecture structural of weighting_results_reg is
	type registerFile is array(0 to AW-1) of std_logic_vector(DW-1 downto 0);
	signal registers : registerFile := (others => (others => '0'));

begin
	reg_stuff: PROCESS 
	begin
		IF (rst = '1') THEN
			registers <= (OTHERS => (OTHERS =>'0'));	
		ELSE
			IF rising_edge(clk) THEN
				d_out <= registers(to_integer(unsigned(addr)));
				IF (w_en = '1') THEN
					registers(to_integer(unsigned(addr))) <= d_in;
				END IF;
			END IF;
		END IF;
	END PROCESS;
end structural;

