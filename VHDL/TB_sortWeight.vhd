--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:20:31 03/11/2015
-- Design Name:   
-- Module Name:   D:/Dropbox/_CODE/ece448/VDR_2/TB_sortWeight.vhd
-- Project Name:  VDR_2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sort_and_weight_module
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
USE ieee.numeric_std.ALL;
 
ENTITY TB_sortWeight IS
END TB_sortWeight;
 
ARCHITECTURE behavior OF TB_sortWeight IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
  

   --Inputs
   signal clk : std_logic := '1';
   signal rst : std_logic := '1';
   signal match_score_in_1 : std_logic_vector(15 downto 0) := (others => '0');
   signal match_score_in_2 : std_logic_vector(15 downto 0) := (others => '0');
   signal match_score_in_3 : std_logic_vector(15 downto 0) := (others => '0');
   signal match_score_in_4 : std_logic_vector(15 downto 0) := (others => '0');
   signal word_no_in_1 : std_logic_vector(6 downto 0) := (others => '0');
   signal word_no_in_2 : std_logic_vector(6 downto 0) := (others => '0');
   signal word_no_in_3 : std_logic_vector(6 downto 0) := (others => '0');
   signal word_no_in_4 : std_logic_vector(6 downto 0) := (others => '0');
	signal known_cmd_no : INTEGER := 8;
   signal final_reg_ext_addr_req : INTEGER := 0;

 	--Outputs
   signal final_reg_ext_Dout : INTEGER;
   signal final_best_match : INTEGER;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.sort_and_weight_module PORT MAP (
          clk => clk,
          rst => rst,
          match_score_in_1 => match_score_in_1,
          match_score_in_2 => match_score_in_2,
          match_score_in_3 => match_score_in_3,
          match_score_in_4 => match_score_in_4,
          word_no_in_1 => word_no_in_1,
          word_no_in_2 => word_no_in_2,
          word_no_in_3 => word_no_in_3,
          word_no_in_4 => word_no_in_4,
			 known_cmd_no => known_cmd_no,
          final_reg_ext_addr_req => final_reg_ext_addr_req,
          final_reg_ext_Dout => final_reg_ext_Dout,
          final_best_match => final_best_match
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		rst <= '1';
      wait for clk_period*10;
		rst <= '0';
      -- insert stimulus here 
		for i in 1 to 10 loop
			 word_no_in_1 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
          word_no_in_2 <= std_logic_vector(to_unsigned(i, word_no_in_1'length)); 
          word_no_in_3 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
          word_no_in_4 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
			 
			 match_score_in_1 <= std_logic_vector(to_unsigned(60-i*3, match_score_in_1'length));
          match_score_in_2 <= std_logic_vector(to_unsigned(i*2, match_score_in_1'length));
          match_score_in_3 <= std_logic_vector(to_unsigned(20-i, match_score_in_1'length));
          match_score_in_4 <= std_logic_vector(to_unsigned(i**2, match_score_in_1'length));
			 wait for clk_period*20;
		end loop;
		
		for i in 11 to 20 loop
			 word_no_in_1 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
          word_no_in_2 <= std_logic_vector(to_unsigned(i, word_no_in_1'length)); 
          word_no_in_3 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
          word_no_in_4 <= std_logic_vector(to_unsigned(i, word_no_in_1'length));
			 
			 match_score_in_1 <= std_logic_vector(to_unsigned(i*2, match_score_in_1'length));
          match_score_in_2 <= std_logic_vector(to_unsigned(60-i*3, match_score_in_1'length));
          match_score_in_3 <= std_logic_vector(to_unsigned(20-i, match_score_in_1'length));
          match_score_in_4 <= std_logic_vector(to_unsigned(i**2, match_score_in_1'length));
			 wait for clk_period*20;
		end loop;
		
      wait;
   end process;

END;
