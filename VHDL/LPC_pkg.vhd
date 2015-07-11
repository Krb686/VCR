--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.ALL;

package LPC_pkg is

constant num_coefficients:integer:=20;
constant num_samples_per_window:integer:=8191;
constant auto_corr_val_type_size :integer:= 16+integer(ceil(log2(real(num_samples_per_window))));
constant multiplicand_type_size :integer:= 32;


subtype multiplicand_type is unsigned(multiplicand_type_size-1 downto 0);
--subtype auto_corr_val_type is std_logic_vector(16+integer(log2(real(num_samples_per_window)-1 downto 0);
subtype auto_corr_val_type is unsigned(auto_corr_val_type_size-1 downto 0);


type multiplicand_matrix is array(num_coefficients-1 downto 0) of multiplicand_type;
type past_array is array(num_samples_per_window+num_coefficients-1 downto 0) of unsigned(7 downto 0);
type auto_corr_matrix is array(num_coefficients downto 0) of auto_corr_val_type;--needs to be one bigger than row_and_col_matrix
type coeff_matrix is array(num_coefficients -1 downto 0) of multiplicand_type;
type row_and_col_matrix is array(num_coefficients -1 downto 0) of auto_corr_val_type;

type Rsum_array is array(num_samples_per_window-1 downto 0) of auto_corr_val_type;
type R_array is array(num_samples_per_window-1 downto 0) of unsigned(15 downto 0);
type tmp_array is array(num_coefficients-1 downto 0) of multiplicand_matrix;
type atmp_array is array(num_coefficients-1 downto 0) of coeff_matrix;
-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
	function to_row_and_col(signal convertee : in auto_corr_matrix; constant upperlower : in integer) return row_and_col_matrix;

end LPC_pkg;

package body LPC_pkg is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

-- Example 2
function to_row_and_col  (signal convertee : in auto_corr_matrix;
								  constant upperlower : in integer) return row_and_col_matrix is
variable converteetmp : row_and_col_matrix;
  begin
		if upperlower = 1 then
				for i in converteetmp'range loop
				converteetmp(i):=convertee(i+1);
			end loop;
		else
				for i in converteetmp'range loop
				converteetmp(i):=convertee(i);
			end loop;
		end if;
		return converteetmp;
  end to_row_and_col;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end LPC_pkg;
