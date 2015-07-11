--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:05:25 02/24/2015
-- Design Name:   
-- Module Name:   /home/christian/Documents/493/SIG_EXT_1/tb_sig_ext_1.vhd
-- Project Name:  SIG_EXT_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signature_extract_1
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.LPC_pkg.ALL;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_sig_ext_1 IS
END tb_sig_ext_1;
 
ARCHITECTURE behavior OF tb_sig_ext_1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT signature_extract_1
    PORT(
         samples_in : IN  unsigned(7 downto 0);
         start_calc_flag : IN  std_logic;
         sample_address : OUT  std_logic_vector(15 downto 0);
         lpc_feature_value : OUT  coeff_matrix:=(others=>(others=>'0'));
         lpc_feature_number : OUT  std_logic_vector(4 downto 0);
         feature_complete : OUT  std_logic;
         all_complete_flag : OUT  std_logic;
         sample_clock : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal samples_in : unsigned(7 downto 0) := (others => '0');
   signal start_calc_flag : std_logic := '0';
   signal sample_clock : std_logic := '0';

 	--Outputs
   signal sample_address : std_logic_vector(15 downto 0);
   signal lpc_feature_value : coeff_matrix;
   signal lpc_feature_number : std_logic_vector(4 downto 0);
   signal feature_complete : std_logic;
   signal all_complete_flag : std_logic;
   -- Clock period definitions
   constant sample_clock_period : time := 10 ns;
	signal dataread: unsigned(7 downto 0);
	
	function to_sl(b: bit) return std_logic is
	begin
	  if b='1' then
		 return '1';
	  else
		 return '0';
	  end if;
	end;
	
	function to_slv(bv:bit_vector) return std_logic_vector is
	  variable sv: std_logic_vector(bv'RANGE);
	begin
	  for i in bv'RANGE loop
		 sv(i) := to_sl(bv(i));
	  end loop;
	  return sv;
	end;
	
	
	type tmp_type is array (num_coefficients -1 downto 0) of integer;
	signal lpc_feature_values_integer : tmp_type;

	
	function array_contents_to_integer(arr: coeff_matrix) return tmp_type is
		variable coeff_matrixtmp: tmp_type;
	begin
		for i in coeff_matrix'range loop
			coeff_matrixtmp(i):=to_integer(arr(i));
		end loop;
		return coeff_matrixtmp;
	end;
		
	TYPE textfile IS FILE OF string;  -- file of text
   TYPE intfile IS FILE OF integer;  -- file of integers

	FILE datainfile:text OPEN read_mode IS "OPEN.txt";	
	signal datainout: unsigned(7 downto 0);
	
	
	
BEGIN

P:PROCESS

    -- file variables
    VARIABLE vDatainline : line;
    VARIABLE vDatain     : integer;

  BEGIN

    FOR i IN 0 TO num_samples_per_window-1 LOOP                             -- will read all the samples per window
      WAIT UNTIL (sample_clock'event AND sample_clock = '1');      -- on every rising edge..
      readline (datainfile, vDatainline);            -- read a line from input file
      read (vDatainline, vDatain);                   -- read the first 8 bits from the line
      DataInout <= to_unsigned(vDatain,8);       -- send to data input
    END LOOP;
end process;


lpc_feature_values_integer<=array_contents_to_integer(lpc_feature_value);
WRITE_FILE: process (sample_clock)
				  variable linecount : integer:=0;	
				  variable VEC_LINE : line;
				  file VEC_FILE : text is out "OPEN_LPCs.txt";
				begin
				  -- strobe OUT_DATA on falling edges 
				  -- of CLK and write value out to file
				 if sample_clock='0' and feature_complete = '1' then
						linecount:=linecount+1;
						if num_coefficients>linecount then
							write (VEC_LINE, lpc_feature_values_integer(linecount-1));
							writeline (VEC_FILE, VEC_LINE);
						end if;
				  end if;
				end process WRITE_FILE;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: signature_extract_1 PORT MAP (
          samples_in => samples_in,
          start_calc_flag => start_calc_flag,
          sample_address => sample_address,
          lpc_feature_value => lpc_feature_value,
          lpc_feature_number => lpc_feature_number,
          feature_complete => feature_complete,
          all_complete_flag => all_complete_flag,
          sample_clock => sample_clock
        );

 -- Clock process definitions
   sample_clock_process :process
   begin
		sample_clock <= '0';
		wait for sample_clock_period/2;
		sample_clock <= '1';
		wait for sample_clock_period/2;
   end process;



   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.



      -- insert stimulus here 
		start_calc_flag <= '1';
		wait for sample_clock_period;
		start_calc_flag <= '0';
		for i in 0 to num_samples_per_window loop
			samples_in<=DataInOut;	
			wait for sample_clock_period;
		end loop;
      wait;
   end process;

END;
