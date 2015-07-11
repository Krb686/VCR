library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity T_FLIP_FLOP is
   port (T,Reset,CLK,CLK_enable: in std_logic;
	 Q: out std_logic);
end T_FLIP_FLOP;
 
architecture Behavioral of T_FLIP_FLOP is	 
	signal temp: std_logic;
begin
   process (Reset,CLK) 
   begin   
	   if Reset='1' then   
		  temp <= '0'; 
	      elsif (rising_edge(CLK)) then 		
	         if CLK_enable ='1' then
					temp <= T xor temp;
				end if;
         end if; 
   end process;
   Q <= temp;	   
end Behavioral;