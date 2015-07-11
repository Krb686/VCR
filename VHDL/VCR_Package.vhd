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

package VCR_Package is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- constants
	constant ADC_Sample_Width 		: integer := 8;	 -- 8 bit sample depth input
	constant ADC_Sample_Rate 		: integer := 8000;	-- samples per second from ADC
	constant Sample_Reg_Add_Width  : integer := 13; -- stores 2 seconds of samples at 8k samples/sec (16k samples)
	constant Sig_Value_Width  		: integer := 32;	-- number of bits needed to represent the value of a feature (LPC value, LPCC value)
	constant Command_Reg_Add_Width 	: integer := 7; -- number of bits needed to represent total number of command words. 7 provides 128 commands.
	constant Feature_Add_Width		: integer := 5;	-- number of bits needed to represent 21 extracted features
	--constant Total_Commands			: integer := (2**Command_Reg_Add_Width);  -- Total number of commands the system can store with specified address size
	constant Total_Commands			: integer := 4;
	constant Num_Features			: integer := 20;	--needs to be adjusted (6 bits gets up to 64 features...), this is the same 
	constant Score_Width 			: integer := 56;	-- length of score results in bits
	constant Score_Width_Ext		: integer := 64;
--	constant Word_list_add_width   	: integer := Command_Reg_Add_Width;	--WHAT IS THE DIFFERENCE BETWEEN THIS AND COMMAND REG?  -- Don't know.  We can get rid of this. -JP
	constant MR_reg_add_width  		: integer := Command_Reg_Add_Width;		-- 10 bit addresses gives 1024 words in list
	constant MR_reg_data_width 		: integer := Score_width + Command_Reg_Add_Width;	-- memory formatted as address = word # [score, 16 bits][link, 10 bits]
	CONSTANT sort_addr_width 		: INTEGER := 5;
	constant Sample_Reg_Length		:	integer := 8192;
	
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end VCR_Package;

package body VCR_Package is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end VCR_Package;
