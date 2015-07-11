LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_vcr_top IS
END tb_vcr_top;
 
ARCHITECTURE behavior OF tb_vcr_top IS 

   --Inputs
   signal CLK 			: std_logic := '0';
   signal Start 		: std_logic := '0';
	signal Start_sim	: std_logic	:= '0';
   signal RST 			: std_logic := '0';
	signal Rst_sim		: std_logic := '0';	
   signal threshold_up : std_logic := '0';
   signal threshold_down : std_logic := '0';
   signal uart_ctl : std_logic_vector(1 downto 0) := (others => '0');
   signal mic_sel : std_logic := '0';
   signal pmod_sdata : std_logic := '0';
   signal mcp_sdata : std_logic := '0';

 	--Outputs
   signal pmod_ncs : std_logic;
   signal pmod_sclk : std_logic;
   signal mcp_ncs : std_logic;
   signal mcp_sclk : std_logic;
   signal uart_tx : std_logic;
   signal debug_led_dout : std_logic_vector(7 downto 0);
   signal debug_sclk : std_logic;
   signal debug_clk_781 : std_logic;
   signal debug_sample_loaded : std_logic;
   signal debug_uart_tx : std_logic;
   signal debug_seg : std_logic_vector(7 downto 0);
   signal debug_an : std_logic_vector(3 downto 0);
   
	
   signal Top_Word : std_logic_vector(6 downto 0);
   signal Confidence : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant CLK_PERIOD : time := 10 ns;
   constant pmod_sclk_period : time := 10 ns;
   constant mcp_sclk_period : time := 10 ns;
   constant debug_sclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.VCR_TOP PORT MAP (
          CLK => CLK,
          Start => Start,
			 start_sim	=> Start_sim,
          RST => RST,
			 Rst_sim	=> Rst_sim,
          threshold_up => threshold_up,
          threshold_down => threshold_down,
          uart_ctl => uart_ctl,
          mic_sel => mic_sel,
          pmod_sdata => pmod_sdata,
          pmod_ncs => pmod_ncs,
          pmod_sclk => pmod_sclk,
          mcp_sdata => mcp_sdata,
          mcp_ncs => mcp_ncs,
          mcp_sclk => mcp_sclk,
          uart_tx => uart_tx,
          debug_led_dout => debug_led_dout,
          debug_sclk => debug_sclk,
          debug_clk_781 => debug_clk_781,
          debug_sample_loaded => debug_sample_loaded,
          debug_uart_tx => debug_uart_tx,
          debug_seg => debug_seg,
          debug_an => debug_an,
          Top_Word => Top_Word,
          Confidence => Confidence
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= not CLK;
		wait for CLK_PERIOD / 2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      Rst_sim <= '1';
		wait for 20 ns;
		Rst_sim <= '0';
		wait for 20 ns;
		Start_sim <= '1';
		wait for 10 ns;
		Start_sim <= '0';



      wait;
   end process;

END;
