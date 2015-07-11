LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_speech_detector IS
END tb_speech_detector;
 
ARCHITECTURE behavior OF tb_speech_detector IS 
 
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal rst_sim : std_logic := '0';
   signal start : std_logic := '0';
   signal start_sim : std_logic := '0';
   signal t_up : std_logic := '0';
   signal t_down : std_logic := '0';
   signal uart_ctl : std_logic_vector(1 downto 0) := (others => '0');
   signal mic_sel : std_logic := '0';
   signal pmod_sdata : std_logic := '0';
   signal mcp_sdata : std_logic := '0';
   signal bram_read_addr : std_logic_vector(12 downto 0) := (others => '0');

 	--Outputs
   signal pmod_ncs : std_logic;
   signal pmod_sclk : std_logic;
   signal mcp_ncs : std_logic;
   signal mcp_sclk : std_logic;
   signal bram_sample_out : std_logic_vector(7 downto 0);
   signal lpc_en : std_logic;
   signal uart_tx : std_logic;
   signal data_bus_8_out : std_logic_vector(7 downto 0);
   signal debug_SCLK : std_logic;
   signal debug_CLK_781 : std_logic;
   signal debug_sampleLoaded : std_logic;
   signal debug_UART_TX : std_logic;
   signal debug_SEG : std_logic_vector(7 downto 0);
   signal debug_AN : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant pmod_sclk_period : time := 10 ns;
   constant mcp_sclk_period : time := 10 ns;
   constant debug_SCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.speech_detector PORT MAP (
          clk => clk,
          rst => rst,
          rst_sim => rst_sim,
          start => start,
          start_sim => start_sim,
          t_up => t_up,
          t_down => t_down,
          uart_ctl => uart_ctl,
          mic_sel => mic_sel,
          pmod_sdata => pmod_sdata,
          pmod_ncs => pmod_ncs,
          pmod_sclk => pmod_sclk,
          mcp_sdata => mcp_sdata,
          mcp_ncs => mcp_ncs,
          mcp_sclk => mcp_sclk,
          bram_read_addr => bram_read_addr,
          bram_sample_out => bram_sample_out,
          lpc_en => lpc_en,
          uart_tx => uart_tx,
          data_bus_8_out => data_bus_8_out,
          debug_SCLK => debug_SCLK,
          debug_CLK_781 => debug_CLK_781,
          debug_sampleLoaded => debug_sampleLoaded,
          debug_UART_TX => debug_UART_TX,
          debug_SEG => debug_SEG,
          debug_AN => debug_AN
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
		rst_sim <= '1';
		wait for 20 ns;
		rst_sim <= '0';
		wait for 20 ns;
		start_sim <= '1';
		wait for 20 ns;
		start_sim <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
