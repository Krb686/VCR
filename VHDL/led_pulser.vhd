library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_PULSER is
	Port (	clk : in STD_LOGIC;
				rst : in STD_LOGIC;
				led_out : out STD_LOGIC
			);
end LED_PULSER;

architecture Behavioral of LED_PULSER is

	signal count1 		: integer;
	signal count1_max : integer;
	signal count1_dir	: STD_LOGIC;
	signal count1_percent : integer;
	
	signal count2 : integer;
	signal count2_max : integer;
	
	
	signal percent 		: integer;
	signal percent_max 	: integer;
	signal percent_dir	: STD_LOGIC;
	

begin

	led_out <= 	'1' when count1 < percent else
					'0';

	

	process(clk, rst)
	begin
		if(rst = '1') then
		
			count1 <= 0;
			count1_max <= 100;
			count1_dir <= '0';
			
			count2 <= 0;
			count2_max <= 100;
			
			percent <= 10;
			percent_dir <= '0';
			percent_max <= 100;
			
		elsif(rising_edge(clk)) then
		
			if(count1_dir = '0') then
				if(count1 < count1_max - 1) then
					count1 <= count1 + 1;
				else
					count1_dir <= '1';
				end if;
			else
				if(count1 > 0) then
					count1 <= count1 - 1;
				else
					count1_dir <= '0';
				end if;
			end if;
			
			
			if(count1 = count1_max - 1) then
				if(count2 < count2_max - 1) then
					count2 <= count2 + 1;
				else
					count2 <= 0;
				end if;
			end if;
			
			
		end if;
	end process;
end Behavioral;

