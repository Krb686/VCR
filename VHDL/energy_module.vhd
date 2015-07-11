library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ENERGY_MODULE is
    Port ( clk 						: in  STD_LOGIC;
           rst 						: in  STD_LOGIC;
			  sample_ready 			: in 	STD_LOGIC;
			  sample_in 				: in  STD_LOGIC_VECTOR(11 downto 0);
			  threshold_in				: in integer;
			  sample_reg_en			: out STD_LOGIC;
			  sample_out				: out STD_LOGIC_VECTOR(7 downto 0);
			  -- Debug IO
			  debug_eAverage			: out STD_LOGIC_VECTOR(11 downto 0);
			  debug_sample_reg_en	: out STD_LOGIC_VECTOR(11 downto 0)
			  );
end energy_module;

--====================================================================================================
--====================================================================================================
architecture Behavioral of ENERGY_MODULE is

	-- Variable size declarations
	--------------------------------------------------
	constant threshold_counter_max	: integer := 128;
	constant input_sample_width		: integer := 12;
	constant output_sample_width		: integer := 8;
	
	-- Vectors
	constant vram_size 					: integer := threshold_counter_max;
	constant vram_element_size 		: integer := 8;
	
	-- Energy
	constant eram_size 					: integer := 128;
	constant eram_element_size 		: integer := 12;
	constant eram_sum_size				: integer := 19;	
	
	--Noise
	--constant nram_size 					: integer := 16;
	--constant nram_element_size 		: integer := 12;
	--constant nram_sum_size				: integer := 16; --16 * 4095(max possible) fits in 16 bits.
	--------------------------------------------------
	
	signal threshold					: integer;

	-- TYPE DECLARATIONS
	----------------------------------------------------------------------
	-- RAM to store raw 12 bit vectors
	type vector_ram 		is array (vram_size - 1 downto 0) 	of STD_LOGIC_VECTOR(vram_element_size - 1 downto 0);
	
	-- RAM to store the energy value of each corresponding sample
	type energy_ram 		is array (eram_size - 1 downto 0) 	of unsigned(eram_element_size - 1 downto 0);
	
	-- RAM to store noise values for offset calculation
	--type noise_ram 		is array (nram_size - 1 downto 0) 	of unsigned(nram_element_size - 1 downto 0);
	
	type state_type		is (S_VERIFY_HIGH, S_VERIFY_LOW);
	----------------------------------------------------------------------
	
	-- Vector Ram Instantiation
	signal vreg_out 				: vector_ram; 
	
	
	-- Energy Ram Instantiation
	--signal eram 					: energy_ram := (others => (others => '0'));
	--signal eIndex 					: integer;
	signal esample_loaded		: STD_LOGIC;
	signal eTotal 					: unsigned(eram_sum_size - 1 downto 0);
	signal eAverage_ext 			: unsigned(eram_sum_size - 1 downto 0);
	signal eAverage				: unsigned(eram_element_size - 1 downto 0);
	--signal eStep					: integer := 0;
	signal eAverage_squared		: unsigned(23 downto 0);
	
	
	--Threshold value to qualify as "speech-detected"
	signal threshold_counter			: integer;
	signal threshold_counter_reset	: STD_LOGIC;
	
	signal sample_constrained	: STD_LOGIC_VECTOR(input_sample_width - 1 downto 0);
	signal sample_signed			: signed(11 downto 0);
	signal sample_shifted		: signed(11 downto 0);
	signal sample_flipped		: unsigned(11 downto 0);
	signal sample_converted		: STD_LOGIC_VECTOR(11 downto 0);
	signal sample_oldest			: STD_LOGIC_VECTOR(11 downto 0);
	
	signal sample_reg_en_signal	: STD_LOGIC;
	
	--State variables
	signal current_state			: state_type;
	signal next_state				: state_type;
	
	signal eStep 		: integer range 0 to 3;
	signal eCounter 	: integer range 0 to eram_size - 1;
	
	
