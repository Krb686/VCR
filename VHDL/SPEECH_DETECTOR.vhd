----------------------------------------------------------------------------------
-- Company: GMU
-- Engineers: 	Kevin Briggs, Scott Carlson, Christian Gibbons,	Jason Page,	Antonia Paris & David Wernli
-- 
-- Create Date:    21:14:50 02/13/2015 
-- Module Name:    SPEECH_DETECTOR - Behavioral  
-- Project Name: 	 Vocal Command Recognition Utilizing Parallel Processing of Multiple Confidence-Weighted Algorithms in an FPGA
-- Target Devices: 
-- Description: Takes in samples from ADC.  Stores a small set of the most recent samples.  Algorithms run on samples to determine if speech is present.
--					 If speech is present than speech flag is held high until speech signal is no longer detected.
--					 Write address location is sent to sample register.
--
-- Dependencies: Lots
--
-- Revision: 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity speech_detector is
    Port ( 	clk 					: in  STD_LOGIC;	
				
				-- Buttons
				rst 					: in 	STD_LOGIC;
				rst_sim				: in	STD_LOGIC;
				start					: in 	STD_LOGIC;
				start_sim			: in	STD_LOGIC;
				t_up					: in STD_LOGIC;
				t_down				: in STD_LOGIC;
				
				--Switches
				uart_ctl				: in STD_LOGIC_VECTOR(1 downto 0);
				
				--PMOD
				pmod_sdata			: in  STD_LOGIC;
				pmod_ncs				: out STD_LOGIC;
				pmod_sclk 			: out STD_LOGIC;
				
				
				--BRAM
				bram_read_addr		: in STD_LOGIC_VECTOR(12 downto 0);
				bram_sample_out	: out STD_LOGIC_VECTOR(7 downto 0);
				lpc_en				: out STD_LOGIC;

				--UART
				uart_tx				: out STD_LOGIC;
				
				-- DEBUG IO --
				--debug_NCS			: out STD_LOGIC;
				--debug_SDATA			: out STD_LOGIC;
				debug_SCLK			: out STD_LOGIC;
				debug_CLK_781		: out STD_LOGIC;
				debug_sampleLoaded: out STD_LOGIC;
				debug_UART_TX		: out STD_LOGIC
			);
end speech_detector;

