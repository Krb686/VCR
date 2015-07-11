--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:59:11 02/19/2015
-- Design Name:   
-- Module Name:   Z:/scottcarlson On My Mac/Code/SeniorDesign/vhdl-ece492/VHDL Code/SIG_EXT_1/Matrix_test_tb.vhd
-- Project Name:  SIG_EXT_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Matrix_test
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
 use work.LPC_pkg.ALL;
 use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Matrix_test_tb IS
END Matrix_test_tb;
 
ARCHITECTURE behavior OF Matrix_test_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Matrix_test
    PORT(
         Vector : IN  auto_corr_matrix;
         Result : OUT  coeff_matrix
        );
    END COMPONENT;
    

   --Inputs
   signal Vector : auto_corr_matrix := (others=> (others=>'0'));

 	--Outputs
   signal Result : coeff_matrix;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
--   constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Matrix_test PORT MAP (
          Vector => Vector,
          Result => Result
        );

   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
-- 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		vector<=(others=>(others=>'0'));
      wait for 100 ns;	
		Vector<=(std_logic_vector(to_unsigned(3,16+num_samples_per_window)),std_logic_vector(to_unsigned(7,16+num_samples_per_window)),std_logic_vector(to_unsigned(9,16+num_samples_per_window)),std_logic_vector(to_unsigned(10,16+num_samples_per_window)),std_logic_vector(to_unsigned(11,16+num_samples_per_window)),std_logic_vector(to_unsigned(12,16+num_samples_per_window))); 
--      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
