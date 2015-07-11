----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:17:00 02/23/2015 
-- Module Name:    dff - Behavioral 
-- Project Name: 	Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Simple D flip flop implementation
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
--use IEEE.NUMERIC_STD.ALL;

use work.VCR_Package.ALL;

entity dff is
	GENERIC (
		DW : INTEGER := 16 	-- data width
		);
    Port ( 
    	clk	: in  STD_LOGIC;
    	rst : in  STD_LOGIC;        
        en  : in  STD_LOGIC;
    	D   : in  STD_LOGIC_VECTOR (DW - 1 downto 0);
        Q   : out STD_LOGIC_VECTOR (DW - 1 downto 0) 
    );
end dff;

architecture Behavioral of dff is
BEGIN
--Q<=D;
    PROCESS 
    BEGIN
       -- IF (rst = '1') THEN            
		--		Q <= (OTHERS => '0');
      --  ELSE
				IF (en = '1') THEN
					IF (clk'EVENT and (clk = '1')) THEN                
                    Q <= D;
                END IF;
				END IF;
      --  END IF;
    END PROCESS;
END Behavioral;