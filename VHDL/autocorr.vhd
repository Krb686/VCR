----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:20 03/15/2015 
-- Design Name: 
-- Module Name:    Auto_Corr - Behavioral 
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
use IEEE.STD_LOGIC_unsigned.ALL;
use work.LPC_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Auto_Corr is
    Port ( Operand : in  unsigned (7 downto 0);
           InputDataMemoryADR : out  STD_LOGIC_VECTOR (12 downto 0);
			  clock: in std_logic;
			  start_calc_flag: in std_logic;
			  T: out Auto_Corr_matrix:=(others=>(others=>'0'));
			  done: out std_logic
);
end Auto_Corr;

architecture Behavioral of Auto_Corr is

signal ADR_X:std_logic_vector(12 downto 0);
signal ADR_Y:std_logic_vector(12 downto 0);
signal ADR_rez:std_logic_vector(12 downto 0);
signal k:integer range 0 to 31;
signal Reg32: auto_corr_val_type;
signal outputresult:auto_corr_matrix:=(others=>(others=>'0'));
signal next_stage:integer range 0 to 8;
signal stage:integer:=0;
signal busy:std_logic:='0';
signal X:unsigned(7 downto 0);
signal Y:unsigned(7 downto 0);
--signal less:std_logic;
--signal ADR_X_less_than_nsamples:std_logic;
--signal ADR_Y_less_than_nsamples:std_logic;


begin


stage <= next_stage;
--less <='1' when to_integer(unsigned(ADR_X))<Num_samples_per_window and to_integer(unsigned(ADR_Y))<Num_samples_per_window else '0';
coefficients_calc:process(clock, start_calc_flag)
						begin
							if rising_edge(clock) then
								case stage is 
									when 0 =>	done<='0';
													if start_calc_flag = '1' then 
														ADR_X<=(others=>'0');
														ADR_Y<=(others=>'0');
														ADR_rez<=(others=>'0');
														k<=0;
														reg32<=(others=>'0');
														Busy<='1';
														next_stage<=1;
													end if;
									when 1 =>	InputDataMemoryADR<=ADR_X;
													ADR_X<=ADR_X+1;--added this here
													next_stage<=2;
									when 2 =>	--Delay
													next_stage <= 3;
									when 3 =>	X<=Operand;
													--ADR_X<=ADR_X+1;
													InputDataMemoryADR<=ADR_Y;
													next_stage<=4;
									when 4 =>	--Delay
													next_stage <= 5;
									when 5 =>	Y<=Operand;
													inputDataMemoryADR<=ADR_X;
													ADR_Y<=ADR_Y+1;
													next_stage<=6;
									when 6 =>	--Delay
													next_stage <= 7;
									when 7 =>	X<=Operand;
													reg32<=reg32+X*Y;		
													inputDataMemoryADR<=ADR_Y;													
													if to_integer(unsigned(ADR_X))<Num_samples_per_window and to_integer(unsigned(ADR_Y))<Num_samples_per_window then
														ADR_X<=ADR_X+1;
														next_stage<=4;
													else		
														ADR_X<=(others=>'0');
														ADR_rez<=ADR_rez+1;
														ADR_Y<=std_logic_vector(to_unsigned(k+1,ADR_Y'length));
														next_stage<=8;
													end if;	
													
									when 8 =>   
--													next_stage<=6;
--													reg32<=reg32+X*OPERAND;	
--									when 6 =>	
--													outputresult(k)<=reg32;
													outputresult(k)<=reg32+X*OPERAND;
													
													if ADR_Y<num_coefficients+1 then 
														reg32<=(others=>'0');														
														k<=k+1;
														next_stage<=1;
													else 
														next_stage<=0;
														busy<='0';
														done<='1';
													end if;
									when others=> next_stage<=0;
							end case;
												
						end if;		
									
					end process coefficients_calc;
T<=outputresult;

--ADR_X_less_than_nsamples<= '1' when (to_integer(unsigned(ADR_X))>=Num_samples_per_window)and(stage=4) else '0';
--ADR_Y_less_than_nsamples<='1' when (to_integer(unsigned(ADR_Y))>=Num_samples_per_window)and(stage=4) else '0';
end Behavioral;

