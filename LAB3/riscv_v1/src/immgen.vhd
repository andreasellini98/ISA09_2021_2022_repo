LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY immgen IS
PORT(
	instr		: IN  std_logic_vector(31 downto 0);  -- 32-bit instruction
	immediate	: OUT  std_logic_vector(31 downto 0)  -- 32-bit immediate value
);
END ENTITY;


ARCHITECTURE behavioral OF immgen IS

signal muxsel: std_logic_vector(2 downto 0);
signal s_mux, b_mux, is_mux, i_mux, u_mux, j_mux: std_logic_vector(31 downto 0); 

signal s_sign_ext, b_sign_ext, i_sign_ext: std_logic_vector(19 downto 0);
signal u_lsb, j_sign_ext: std_logic_vector(11 downto 0);

BEGIN

-- Decode OPCODE and funct3
process(instr(6 downto 2), instr(14 downto 12))
begin
	case instr(6 downto 2) is
		when "01000" 	=> muxsel <= "000"; -- STORE		-> s-type
		when "11000" 	=> muxsel <= "001"; -- BRANCH		-> sb-type
		when "00000" 	=> muxsel <= "010"; -- LOAD		-> i-type
		when "00100" 	=> 
			if instr(14 downto 12) = "101" then
						   muxsel <= "101"; -- IMM-SHIFT	-> is-type
			else
						   muxsel <= "010"; -- OP-IMM 		-> i-type
			end if;
		when "00101" 	=> muxsel <= "011"; -- AUIPC 		-> u-type
		when "01101" 	=> muxsel <= "011"; -- LUI 		-> u-type
		when "11011" 	=> muxsel <= "100"; -- JAL 		-> uj-type
		when others 	=> muxsel <= "111"; -- OTHERS
	end case;
end process;

s_sign_ext 	<= (others => instr(31));
s_mux 		<= s_sign_ext & instr(31 downto 25) & instr(11 downto 7); 			 -- s-type

b_sign_ext 	<= (others => instr(31));
b_mux 		<= b_sign_ext & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8); -- sb-type

-- SHAMT in (24-20)
is_mux 		<= (26 downto 0 => '0') & instr(24 downto 20);					 -- is-type (For shifting operations)

i_sign_ext 	<= (others => instr(31));
i_mux 		<= i_sign_ext & instr(31 downto 20);					 	 -- i-type

u_lsb 		<= (others => '0');
u_mux 		<= instr(31 downto 12) & u_lsb;							 -- u-type

j_sign_ext 	<= (others => instr(31));
j_mux		<= j_sign_ext & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21); -- uj-type


immediate <= 	s_mux 	WHEN muxsel = "000" ELSE
		b_mux 	WHEN muxsel = "001" ELSE
		is_mux 	WHEN muxsel = "101" ELSE
		i_mux 	WHEN muxsel = "010" ELSE
		u_mux 	WHEN muxsel = "011" ELSE
		j_mux 	WHEN muxsel = "100" ELSE
		(others => '0');

END behavioral;