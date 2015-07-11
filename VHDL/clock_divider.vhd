library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLOCK_DIVIDER is
	Generic (N : integer := 7);
	Port ( 	RST		: in	STD_LOGIC;
				CLKIN 	: in  STD_LOGIC;
				CLKOUT	: out STD_LOGIC);
end CLOCK_DIVIDER;

architecture Behavioral of CLOCK_DIVIDER is
	signal t_out : STD_LOGIC_VECTOR(N downto 0);
	

begin

	t_out(0) <= CLKIN;
	CLKOUT <= t_out(N);
	
	
	--Generate 7 T flip flops to divide the input clock from 100MHz -> 781.25 kilohertz
	--From there, the PmodMic component internally divides this clock by 4 to provide to the ADC, at 195.3125 kHz
	-- Summary of sample cycles
	-- 1 init cycle
	-- 16 serial out cycles
	--		4 - 0s
	--		12 - data bits
	-- 1 parallel load cycle
	-- This gives 18 cycles per sample.
	-- 195.3125 kHz / 18 = approx. 10,850 samples per second
	GEN_T_FLIP_FLOP:
	for i in 0 to N-1 generate
		T_FLIP_FLOP_X: entity work.T_FLIP_FLOP PORT MAP(
			T => '1',
			Reset => RST,
			CLK => t_out(i),
			CLK_enable => '1',
			Q => t_out(i+1)
		);
	end generate GEN_T_FLIP_FLOP;



end Behavioral;

