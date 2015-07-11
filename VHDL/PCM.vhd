----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:31 03/15/2015 
-- Design Name: 
-- Module Name:    PCM - Behavioral 
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
use work.LPC_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCM is
    Port ( InputDataMemoryADR : in  STD_LOGIC_VECTOR (25 downto 0):=(others=>'0');
           Operand : out  unsigned (7 downto 0);
			  Input: in unsigned(7 downto 0);
			  LoadDataMemoryADR: in STD_LOGIC_VECTOR(25 downto 0):=(others=>'0'));
end PCM;

architecture Behavioral of PCM is
type Reg_mem is array (num_samples_per_window downto 0) of unsigned(7 downto 0);
signal Reg:Reg_mem:=(others=>(others=>'0'));
 
begin
Reg(to_integer(unsigned(LoadDataMemoryADR)))<=Input;
Operand<=Reg(to_integer(unsigned(InputDataMemoryADR)));

end Behavioral;

