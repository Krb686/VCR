LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_energy_module IS
END tb_energy_module;
 
ARCHITECTURE behavior OF tb_energy_module IS 

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal sample_ready : std_logic := '0';
   signal sample : std_logic_vector(11 downto 0) := (others => '0');
   signal noiseAdjustStart : std_logic := '0';

 	--Outputs
   signal startflag : std_logic;
   signal debug_eAverage : std_logic_vector(15 downto 0);
   signal debug_nAverage : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	type VRAM is array(255 downto 0) of STD_LOGIC_VECTOR(11 downto 0);
	
	signal rIndex : integer := 0;
	
	signal ram : VRAM := (
		x"280", x"27d", x"27e", x"325", x"3a3", x"3ab", x"3e5", x"42a", x"4fb", x"53f", x"567", x"4c8", x"433", x"243", x"23b", x"21f", 
		x"22b", x"25e", x"2c5", x"2ed", x"31f", x"341", x"3b2", x"3d7", x"3f8", x"3ef", x"3d6", x"3b8", x"3b7", x"3bd", x"3c8", x"3aa", 
		x"397", x"395", x"3c7", x"418", x"469", x"4d9", x"4a0", x"491", x"457", x"3db", x"38c", x"32e", x"2d6", x"2c7", x"307", x"395", 
		x"3e9", x"429", x"42b", x"441", x"485", x"48a", x"49d", x"491", x"321", x"28a", x"271", x"279", x"347", x"3b0", x"3e1", x"3e7", 
		x"436", x"53b", x"549", x"586", x"4e5", x"41e", x"240", x"214", x"201", x"222", x"246", x"281", x"302", x"33d", x"37b", x"3ae", 
		x"3df", x"3c4", x"3b1", x"3a3", x"39e", x"39d", x"3a1", x"38d", x"39c", x"397", x"3f8", x"42f", x"462", x"485", x"499", x"48a", 
		x"447", x"429", x"3b3", x"35a", x"316", x"2e7", x"2e3", x"36b", x"3f2", x"43f", x"455", x"44d", x"42b", x"41e", x"444", x"421", 
		x"3f9", x"311", x"2ba", x"284", x"2bc", x"390", x"3e5", x"43d", x"443", x"433", x"453", x"4c9", x"4e1", x"4e9", x"458", x"2e5",
		x"399", x"3a1", x"38f", x"3a0", x"3a3", x"3a5", x"3aa", x"39c", x"39d", x"39f", x"3a5", x"395", x"3a3", x"3a5", x"3a0", x"39c", 
		x"3a3", x"39f", x"3a2", x"3a9", x"3a5", x"3aa", x"39a", x"39e", x"3a1", x"3a2", x"3a7", x"3a8", x"3a6", x"39c", x"3a7", x"3ac", 
		x"39a", x"3af", x"3a1", x"3ab", x"3ab", x"3a9", x"39e", x"3a9", x"3ab", x"3a9", x"3a7", x"3a8", x"3ae", x"3b1", x"3a9", x"3b0", 
		x"3a8", x"3af", x"3af", x"3a4", x"3a3", x"3ab", x"3a7", x"3b1", x"3a8", x"3a2", x"3a7", x"3a6", x"3a5", x"3a9", x"3ab", x"3a3", 
		x"3a1", x"39e", x"3a7", x"3a5", x"39b", x"39f", x"3a4", x"3a2", x"39e", x"399", x"39b", x"39c", x"3aa", x"3a2", x"39b", x"3a0", 
		x"3a8", x"3a6", x"39f", x"399", x"39b", x"3a0", x"399", x"3a1", x"3a6", x"3a5", x"39b", x"3a5", x"3a1", x"3a0", x"3a9", x"3a7", 
		x"3a9", x"3a9", x"3a7", x"3a6", x"3ae", x"3aa", x"3a7", x"3ac", x"3ac", x"3a7", x"3a1", x"3a7", x"39d", x"3ac", x"3b1", x"3a5", 
		x"3ab", x"3a6", x"3af", x"39f", x"3a8", x"3a5", x"3ac", x"3a9", x"3a9", x"3af", x"3ac", x"3a0", x"3af", x"3a7", x"3a9", x"3ab"
		);
 
BEGIN

	sample <= ram(rIndex);
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.energy_module PORT MAP (
          clk => clk,
          rst => rst,
          sample_ready => sample_ready,
          sample => sample,
          noiseAdjustStart => noiseAdjustStart,
          startflag => startflag,
          debug_eAverage => debug_eAverage,
          debug_nAverage => debug_nAverage
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= not clk;
		wait for clk_period / 2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 20 ns;

      -- insert stimulus here 
		rst <= '1';
		wait for 50 ns;
		rst <= '0';
		noiseAdjustStart <= '1';
		wait for 10 ns;
		
		for i in 0 to 511 loop
			-- Sample ready goes high
			sample_ready <= not sample_ready;
			wait for 20 ns;
			-- Sample ready goes low
			sample_ready <= not sample_ready;
			
			if(rIndex < 511) then
				rIndex <= rIndex + 1;
			else
				rIndex <= 0;
			end if;
			
			if(rIndex = 3) then
				noiseAdjustStart <= '0';
			end if;
			wait for 80 ns;
		end loop;
		
		

      wait;
   end process;
	

END;
