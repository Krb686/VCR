----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:35:45 02/19/2015 
-- Design Name: 
-- Module Name:    Matrix_test - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library work;
use work.LPC_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Matrix_test is
port(		Vector: in auto_corr_matrix;
			Result: out coeff_matrix);
end Matrix_test;

architecture Behavioral of Matrix_test is
signal T: auto_corr_matrix;
signal coefficients: coeff_matrix;

component matrix_mult is
generic( num_coefficients: integer);
port( auto_corr_values: in auto_corr_matrix;
	   coefficient: out multiplicand_type;
		index_k: in integer);
end component;

begin

T<=vector;
Result<=coefficients;

GEN:	for i in 0 to num_coefficients-1 generate
			matrix_multx: matrix_mult 	generic map (num_coefficients=>num_coefficients)
												port map (auto_corr_values=>T,coefficient=>coefficients(i),index_k=>i);
		end generate GEN;

end Behavioral;

