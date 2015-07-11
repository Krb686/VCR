----------------------------------------------------------------------------------
-- Company: GMU
-- Engineer: Jason Page
-- 
-- Create Date:    11:55:37 02/12/2015 
-- Design Name: 
-- Module Name:    Debouncer - Behavioral 
-- Project Name:   Lab3
-- Target Devices: NEXYS 3
-- Revision: 1
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity Debouncer_Test is
	generic ( Debounce_Bit : integer := 20;
			-- 	Debounce_Bit equals number of bits required to represent # of clock cycles in delay in binary
			-- 	Debounce_Bit = log_2(ClkFreqeuncy*Debounce Delay);  ( ClkFreqeuncy=100 MHz, DebounceDelay=10ms => Debounce_Bit = 20)
				 Debounce_Delay : STD_LOGIC_VECTOR := "11110100001001000000");
			--    Debounce_Delay STD_LOGIC_VECTOR := "11110100001001000000";  ( ClkFreqeuncy=100 MHz, Delay=10ms => Debounce_Delay = 1111 0100 0010 0100 0000)
			--		Debounce_Delay = Binary(ClkFreqeuncy*DebounceDelay)
    Port ( input, rst, clk : in  STD_LOGIC;
           output : out  STD_LOGIC;
			  step_output : out  STD_LOGIC);
end Debouncer_Test;

architecture Behavioral of Debouncer_Test is

signal prev_input : STD_LOGIC;
signal count : STD_LOGIC;
signal set : STD_LOGIC;
signal reset_sig : STD_LOGIC;
signal count_reset_sig : STD_LOGIC;
signal counter_out : STD_LOGIC_VECTOR (Debounce_Bit-1 downto 0);
signal D_output_sig : STD_LOGIC;
signal Q_output_sig : STD_LOGIC;
signal en_button_sig : STD_LOGIC;

begin

Counter: entity work.Counter_Test generic map( n => Debounce_Bit ) port map ( rst => reset_sig, clk => clk, en => count, Q => counter_out );
RED: entity work.RED_Test port map ( input => Q_output_sig,  rst => rst, clk => CLK, output => en_button_sig);

-- Input Flip-Flop to affect counter
process (clk)
begin
   if rising_edge(clk) then  
      prev_input <= input;
   end if;
end process;

-- Combinational logic for control signals to counter and count flip-flop
set <= (input xor prev_input) and not(count);
count_reset_sig <= '1' when (counter_out = Debounce_Delay) else '0';
reset_sig <= rst or count_reset_sig;

-- Set/Reset Flip-flop for Start Counter Flag and Switching of Output Mux
process (reset_sig, clk)
   begin
		if reset_sig = '1' then
			count <= '0';
		elsif rising_edge(clk) then
			if set = '1' then
				count <= '1';
			end if;
		end if;
end process;

-- Output Mux
D_output_sig <= input when (count = '0') else Q_output_sig;

-- Output Flip-Flop
process (clk)
   begin
		if rising_edge(clk) then
			Q_output_sig <= D_output_sig;
		end if;
end process;

-- Step Output Signal Assignment, Used for soft reset in ATM
step_output <= Q_output_sig;

-- Output Signal Assignment
output <= en_button_sig;

end Behavioral;

