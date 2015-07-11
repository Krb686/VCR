--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:28:31 03/09/2015
-- Design Name:   
-- Module Name:   G:/Desktop/Classes/ECE493/RepoCode/TB_Sample_Register.vhd
-- Project Name:  VCR
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sample_reg
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
 
use work.VCR_Package.ALL;
 
ENTITY TB_Sample_Register IS
END TB_Sample_Register;
 
ARCHITECTURE behavior OF TB_Sample_Register IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sample_reg
    PORT(
         write_en : IN  std_logic;
         write_address : IN  std_logic_vector(Sample_Reg_Add_Width - 1 downto 0);
         samples_in : IN  std_logic_vector(ADC_Sample_Width - 1 downto 0);
         sys_clk : IN  std_logic;
         read_1_address : IN  std_logic_vector(Sample_Reg_Add_Width - 1 downto 0);
         read_2_address : IN  std_logic_vector(Sample_Reg_Add_Width - 1 downto 0);
         read_1_out : OUT  std_logic_vector(ADC_Sample_Width - 1 downto 0);
         read_2_out : OUT  std_logic_vector(ADC_Sample_Width - 1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal write_en : std_logic := '0';
   signal write_address : std_logic_vector(Sample_Reg_Add_Width - 1 downto 0) := (others => '0');
   signal samples_in : std_logic_vector(ADC_Sample_Width - 1 downto 0) := (others => '0');
   signal sys_clk : std_logic := '0';
   signal read_1_address : std_logic_vector(Sample_Reg_Add_Width - 1 downto 0) := (others => '0');
   signal read_2_address : std_logic_vector(Sample_Reg_Add_Width - 1 downto 0) := (others => '0');

 	--Outputs
   signal read_1_out : std_logic_vector(ADC_Sample_Width - 1 downto 0);
   signal read_2_out : std_logic_vector(ADC_Sample_Width - 1 downto 0);

   -- Clock period definitions
   constant sys_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sample_reg PORT MAP (
          write_en => write_en,
          write_address => write_address,
          samples_in => samples_in,
          sys_clk => sys_clk,
          read_1_address => read_1_address,
          read_2_address => read_2_address,
          read_1_out => read_1_out,
          read_2_out => read_2_out
        );

   -- Clock process definitions
   sys_clk_process :process
   begin
		sys_clk <= '0';
		wait for sys_clk_period/2;
		sys_clk <= '1';
		wait for sys_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      write_En <= '0';
      write_address <= x"0000";
		read_1_address <= x"0000";
		read_2_address <= x"0001";
      samples_in <= x"0F";
		wait for sys_clk_period*2;
		
		write_En <= '1';
      write_address <= x"0000";
      samples_in <= x"0F";
		wait for sys_clk_period*1;
		
		write_En <= '0';
		wait for sys_clk_period*2;
		
		write_En <= '1';
      write_address <= x"0001";
      samples_in <= x"F0";
		wait for sys_clk_period*1;
		
		write_En <= '0';
		wait for sys_clk_period*2;
		
		write_En <= '1';
      write_address <= x"0002";
      samples_in <= x"99";
		wait for sys_clk_period*1;
		
		write_En <= '0';
		wait for sys_clk_period*2;
		
		write_En <= '1';
      write_address <= x"0003";
      samples_in <= x"66";
		wait for sys_clk_period*1;
		
		write_En <= '0';
		wait for sys_clk_period*2;
		
		read_1_address <= x"0001";
		read_2_address <= x"0002";
      samples_in <= x"0F";
		wait for sys_clk_period*2;
		
		read_1_address <= x"0002";
		read_2_address <= x"0003";
      samples_in <= x"0F";
		wait for sys_clk_period*2;

      -- insert stimulus here 

      wait;
   end process;

END;
