----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:18:28 03/25/2015 
-- Design Name: 
-- Module Name:    levinson - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity levinson is
    Port (	R 		: in	auto_corr_matrix;
				CLK	: in	STD_LOGIC;
				START	: in	STD_LOGIC;
				DONE	: out	STD_LOGIC;
				COEFF : out	coeff_matrix);
end levinson;

--architecture Sequential of levinson is
--
--type real_coeff_matrix is array(num_coefficients downto 0) of real;
--signal Ak		: real_coeff_matrix;--coeff_matrix;
--signal Ek		: real;
--signal LAMBDA	: real;
--signal k			: integer;
--signal j			: integer;
--signal n			: integer;
--
--TYPE STATE_MACHINE is (IDLE,s0,s1,s2,s3,s4,s5,s6);
--signal STATE		: STATE_MACHINE := IDLE;
--signal NEXT_STATE	: STATE_MACHINE := IDLE;
--begin
--
--	process(CLK,START)
--	begin
--		if(START = '1') then
--			STATE <= IDLE;
--		else
--			STATE <= NEXT_STATE;
--		end if;
--	end process;
--	
--	process(CLK,START)
--	begin
--		if(START = '1') then
--			DONE <= '0';
--			NEXT_STATE <= s0;
--		elsif rising_edge(CLK) then
--			case STATE is
--				WHEN s0 =>
--					Ak				<= (0=>1.0, OTHERS=> 0.0);
--					Ek				<= real(to_integer(R(0)));
--					k				<= 0;
--					NEXT_STATE	<= s1;
--				WHEN s1 =>
--					LAMBDA		<= 0.0;
--					j				<= 0;
--					NEXT_STATE	<= s2;
--				WHEN s2 =>
--					LAMBDA	<= LAMBDA - (Ak(j) * real(to_integer(R(k+1-j))));
--					j			<= j+1;
--					if j>k-1 then
--						NEXT_STATE <= s3;
--					end if;
--				WHEN s3 =>
--					LAMBDA		<= LAMBDA/Ek;
--					n				<= 0;
--					NEXT_STATE	<= s4;
--				WHEN s4 =>
--					Ak(n)			<= Ak(n) + (LAMBDA*Ak(k+1-n));
--					Ak(k+1-n)	<= Ak(k+1-n) + (LAMBDA*Ak(n));
--					n				<= n+1;
--					if n>((k+1)/2)-1 then
--						NEXT_STATE <= s5;
--					end if;
--				WHEN s5 =>
--					Ek				<= Ek * (1.0-(LAMBDA*LAMBDA));
--
--					k				<= k+1;
--					if k < num_coefficients-1 then --num_coefficients
--						NEXT_STATE <= s1;
--					else
--						NEXT_STATE <= s6;
--					end if;
--				WHEN s6 =>
--					DONE			<= '1';
--					NEXT_STATE 	<= IDLE;
--				WHEN IDLE =>
--			end case;
--		end if;
--	end process;
--
----	COEFF <= Ak;
--end Sequential;

architecture FLOAT of levinson is

constant float_size : integer:= 32;
constant float_0		: STD_LOGIC_VECTOR(float_size-1 downto 0):= (others=>'0');
constant float_1		: STD_LOGIC_VECTOR(float_size-1 downto 0):= X"3f800000";
constant float_1000	: STD_LOGIC_VECTOR(float_size-1 downto 0):= X"447a0000";
constant float_1Mil	: STD_LOGIC_VECTOR(float_size-1 downto 0):= X"49742400";
type float_coeff_matrix is array(num_coefficients downto 0) of STD_LOGIC_VECTOR(float_size-1 downto 0);
type float_ARR is array(0 to 1) of STD_LOGIC_VECTOR(float_size-1 downto 0);

signal Ak		: float_coeff_matrix;--coeff_matrix;

signal Rf		: float_coeff_matrix;

signal Ek		: STD_LOGIC_VECTOR(float_size-1 downto 0);

