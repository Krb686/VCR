----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:03:11 04/02/2015 
-- Design Name: 
-- Module Name:    signature_extract_1 - Behavioral 
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
use work.LPC_pkg.ALL;
use work.VCR_Package.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signature_extract_1 is
    Port (
				rst : in STD_LOGIC;
				start_calc_flag : in  STD_LOGIC;
				sample_clock: in STD_logic;
				Operand: in unsigned (7 downto 0):=(others=>'0');
				lpc_addr_0 : in STD_LOGIC_VECTOR(Feature_Add_Width-1 downto 0);
				lpc_addr_1 : in STD_LOGIC_VECTOR(Feature_Add_Width-1 downto 0);
				lpc_addr_2 : in STD_LOGIC_VECTOR(Feature_Add_Width-1 downto 0);
				lpc_addr_3 : in STD_LOGIC_VECTOR(Feature_Add_Width-1 downto 0);
				lpc_out_0 : out STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
				lpc_out_1 : out STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
				lpc_out_2 : out STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
				lpc_out_3 : out STD_LOGIC_VECTOR(Sig_Value_Width-1 downto 0);
				InputDataMemoryADR: out std_logic_vector(Sample_Reg_Add_Width - 1 downto 0);
				all_complete_flag : out  STD_LOGIC
			  );
end signature_extract_1;

architecture Behavioral of signature_extract_1 is

signal auto_corr_done	: STD_LOGIC;
signal auto_corr_out		: Auto_Corr_matrix;
signal lpc_coeff			: coeff_matrix;
begin

Auto_Correlation:	ENTITY work.Auto_Corr(Behavioral)
							PORT MAP(
								Operand					=> Operand,
								InputDataMemoryADR	=> InputDataMemoryADR,
								clock						=> sample_clock,
								start_calc_flag		=> start_calc_flag,
								T							=> Auto_Corr_out,
								Done						=> auto_corr_done
							);
							
							
levinson_Durbin:	Entity work.levinson(FLOAT)
							PORT MAP(
								R		=> auto_corr_out,
								CLK	=> sample_clock,
								START	=> auto_corr_done,
								DONE	=> all_complete_flag,
								COEFF	=> lpc_coeff
							);

lpc_out_0	<= STD_LOGIC_VECTOR(lpc_coeff(to_integer(unsigned(lpc_addr_0))));
lpc_out_1	<= STD_LOGIC_VECTOR(lpc_coeff(to_integer(unsigned(lpc_addr_1))));
lpc_out_2	<= STD_LOGIC_VECTOR(lpc_coeff(to_integer(unsigned(lpc_addr_2))));
lpc_out_3	<= STD_LOGIC_VECTOR(lpc_coeff(to_integer(unsigned(lpc_addr_3))));
end Behavioral;