architecture Behavioral of speech_detector is

	--==============================================
	-- CONSTANTS
	------------
	constant compile_mode			: integer := 1;	-- 0 for board, 1 for simulation
	-- Inter-sample spacing --
	constant SAMPLE_DELAY 			: integer := 5;
	constant bram_done_count_max	: integer := 128;
	--==============================================



	
	--==============================================
	-- I/O SIGNALS (BUTTON/SWITCH/LED)
	--------------
	-- Button input and debouncer signals --
	signal debouncerIn	: STD_LOGIC_VECTOR(3 downto 0);
	signal debouncerOut	: STD_LOGIC_VECTOR(3 downto 0);
	signal redOut			: STD_LOGIC_VECTOR(3 downto 0);
	--Clean input signals
	signal t_down_pulse			:	STD_LOGIC;
	signal t_up_pulse				:	STD_LOGIC;
	signal rst_pulse				: 	STD_LOGIC;
	signal start_pulse			: 	STD_LOGIC;
	signal start_sig_sim			:	STD_LOGIC;
	signal rst_sig_sim			:	STD_LOGIC;
	signal detector_done			:	STD_LOGIC;
	--==============================================

	
	

	--==============================================
	--PMOD SIGNALS
	--------------
	signal ncs_signal		:	STD_LOGIC;
	signal sclk_signal	:	STD_LOGIC;
	signal doneSignal 	:	STD_LOGIC;
	signal pmod_fake_bus	:	STD_LOGIC_VECTOR(11 downto 0);
	signal pmod_real_bus	:	STD_LOGIC_VECTOR(11 downto 0);
	signal pmod_bus		:	STD_LOGIC_VECTOR(11 downto 0);
	signal pmod_data_reg	:	STD_LOGIC_VECTOR(11 downto 0);
	signal DATA_REGISTER :	STD_LOGIC_VECTOR(11 downto 0);
	--==============================================
	
	

	
	--==============================================
	--SAMPLE TRACKING SIGNALS
	-- Simple sample count
	signal samplesTaken 			: integer := 0;
	-- Intersample delay counter
	signal sampleDelayCounter 	: integer;
	signal sampleLoaded : STD_LOGIC;
	--==============================================
	
	
	
	
	--==============================================
	--ENERGY MODULE SIGNALS
	signal threshold	: integer range 0 to 4095;
	--signal threshold_hex		: STD_LOGIC_VECTOR(15 downto 0);
	signal threshold_bcd		: STD_LOGIC_VECTOR(15 downto 0);
	--==============================================
	
	
	
	
	--==============================================
	--UART SIGNALS
	signal uart_tx_signal : STD_LOGIC;
	signal uart_din_signal	: STD_LOGIC_VECTOR(11 downto 0);
	signal uart_counter		: STD_LOGIC_VECTOR(11 downto 0);
	--==============================================
	
	
	
	
	--==============================================
	--MCP3301 SIGNALS
	signal mcp_ncs_sig : STD_LOGIC;
	signal mcp_sclk_sig: STD_LOGIC;
	signal mcp_sdata_sig : STD_LOGIC;
	signal mcp_done_sig: STD_LOGIC;
	
	signal mcp_data_bus: STD_LOGIC_VECTOR(11 downto 0);
	--signal mcp_data_reg: STD_LOGIC_VECTOR(11 downto 0);
	--==============================================



	--==============================================
	--BRAM SIGNALS
	signal bram_write_addr		: STD_LOGIC_VECTOR(12 downto 0);
	signal bram_done_count		: integer range 0 to bram_done_count_max - 1;
	signal bram_done				: STD_LOGIC;
	signal bram_done_pulse		: STD_LOGIC;
	signal bram_done_counter_rst: STD_LOGIC;
	signal bram_reg_en			: STD_LOGIC;
	signal bram_addr				: STD_LOGIC_VECTOR(12 downto 0);
	--==============================================
	
	
	
	
	--==============================================
	-- OTHER
	-- Start signals
	-- One is "slow" and one is "fast"
	-- The fast one is checked inside a process with the 100 Mhz clock, and goes HIGH
	-- when the start button press is detected.
	-- Since the slower SCLK (195.3125kHz) is the frequency that samples arrive at and is the frequency of the UART,
	-- the slower signal is set when the faster signal is detected as HIGH, from within the slower process.
	signal start_signal	: STD_LOGIC;
	signal start_signal_fast : STD_LOGIC;
	--Divided Clock
	-- This is the main clock / 128, fed to the PmodMic, which further divides it to 195.3125 kHz
	signal CLK_781 	: STD_LOGIC;
	-- Debug signals --
	signal debug_eAverage		: STD_LOGIC_VECTOR(11 downto 0);
	signal debug_sample_reg_en	: STD_LOGIC_VECTOR(11 downto 0);
	--signal bcd_signal				: STD_LOGIC_VECTOR(15 downto 0);
	signal sample_reg_en_signal	: STD_LOGIC;
	signal data_bus_12	: STD_LOGIC_VECTOR(11 downto 0);
	signal data_bus_8		: STD_LOGIC_VECTOR(7 downto 0);
	--==============================================


