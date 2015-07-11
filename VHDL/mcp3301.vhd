
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MCP3301 is
	Port(	clk	: in	STD_LOGIC;
			rst	: in  STD_LOGIC;
			start	: in	STD_LOGIC;
			ncs	: out STD_LOGIC;
			sclk	: out STD_LOGIC;
			din	: in  STD_LOGIC;
			done	: out STD_LOGIC;
			dout  : out STD_LOGIC_VECTOR(11 downto 0)
	);
end MCP3301;

architecture Behavioral of MCP3301 is

	type state_type is (S_WAIT, S_CONVERT, S_DONE);
	
	signal currentState 	: state_type;
	signal nextState		: state_type;
	
	signal count			: integer;
	
	signal shiftreg_en				: STD_LOGIC;
	signal shiftreg_serial_out		: STD_LOGIC;
	signal shiftreg_parallel_out	: STD_LOGIC_VECTOR(11 downto 0);
begin

	sclk <= clk;
	
	dout <= shiftreg_parallel_out;

	SHIFT_REG1: entity work.SHIFT_REG PORT MAP(
		clk => clk,
		rst => rst,
		en => shiftreg_en,
		load => '0',
		dir => '0',
		shift_in => din,
		parallel_in => x"000",
		shift_out => shiftreg_serial_out,
		parallel_out => shiftreg_parallel_out
	);


	process (clk, rst)
	begin
		if(rst = '1') then
			currentState <= S_WAIT;
			count <= 0;
		elsif(rising_edge(clk)) then
			
			-- Counter
			if(start = '1') then
				count <= 0;
			else
				if(count < 18) then
					count <= count + 1;
				else
					count <= 0;
				end if;
			end if;
			--
			
			case currentState is
			when S_WAIT 		=>
				ncs <= '1';
				shiftreg_en <= '0';
				done <= '0';
				
				if(start = '1') then
					currentState <= S_CONVERT;
				end if;
			when S_CONVERT 	=>
				ncs <= '0';
				done <= '0';
			
				
				if(count = 2) then
					shiftreg_en <= '1';
				end if;
				
				if(count = 17) then
					currentState <= S_DONE;
				end if;
				
				
			when S_DONE			=>
				ncs <= '1';
				shiftreg_en <= '0';
				done <= '1';
				
				if(start = '1') then
					currentState <= S_CONVERT;
				else
					currentState <= S_WAIT;
				end if;
			when others			=>
		end case;
			
			
		end if;
	end process;
end Behavioral;

