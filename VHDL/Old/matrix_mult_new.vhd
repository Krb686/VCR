----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:02:27 02/12/2015 
-- Design Name: 
-- Module Name:    matrix_mult - Behavioral 
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

use work.LPC_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity matrix_mult is
generic(	num_coefficients: integer:=1);
port( auto_corr_values: in auto_corr_matrix;
	   coefficient: out multiplicand_type;
		index_k: in integer);
end matrix_mult;

architecture Behavioral of matrix_mult is
signal multiplicand	:	multiplicand_matrix;
signal sum				:	multiplicand_matrix;
signal row: row_and_col_matrix;
signal column: row_and_col_matrix;

type intArray is array (0 to num_coefficients-1) of integer;
signal index	:	intArray;


function revvec (a: in std_logic_vector)
return std_logic_vector is
  variable result: std_logic_vector(a'RANGE);
  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end;

begin

row<=	to_row_and_col(auto_corr_values,1);
column<=	to_row_and_col(auto_corr_values,0);

gen: for i in 0 to num_coefficients -1 generate
	index(i) <=(num_coefficients-1)-abs(i-index_k);
	multiplicand(i)<=(unsigned(column(i)) * unsigned(row((num_coefficients-1)-abs(i-index_k))));
	
	gen2	:	if i=0 generate
		sum(i) <= multiplicand(i);
	end generate;
	
	gen3	:	if i>0 generate
		sum(i) <= (unsigned(sum(i-1)) + unsigned(multiplicand(i)));
	end generate;
end generate gen;
coefficient<=sum(num_coefficients -1);


end Behavioral;