begin

	--This signal is for simulation purposes only, and allows bypassing
	--the debouncer/red input chain
	start_sig_sim	<= start_signal	OR start_sim;
	rst_sig_sim		<= rst_pulse		OR rst_sim;

	--threshold_hex <= STD_LOGIC_VECTOR(to_unsigned(threshold, 16));
	


	data_bus_12 <= pmod_data_reg;
						
	lpc_en <= bram_done_pulse;
	
	pmod_bus	<= pmod_real_bus	when compile_mode = 0	else
					pmod_fake_bus;
					
					
	bram_reg_en	<= sample_reg_en_signal AND sclk_signal;
	bram_addr	<=	bram_write_addr	when detector_done = '0'	else
						bram_read_addr;

	-- Debugging Signals ------------------
	--debug_NCS <= ncs_signal;
	debug_SCLK <= sclk_signal;
	debug_sampleLoaded <= sampleLoaded;
	debug_UART_TX <= uart_tx_signal;
	debug_CLK_781 <= CLK_781;
	---------------------------------------
	
	
	-- Button input pulses and debouncer --
	debouncerIn <= t_down & t_up & rst & start;
	t_down_pulse			<= redOut(3);
	t_up_pulse				<= redOut(2);
	rst_pulse 				<= redOut(1);
	start_pulse				<= redOut(0);
	--------------------------------------
	
	
	-- PmodMIC signals --------------------
	pmod_ncs <= ncs_signal;
	pmod_sclk <= sclk_signal;
	--done <= doneSignal;
	--------------------------------------
	
	
	-- UART signals -----------------------
	uart_tx <= uart_tx_signal;
	uart_din_signal	<= data_bus_12 			when	uart_ctl = "00" else
								debug_eAverage			when	uart_ctl = "01" else
								debug_sample_reg_en	when 	uart_ctl = "10" else
								uart_counter;
								
	--uart_din_signal <= 	debug_energy_signal when sample_reg_en_signal = '1' else
		--						x"000";
	---------------------------------------
	
	--sample_reg_en <= sample_reg_en_signal;

	-- PMODmic instantiation
	PMODMIC: entity work.PmodMICRefComp PORT MAP(
		clk => CLK_781,
		rst => rst_sig_sim,
		sdata => pmod_sdata,
		sclk => sclk_signal,
		ncs => ncs_signal,
		DATA => pmod_real_bus,
		start => START_SIGNAL,
		done => doneSignal
	);
	
	
	-- Debouncers
	GEN_DEBOUNCER:
	for i in 0 to 3 generate
		DEBOUNCERX : entity work.DEBOUNCER PORT MAP(
			input => debouncerIn(i),
			clk => clk,
			reset => rst_sig_sim,
			output => debouncerOut(i)
		);
	end generate GEN_DEBOUNCER;
	
	-- REDs
	GEN_RED:
	for i in 0 to 3 generate
		REDX : entity work.RED PORT MAP(
			input => debouncerOut(i),
			clk => clk,
			reset => rst_sig_sim,
			output => redOut(i)
		);
	end generate GEN_RED;
	
	CLOCK_DIVIDER: entity work.CLOCK_DIVIDER PORT MAP(
		RST	=> rst_sig_sim,
		clkIN => clk,
		clkOUT => CLK_781
	);
	
	ENERGY_MODULE: entity work.ENERGY_MODULE PORT MAP(
		clk 						=> SCLK_signal,
		rst 						=> rst_sig_sim,
		sample_ready 			=> sampleLoaded,
		sample_in 				=> data_bus_12,
		threshold_in			=> threshold,
		sample_reg_en			=> sample_reg_en_signal,
		sample_out				=> data_bus_8,
		debug_eAverage			=> debug_eAverage,
		debug_sample_reg_en	=> debug_sample_reg_en
	);
	
	UART: entity work.UART PORT MAP(
		clk => CLK_781,
		rst => rst_sig_sim,
		start_flag => sampleLoaded,
		din => uart_din_signal,
		tx => uart_tx_signal
	);
	
	SAMPLE_PLAYBACK: entity work.SAMPLE_PLAYBACK PORT MAP(
		clk => sclk_signal,
		rst => rst_sig_sim,
		dout => pmod_fake_bus
	);
	
--	SSD_DRIVER: entity work.SSD_DRIVER PORT MAP(
--		HEX0_IN => threshold_bcd(3 downto 0),
--		HEX1_IN => threshold_bcd(7 downto 4),
--		HEX2_IN => threshold_bcd(11 downto 8),
--		HEX3_IN => threshold_bcd(15 downto 12),
--		CLK => clk,
--		RESET => rst_sig_sim,
--		SEG => debug_SEG,
--		AN => debug_AN
--	);
	
--	BIN2BCD: entity work.BIN2BCD PORT MAP(
--		BIN => threshold_hex,
--		BCD => threshold_bcd
--	);
	
