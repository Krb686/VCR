--------------------------------------------------------------------------------------------------------------------------
-- Title       : ssd_driver
-- Design      : lab3_demo
-- Function:   : generates signals driving four seven segment displays of the Digilent Basys2 or the Digilent Nexys3 board
--------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ssd_driver_Test is
	generic ( SSD_Delay : integer := 20 );
	port(
		clk      : in    std_logic;
		rst 		: in    std_logic; 
		SEG_0    : in    std_logic_vector(4 downto 0);
		SEG_1    : in    std_logic_vector(4 downto 0);
		SEG_2    : in    std_logic_vector(4 downto 0);
		SEG_3    : in    std_logic_vector(4 downto 0);
		seg		: out   std_logic_vector(7 downto 0);
		an  		: out   std_logic_vector(3 downto 0));
end entity;

architecture arch of ssd_driver_Test is
	
	-- intermediate signals and constants
	signal q : std_logic_vector(SSD_Delay-1 downto 0);
	signal mux_out : std_logic_vector(4 downto 0);
	signal sel : std_logic_vector(1 downto 0);
	
begin	

	up_counter2 : entity work.up_counter generic map ( SSD_Delay => SSD_Delay ) port map ( clk => clk, rst => rst, init => '0', enable => '1', count => q);
	
	sel <= q(SSD_Delay-1 downto SSD_Delay-2);
	
	with sel select	 
		mux_out <= 	SEG_0 when "00",
						SEG_1 when "01",
						SEG_2 when "10",
						SEG_3 when others;
						
	with sel select	 
		an <= "1110" when "00",
				"1101" when "01",
				"1011" when "10",
				"0111" when others;
						
	-- SEG_-to-7-segment decoding
	with mux_out select
		seg(7 downto 0) <= 	x"C0" when "00000", -- 0
									x"F9" when "00001", -- 1
									x"A4" when "00010", -- 2
									x"B0" when "00011", -- 3
									x"99" when "00100", -- 4
									x"92" when "00101", -- 5 or S
									x"82" when "00110", -- 6
									x"F8" when "00111", -- 7
									x"80" when "01000", -- 8
									x"90" when "01001", -- 9
									x"88" when "01010", -- A
									x"83" when "01011", -- b
									x"C6" when "01100", -- c
									x"A1" when "01101", -- d
									x"86" when "01110", -- E
									x"FB" when "01111", -- i
									x"89" when "10000", -- H
									x"C7" when "10001", -- L
									x"AB" when "10010", -- n
									x"A3" when "10011", -- o
									x"8C" when "10100", -- P
									x"87" when "10101", -- t
									x"E3" when "10110", -- u
									x"FF" when others; -- others
								
end arch;
