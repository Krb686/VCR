----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:26 02/02/2015 
-- Design Name: 
-- Module Name:    address_bitmath - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity address_bitmath is
	GENERIC(BASE_OFFSET	:	integer := 0);
    Port ( feature_no : in  STD_LOGIC_VECTOR (4 downto 0);
           address_out : out  STD_LOGIC_VECTOR (5 downto 0));
end address_bitmath;

architecture Behavioral of address_bitmath is

begin


end Behavioral;