--====================================================================================================
--====================================================================================================
begin

	threshold <= threshold_in;
	
	-- Debug stuff ------------------------------------
	
	sample_reg_en <= sample_reg_en_signal;
	
	debug_eAverage 		<= STD_LOGIC_VECTOR(eAverage);
	debug_sample_reg_en 	<= "00000000000" & sample_reg_en_signal;
	---------------------------------------------------

	-- Vector conversion
	---------------------------------------------------
	sample_constrained 	<= STD_LOGIC_VECTOR(to_unsigned(2987, 12)) when (unsigned(sample_in) > 2987) else
								sample_in;
	sample_signed			<= signed(sample_constrained);
	sample_shifted			<= sample_signed - 940;
	sample_flipped			<= unsigned(STD_LOGIC_VECTOR(abs(sample_shifted)));
	---------------------------------------------------
	
	sample_converted		<= STD_LOGIC_VECTOR(unsigned(sample_in) / 16);
	
	eAverage_ext 		<= eTotal srl 7;
	eAverage 			<= eAverage_ext(11 downto 0);
	eAverage_squared 	<= eAverage * eAverage;
	
	process (rst, clk)
	begin
		if(rst = '1') then
			
			--Energy variables
			esample_loaded 	<= '0';
			eTotal 				<= (others => '0');
			--eAverage_ext 		<= (others => '0');
			eStep 				<= 0;
			eCounter 			<= 0;
			
		elsif(rising_edge(clk)) then

			if(sample_ready = '1' and esample_loaded = '0') then
				esample_loaded <= '1';
				
				if(eCounter < eram_size - 1) then
					eCounter <= eCounter + 1;
					eTotal <= eTotal + sample_flipped;
				else
					eTotal <= eTotal + sample_flipped;
					eStep <= eStep + 1;
				end if;
	
			elsif(sample_ready = '0' and esample_loaded = '1') then
				esample_loaded <= '0';
			end if;
			
			
			if(eStep = 1) then
				eTotal <= eTotal - unsigned(sample_oldest);
				eStep <= eStep + 1;
			elsif(eStep = 2) then
				
				eStep <= 0;
			end if;
		end if;
	end process;
	
	
	-- State machine: current state
	process (rst, clk)
	begin
		if(rst = '1') then
			current_state <= S_VERIFY_HIGH;
			sample_reg_en_signal <= '0';
			
			threshold_counter_reset <= '1';
			
		elsif(rising_edge(clk)) then
			
			if(threshold_counter_reset = '1') then
				threshold_counter <= 0;
			else
				if(sample_ready = '1') then
					threshold_counter <= threshold_counter + 1;
				end if;
			end if;
		
			case current_state is
				when S_VERIFY_HIGH 	=>
					sample_reg_en_signal <= '0';
					if(to_integer(eAverage_squared) > threshold) then
						threshold_counter_reset <= '0';
						
						if(threshold_counter = threshold_counter_max) then
							current_state <= S_VERIFY_LOW;
							threshold_counter_reset <= '1';
						end if;
					else
						threshold_counter_reset <= '1';
					end if;
				when S_VERIFY_LOW		=>
					sample_reg_en_signal 			<= '1';
					
					if(to_integer(eAverage_squared) < threshold) then
						threshold_counter_reset <= '0';
						
						if(threshold_counter = threshold_counter_max) then
							current_state <= S_VERIFY_HIGH;
							threshold_counter_reset <= '1';
						end if;
					else
						threshold_counter_reset <= '1';
					end if;
			end case;
		end if;
	end process;
	
	-- Generate sample shift register
	GEN_REGS : for i in 0 to vram_size - 1 generate
		GEN_0: if i = 0 generate
			REGX: entity work.REG PORT MAP(
				clk => clk,
				rst => rst,
				en => sample_ready,
				din => sample_converted(output_sample_width - 1 downto 0),
				dout => vreg_out(i)
			);
		end generate GEN_0;
		
		GEN_X: if i > 0 generate
			REGX: entity work.REG PORT MAP(
				clk => clk,
				rst => rst,
				en => sample_ready,
				din => vreg_out(i-1),
				dout => vreg_out(i)
			);
		end generate GEN_X;
	end generate GEN_REGS;
	
	sample_out <= vreg_out(vram_size - 1);
	
	Inst_eram: entity work.eram_128 PORT MAP(
		d => STD_LOGIC_VECTOR(sample_flipped),
		clk => clk,
		ce => sample_ready,
		q => sample_oldest
	);
	
end Behavioral;