signal LAMBDA		: STD_LOGIC_VECTOR(float_size-1 downto 0);

signal k			: integer;
signal j			: integer;
signal n			: integer;

signal ftf_a_v	: STD_LOGIC;
signal ftf_r_v	: STD_LOGIC;
signal ftf_in	: STD_LOGIC_VECTOR(31 downto 0);
signal ftf_out	: STD_LOGIC_VECTOR(float_size-1 downto 0);

signal fltf_a_v	: STD_LOGIC;
signal fltf_r_v	: STD_LOGIC;
signal fltf_in		: STD_LOGIC_VECTOR(float_size-1 downto 0);
signal fltf_out	: STD_LOGIC_VECTOR(31 downto 0);


signal fm_a_v	: STD_LOGIC_VECTOR(0 to 1);
signal fm_b_v	: STD_LOGIC_VECTOR(0 to 1);
signal fm_r_v	: STD_LOGIC_VECTOR(0 to 1);
signal fm_a_in	: float_ARR;
signal fm_b_in	: float_ARR;
signal fm_out	: float_ARR;

signal fas_a_v		: STD_LOGIC_VECTOR(0 to 1);
signal fas_b_v		: STD_LOGIC_VECTOR(0 to 1);
signal fas_o_v		: STD_LOGIC_VECTOR(0 to 1);
signal fas_r_v		: STD_LOGIC_VECTOR(0 to 1);
signal fas_a_in	: float_ARR;
signal fas_o_in	: STD_LOGIC_VECTOR(0 to 1); -- 0->add, 1->subtract
signal fas_b_in	: float_ARR;
signal fas_out		: float_ARR;

signal fd_a_v	: STD_LOGIC;
signal fd_b_v	: STD_LOGIC;
signal fd_r_v	: STD_LOGIC;
signal fd_a_in	: STD_LOGIC_VECTOR(float_size-1 downto 0);
signal fd_b_in	: STD_LOGIC_VECTOR(float_size-1 downto 0);
signal fd_out	: STD_LOGIC_VECTOR(float_size-1 downto 0);

signal index		: integer;
signal index_lag	: integer;
TYPE STATE_MACHINE is (IDLE,s0,s1,s2,s3,s4,s5,s6,rtf,fm_s2,fs_s2,fd_s3,fm_s4,fs_s4,fm0_s5,fs_s5,fm1_s5,atf);
signal STATE			: STATE_MACHINE := IDLE;
signal NEXT_STATE		: STATE_MACHINE := IDLE;
signal PENDING_STATE	: STATE_MACHINE := IDLE;
begin

ftf:	ENTITY work.fixed_to_float(fixed_to_float_a)
			PORT MAP(
							aclk						=> CLK,
							s_axis_a_tvalid		=> ftf_a_v,
--							s_axis_a_tready		=> x,
							s_axis_a_tdata			=> ftf_in,
							m_axis_result_tvalid	=> ftf_r_v,
--							m_axis_result_tready	=> z,
							m_axis_result_tdata	=> ftf_out
						);
FLOAT_DIV:	ENTITY work.float_divide(float_divide_a)
					PORT MAP(
									aclk 						=> CLK,
									s_axis_a_tvalid		=> fd_a_v,
									s_axis_a_tdata			=> fd_a_in,
									s_axis_b_tvalid		=> fd_b_v,
									s_axis_b_tdata			=> fd_b_in,
									m_axis_result_tvalid	=> fd_r_v,
									m_axis_result_tdata	=> fd_out
								);
