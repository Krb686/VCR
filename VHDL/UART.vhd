library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART is
    Port ( clk  : in STD_LOGIC;
			  rst : in STD_LOGIC;
			  din : in  STD_LOGIC_VECTOR(11 downto 0);
			  start_flag : in STD_LOGIC;
			  tx : out  STD_LOGIC);
end UART;

architecture Behavioral of UART is
	
	constant uart_vector_length	: integer	:= 128;
	
	
	signal count 				: integer range 0 to 127;
	signal output_vector 	: STD_LOGIC_VECTOR(uart_vector_length - 1 downto 0);
	signal checksum			: unsigned(5 downto 0);
	
	

begin
	
	-- Output Vector Framing Format for UART serial transmission
	--
	-- 	Simple: 
	--			Each "packet" is 10 bits long.  It consists of (1) start bit, 8 data bits, and (1) stop bit.
	--			Bits/packets are sent from RIGHT to LEFT.
	--			There are 6 containers sent through this vector. They are:
	--
	--				[PAD] : [DATA UPPER] : [PAD] : [DATA LOWER] : [PAD] : [CHECKSUM]
	--				
	--			Additionally, there are 67 ish HIGH bits sent after the main transmission that represent IDLE and aid in synchronization.
	--
	--			Since each data sample is actually only 12 bits, they are split into 2 - six bit segments, as bits 0 through 5, and bits 6 through 11.
	--			Each 6 bit segment is transmitted with 2 additional bits, designated as UPPER ID (00) and LOWER ID (10) to fill out the 8 bit "payload" of the 10 bit packet.
	--			For instance, DATA UPPER is comprised of:
	--				[UPPER ID] : [din(11 downto 5)]
	--
	--		Default bit:
	--			The default bit is vector(0) and is HIGH for the same reason as the 40 HIGH bits on the end of the vector, to represent the IDLE state.
	--			The "start_flag" signal goes HIGH when a new data sample is loaded into the DATA_REGISTER to inform this UART module to start fresh at index 0.
	--			When the start_flag is HIGH, the count index returns to 0.
	--			However since the clock managing the "start_flag" signal runs at 195,312.5 Hz, 4 cycles of the faster clock in this UART module, CLOCKDIV, will run
	--			before the "start_signal" returns to 0.  That means the default bit should be transmitted 4 times before counting actually begins across the output_vector.
	--					
	--		Full format:
	-- 		[40x - 1s]:[STOP]:[UPPER ID]:[DATA_UPPER6]:[START]:[STOP]:[PAD BYTE]:[START]:[STOP]:[LOWER ID]:[DATA_LOWER6]:[START]:[STOP]:[PAD BYTE]:[START][DEFAULT]
	--
	--
	--	Synchronization:
	--
	--		Since each new sample arrives after 18 cycles of SCLK (195,312.5Hz), this serial transmission must be completed and must currently be in 
	--		
	
	checksum <= unsigned("00" & din(11 downto 8)) + unsigned("00" & din(7 downto 4)) + unsigned("00" & din(3 downto 0));
	output_vector <=	"111"&x"FFFFFFFFFFFFFFFF"&'1'&"10"&STD_LOGIC_VECTOR(checksum)&'0'&'1'&x"FF"&'0'&'1'&"01"&din(11 downto 6)&'0'&'1'&x"FF"&'0'&'1'&"00"&din(5 downto 0)&'0'&'1'&x"FF"&"01";
	--output_vector <=	x"FFFFFFFFFF"&'1'&"00"&din(11 downto 6)&'0'&'1'&x"FF"&'0'&'1'&"10"&din(5 downto 0)&'0'&'1'&x"FF"&"01";
	
	tx <= output_vector(count);
	
	
	--CLOCKDIV runs at 781.25 kHz, therefore the baud rate is 781.25 kHz (781,250)
	process (clk, rst)
	begin
		if(rst = '1') then
			count <= 0;
		elsif(rising_edge(clk)) then
			if(start_flag = '1') then
				count <= 0;
			else
				if(count < uart_vector_length - 1) then
					count <= count + 1;
				else
					count <= 0;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