--	MCP3301_1: entity work.MCP3301 PORT MAP(
--		clk => SCLK_signal,
--		rst => rst_sig_sim,
--		start => START_SIGNAL,
--		ncs => mcp_ncs_sig,
--		sclk => mcp_sclk_sig,
--		din => mcp_sdata_sig,
--		done => mcp_done_sig,
--		dout => mcp_data_bus
--	);
	
	BRAM_SAMPLE_REG: entity work.BRAM_reg 
	GENERIC MAP (
		AW => 13,
		DW => 8
	)
	PORT MAP(
		clk => clk,
		wen => bram_reg_en,
		addr => bram_addr,
		d_in => data_bus_8,
		d_out => bram_sample_out
	);
	
	--This process runs at the normal clock speed of 100 MHz
	process (CLK, rst_pulse, rst_sig_sim)
	begin
		if(rst_sig_sim = '1') then
			START_SIGNAL_FAST <= '0';
			threshold <= 0;
			bram_done_pulse <= '0';
			detector_done <= '0';
		elsif(rising_edge(CLK)) then
		
			--Begin the first conversion
			if(START_PULSE = '1') then
				if(START_SIGNAL = '0') then
					START_SIGNAL_FAST <= '1';
				end if;
			end if;
			
			if(start_sig_sim = '1') then
				if(START_SIGNAL = '0') then
					START_SIGNAL_FAST <= '1';
				end if;
			end if;
			
			--This is outside the START_PULSE because START_PULSE is low
			-- by the time this needs to run
			if(START_SIGNAL = '1') then
				if(START_SIGNAL_FAST = '1') then
					START_SIGNAL_FAST <= '0';
				end if;
			end if;
			
			if(t_up_pulse = '1') then
				if(threshold + 5 < 4095) then
					threshold <= threshold + 5;
				end if;
			elsif(t_down_pulse = '1') then
				if(threshold - 5 > 0) then
					threshold <= threshold - 5;
				end if;
			end if;
			
			if(threshold = 0) then
				threshold <= 400;
			end if;
			
			if(bram_done = '1') then
				detector_done <= '1';
			end if;
			
			
			if(bram_done = '1' and detector_done = '0') then
				bram_done_pulse <= '1';
			else
				bram_done_pulse <= '0';
			end if;
			
			
			
			
		end if;
	end process;
	
	process (rst_pulse, SCLK_signal, rst_sig_sim)
	begin
		if(rst_sig_sim = '1') then
			samplesTaken <= 0;
			sampleDelayCounter <= 0;
			START_SIGNAL <= '0';
			bram_write_addr <= "0000000000000";
			bram_done_count <= 0;
			bram_done <= '0';
			bram_done_counter_rst <= '1';
			
		elsif(rising_edge(SCLK_signal)) then
			-- This block initiates the transition from the idle state to the shiftIn state
			-- after a predefined delay of SAMPLE_DELAY / 512 SCLK cycles
			
			if(START_SIGNAL_FAST = '1') then
				START_SIGNAL <= '1';
			end if;
			
			
			if(START_SIGNAL = '0') then
				if(samplesTaken > 0) then
					if(detector_done = '0') then
						if(sampleDelayCounter = SAMPLE_DELAY) then
							START_SIGNAL <= '1';
							sampleDelayCounter <= 0;
						else
							sampleDelayCounter <= sampleDelayCounter + 1;
						end if;
					end if;
				end if;
				
				
				if(sampleLoaded = '1') then
					sampleLoaded <= '0';
				end if;
			end if;
			
			-- In the SyncData state - the 12 bit output is placed on the DATA port.
			-- So load the parallel data into a register and return to idle state
			if(doneSignal = '0') then
				if(nCS_signal = '1') then
					if(START_SIGNAL = '1') then
						START_SIGNAL <= '0';
					
						pmod_data_reg <= pmod_bus;
						sampleLoaded <= '1';
					
						samplesTaken <= samplesTaken + 1;
					end if;
				end if;
			end if;
			
			if(sampleLoaded = '1') then
				if(sample_reg_en_signal = '1') then
					if(bram_write_addr = "1111111111111") then
						bram_write_addr <= "0000000000000";
					else
						bram_write_addr <= STD_LOGIC_VECTOR(unsigned(bram_write_addr) + 1);
					end if;
					
					bram_done_counter_rst <= '1';
				else
					if(unsigned(bram_write_addr) > 0) then
						bram_done_counter_rst <= '0';
					end if;
				end if;
				
				
				if(bram_done_counter_rst = '0') then
					if(bram_done_count < bram_done_count_max - 1) then
						bram_done_count <= bram_done_count + 1;
					else
						bram_done_count <= 0;
						bram_done <= '1';
					end if;
				else
					bram_done_count <= 0;
				end if;
				
				
				if(unsigned(uart_counter) < 4095) then
					uart_counter <= STD_LOGIC_VECTOR(unsigned(uart_counter) + 1);
				else
					uart_counter <= x"000";
				end if;
			end if;
			
			if(bram_done = '1') then
				bram_done <= '0';
			end if;
			
			--if(mcp_done_sig = '1') then
			--	mcp_data_reg <= mcp_data_bus;
			--end if;
		
		end if;
	
	
	end process;


end Behavioral;