FLOAT_ARITH:	for i in 0 to 1 GENERATE
	FLOAT_MULT:	ENTITY work.float_multiply(float_multiply_a)
						PORT MAP(
										aclk						=> CLK,
										s_axis_a_tvalid		=> fm_a_v(i),
										s_axis_a_tdata			=> fm_a_in(i),
										s_axis_b_tvalid		=> fm_b_v(i),
										s_axis_b_tdata			=> fm_b_in(i),
										m_axis_result_tvalid	=> fm_r_v(i),
										m_axis_result_tdata	=> fm_out(i)
						);
	FLOAT_AS:	ENTITY work.float_add_subtract(float_add_subtract_a)
						PORT MAP(
										aclk							=> CLK,
										s_axis_a_tvalid			=> fas_a_v(i),
										s_axis_a_tdata				=> fas_a_in(i),
										s_axis_b_tvalid			=> fas_b_v(i),
										s_axis_b_tdata				=> fas_b_in(i),
										s_axis_operation_tvalid => fas_o_v(i),
										s_axis_operation_tdata	=> (0=>fas_o_in(i),OTHERS=>'0'),
										m_axis_result_tvalid		=> fas_r_v(i),
										m_axis_result_tdata		=> fas_out(i)
									);
END GENERATE;

fltf:	ENTITY work.float_to_fixed(float_to_fixed_a)
			PORT MAP(
							aclk						=> CLK,
							s_axis_a_tvalid		=> fltf_a_v,
							s_axis_a_tdata			=> fltf_in,
							m_axis_result_tvalid	=> fltf_r_v,
							m_axis_result_tdata	=> fltf_out
						);
	process(CLK,START,NEXT_STATE)
	begin
		if(START = '1') then
			STATE <= IDLE;
		else
			STATE <= NEXT_STATE;
		end if;
	end process;
	
	process(CLK,START)
	begin
		--default values

		--
		if(START = '1') then
			DONE			<= '0';
			index			<= 0;
			index_lag	<= 0;
			Rf				<=(OTHERS=>(OTHERS=>'0'));
			NEXT_STATE	<= rtf;
		elsif rising_edge(CLK) then
		ftf_a_v		<= '0';
		fm_a_v		<= "00";
		fm_b_v		<= "00";
		fas_a_v		<= "00";
		fas_b_v		<= "00";
		fas_o_v		<= "00";
		fd_a_v		<= '0';
		fd_b_v		<= '0';
		--
		Ek				<= Ek;
		LAMBDA		<= LAMBDA;
		Ak				<= Ak;
			case STATE is
				WHEN rtf =>
					if index <= num_coefficients then
						ftf_in	<= STD_LOGIC_VECTOR(resize(R(index),ftf_in'length));
						ftf_a_v	<= '1';
						index		<= index+1;
					end if;
					if ftf_r_v = '1' and index > 0 then
						Rf(index_lag)	<= ftf_out;
						index_lag		<= index_lag+1;
					end if;
					if index_lag = num_coefficients then
						NEXT_STATE <= s0;
					end if;
				WHEN s0 =>
					Ak				<= (0=>float_1,OTHERS=>float_0);
					Ek				<= Rf(0);
					k				<= 0;
					NEXT_STATE	<= s1;
				WHEN s1 =>
					LAMBDA		<= float_0;
					j				<= 0;
					NEXT_STATE	<= s2;
				WHEN s2 =>
					j				<= j+1;
					fm_a_v(0)	<= '1';
					fm_a_in(0)	<= Ak(j);
					fm_b_v(0)	<= '1';
					fm_b_in(0)	<= Rf(k+1-j);
					NEXT_STATE	<= fm_s2;
					if j>k-1 then
						PENDING_STATE <= s3;
					else
						PENDING_STATE <= STATE;
					end if;
				WHEN fm_s2 =>
					if fm_r_v(0) = '1' then
						fas_b_v(0)	<= '1';
						fas_b_in(0)	<= fm_out(0);
						fas_a_v(0)	<= '1';
						fas_a_in(0)	<= LAMBDA;
						fas_o_v(0)	<= '1';
--						fas_o_in(0)	<= '1'; --is this the problem?
						fas_o_in(0) <= '0'; --this is a test
						NEXT_STATE	<= fs_s2;
					end if;
				WHEN fs_s2 =>
					if fas_r_v(0) = '1' then
						LAMBDA	<= fas_out(0);
						NEXT_STATE <= PENDING_STATE;
					end if;
				WHEN s3 =>
					fd_a_v		<= '1';
					fd_a_in		<= LAMBDA;
					fd_b_v		<= '1';
					fd_b_in		<= Ek;
					n				<= 0;
					NEXT_STATE	<= fd_s3;
				WHEN fd_s3 =>
					if fd_r_v = '1' then
						LAMBDA	<= fd_out;
						NEXT_STATE <= s4;
					end if;
				WHEN s4 =>
					n				<= n+1;
					fm_a_v(0)	<= '1';
					fm_a_in(0)	<= LAMBDA;
					fm_b_v(0)	<= '1';
					fm_b_in(0)	<= Ak(k+1-n);
					fm_a_v(1)	<= '1';
					fm_a_in(1)	<= LAMBDA;
					fm_b_v(1)	<= '1';
					fm_b_in(1)	<= Ak(n);				
					NEXT_STATE	<= fm_s4;
					if n>((k+1)/2)-1 then
						PENDING_STATE	<= s5;
					else
						PENDING_STATE	<= STATE;
					end if;
				WHEN fm_s4 =>
					if fm_r_v = "11" then
						fas_a_v(0)	<= '1';
						fas_a_in(0)	<= Ak(n-1);
						fas_o_v(0)	<= '1';
						fas_o_in(0)	<= '1';
						fas_b_v(0)	<= '1';
						fas_b_in(0)	<= fm_out(0);
						fas_a_v(1)	<= '1';
						fas_a_in(1)	<= Ak(k+1-(n-1));
						fas_o_v(1)	<= '1';
						fas_o_in(1)	<= '1';
						fas_b_v(1)	<= '1';
						fas_b_in(1)	<= fm_out(1);
						NEXT_STATE	<= fs_s4;
					end if;
				WHEN fs_s4 =>
					if fas_r_v = "11" then
						Ak(n-1)			<= fas_out(0);
						Ak(k+1-(n-1))	<= fas_out(1);
						NEXT_STATE	<= PENDING_STATE;
					end if;
				WHEN s5 =>
					fm_a_v(0)	<= '1';
					fm_a_in(0)	<= LAMBDA;
					fm_b_v(0)	<= '1';
					fm_b_in(0)	<= LAMBDA;
					k				<= k+1;
					NEXT_STATE	<= fm0_s5;
					if k < num_coefficients-1 then --num_coefficients
						PENDING_STATE <= s1;
					else
						PENDING_STATE <= s6;
					end if;
				WHEN fm0_s5 =>
					if fm_r_v(0) = '1' then
						fas_a_v(0)	<= '1';
						fas_a_in(0)	<= float_1;
						fas_o_v(0)	<= '1';
						fas_o_in(0)	<= '1';
						fas_b_v(0)	<= '1';
						fas_b_in(0)	<= fm_out(0);
						NEXT_STATE <= fs_s5;
					end if;
				WHEN fs_s5 =>
					if fas_r_v(0) = '1' then
						fm_a_v(0)	<= '1';
						fm_a_in(0)	<= Ek;
						fm_b_v(0)	<= '1';
						fm_b_in(0)	<= fas_out(0);
						NEXT_STATE <= fm1_s5;
					end if;
				WHEN fm1_s5 =>
					if fm_r_v(0) = '1' then
						Ek				<= fm_out(0);
						index			<= 0;
						index_lag	<= 0;
						NEXT_STATE	<= PENDING_STATE;
					end if;
				WHEN s6 =>
					if index <= num_coefficients then
						fm_a_in(0)	<= Ak(index);
						fm_a_v(0)	<= '1';
--						fm_b_in(0)	<= float_1000;
						fm_b_in(0)	<= float_1mil;
						fm_b_v(0)	<= '1';
						index			<= index + 1;
					end if;
					if fm_r_v(0) = '1' then
						Ak(index_lag)	<= fm_out(0);
						index_lag		<= index_lag + 1;
					end if;
					if index_lag = num_coefficients then
						index <= 1;
						index_lag <= 0;
						NEXT_STATE <= atf;
					end if;
				WHEN atf =>
					if index <= num_coefficients then
						fltf_in	<= '0' & Ak(index)(30 downto 0);
						fltf_a_v	<= '1';
						index		<= index+1;
					end if;
					if fltf_r_v = '1' then
						COEFF(index_lag)	<= unsigned(fltf_out);
						index_lag			<= index_lag+1;
					end if;
					if index_lag = num_coefficients-1 then
						DONE			<= '1';
						NEXT_STATE	<= IDLE;
					end if;
				WHEN IDLE =>
						DONE			<= '0';
			end case;
		end if;
	end process;
end FLOAT;

--architecture Fixed of levinson is
--
--type int_coeff_matrix is array(num_coefficients downto 0) of integer;
--signal Ak		: int_coeff_matrix;--coeff_matrix;
--signal Rf		: int_coeff_matrix;
--signal Ek		: integer;
--signal LAMBDA	: integer;
--signal k			: integer;
--signal j			: integer;
--signal n			: integer;
--
--TYPE STATE_MACHINE is (IDLE,s0,s1,s2,s3,s4,s5,s6);
--signal STATE		: STATE_MACHINE := IDLE;
--signal NEXT_STATE	: STATE_MACHINE := IDLE;
--begin
--
--	process(CLK,START)
--	begin
--		if(START = '1') then
--			STATE <= IDLE;
--		else
--			STATE <= NEXT_STATE;
--		end if;
--	end process;
--	
--	process(CLK,START)
--	begin
--		if(START = '1') then
--			DONE <= '0';
--			for i in 0 to R'length-1 loop
--				Rf(i) <= 1000000 * to_integer(R(i));
--			end loop;
--			NEXT_STATE <= s0;
--		elsif rising_edge(CLK) then
--			case STATE is
--				WHEN s0 =>
--					Ak				<= (0=>1000000, OTHERS=> 0);
----					Ak				<= (0=>1, OTHERS=> 0);
--					Ek				<= Rf(0);
--					k				<= 0;
--					NEXT_STATE	<= s1;
--				WHEN s1 =>
--					LAMBDA		<= 0;
--					j				<= 0;
--					NEXT_STATE	<= s2;
--				WHEN s2 =>
--					LAMBDA	<= LAMBDA - (Ak(j) * Rf(k+1-j))/1000000;
--					j			<= j+1;
--					if j>k-1 then
--						NEXT_STATE <= s3;
--					end if;
--				WHEN s3 =>
--					LAMBDA		<= 1000000*LAMBDA/Ek;
--					n				<= 0;
--					NEXT_STATE	<= s4;
--				WHEN s4 =>
--					Ak(n)			<= Ak(n) + (LAMBDA*Ak(k+1-n)/1000000);
--					Ak(k+1-n)	<= Ak(k+1-n) + (LAMBDA*Ak(n)/1000000);
--					n				<= n+1;
--					if n>((k+1)/2)-1 then
--						NEXT_STATE <= s5;
--					end if;
--				WHEN s5 =>
--					Ek				<= Ek * (1000000-(LAMBDA*LAMBDA/1000000));
--
--					k				<= k+1;
--					if k < num_coefficients-1 then --num_coefficients
--						NEXT_STATE <= s1;
--					else
--						NEXT_STATE <= s6;
--					end if;
--				WHEN s6 =>
--					DONE			<= '1';
--					NEXT_STATE 	<= IDLE;
--				WHEN IDLE =>
--			end case;
--		end if;
--	end process;
--
--G1:	for g in 0 to num_coefficients-1 generate
--	COEFF(g) <= to_unsigned(Ak(g),multiplicand_type_size);
--end generate;
--end Fixed;