----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    20:46:00 02/23/2015 
-- Module Name:    reg_with_insert - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: A register with selectable insertion point. Allows updating a sorted list by insertion
--
-- Dependencies: None
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

entity reg_with_insert is
	GENERIC (
		DW : INTEGER := Command_Reg_Add_Width + Score_width; 	-- data width, word number + match result score
		AW : INTEGER := Command_Reg_Add_Width 	-- address width
		);
    Port ( 
    	clk			: in  STD_LOGIC;
    	rst 		: in  STD_LOGIC;
    	address 	: in  STD_LOGIC_VECTOR (AW - 1 downto 0);
    	w_data		: in  STD_LOGIC_VECTOR (DW - 1 downto 0);
    	w_en		: in  STD_LOGIC;
    	data_out_1	: out STD_LOGIC_VECTOR (DW - 1 downto 0)
    	--data_out_2	: out STD_LOGIC_VECTOR (DW - 1 downto 0);	--data_out_2 through 4 used for rapid dumping of list to word-ordered weight register
    	--data_out_3	: out STD_LOGIC_VECTOR (DW - 1 downto 0);
    	--data_out_4	: out STD_LOGIC_VECTOR (DW - 1 downto 0)
    );
end reg_with_insert;

architecture Behavioral of reg_with_insert is
	TYPE insert_block IS ARRAY (0 to 2**AW-1) OF STD_LOGIC_VECTOR(DW - 1 downto 0);
	SIGNAL register_structure : insert_block := (OTHERS => (OTHERS => '1'));

	--TYPE address_decode IS ARRAY (0 to 2**AW-1) OF STD_LOGIC;
	--SIGNAL ff_en : address_decode := (OTHERS => '0');

	--TYPE data_select_muxes IS ARRAY (0 to 2**AW-1) OF STD_LOGIC_VECTOR(DW - 1 downto 0);
	--SIGNAL data_in : data_select_muxes;

BEGIN		

	REG_ACCESS:
	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			--register_structure <= (OTHERS => (OTHERS => '0')); --handled in the flipflops
		ELSE
			IF rising_edge(clk) THEN
				data_out_1 <= register_structure(to_integer(unsigned(address)) + 0 );

				--writing of the register is handled by the above ff_en statements and the attached flip flops
			END IF;
		END IF;
	END PROCESS;
	
	
	contents0 : PROCESS(clk, rst)
	BEGIN
		IF (rising_edge(clk)) AND (w_en = '1') THEN
			IF (address = std_logic_vector(to_unsigned(0, address'LENGTH))) THEN
				register_structure(0) <= w_data;
			END IF;
		END IF;
	END PROCESS;
	
	gen2 : FOR j in 1 to 2**AW-1 GENERATE
	contents : PROCESS(clk, rst)
	BEGIN
		IF (rising_edge(clk)) AND (w_en = '1') THEN
			IF (address = std_logic_vector(to_unsigned(j, address'LENGTH))) THEN
				register_structure(j) <= w_data;
			ELSIF (address < std_logic_vector(to_unsigned(j, address'LENGTH))) THEN
				register_structure(j) <= register_structure(j - 1);
			END IF;
		END IF;
	END PROCESS;
	END GENERATE;
	
end Behavioral;