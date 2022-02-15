LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY ALU IS
PORT(
	a	: IN  std_logic_vector(31 downto 0);
	b	: IN  std_logic_vector(31 downto 0);
	ctrl	: IN std_logic_vector(3 downto 0);
	result	: OUT std_logic_vector(31 downto 0)
);
END ENTITY;


ARCHITECTURE behavioral OF ALU IS

-- Operations: Addition, Subtraction, Comparison, Bitwise AND/XOR, Arithmetic Right Shift

signal a_adder, b_adder: std_logic_vector(31 downto 0);
signal a_comp, b_comp: std_logic_vector(31 downto 0);
signal a_and, b_and: std_logic_vector(31 downto 0);
signal a_xor, b_xor: std_logic_vector(31 downto 0);
signal a_srai, b_srai: std_logic_vector(31 downto 0);
signal en_adder, en_and, en_xor, en_srai, en_comp, bit_comp: std_logic;
signal result_sum, result_and, result_srai, result_xor, result_comp: std_logic_vector(31 downto 0);


BEGIN

	gating: for i in 0 to 31 generate
	
		a_adder(i) 	<= en_adder AND a(i);
		b_adder(i)  <= en_adder AND b(i);
		
		a_srai(i) 	<= en_srai AND a(i);
		b_srai(i) 	<= en_srai AND b(i);
		
		a_xor(i) 	<= en_xor AND a(i);
		b_xor(i) 	<= en_xor AND b(i);
		
		a_and(i) 	<= en_and AND a(i);
		b_and(i) 	<= en_and AND b(i);
		
		a_comp(i) 	<= en_comp AND a(i);
		b_comp(i) 	<= en_comp AND b(i);

	end generate gating;
	
	-- Decoding ALUControl
	enabling: process(ctrl)
	begin 

		en_adder <= '0';
		en_and 	 <= '0';
		en_comp	 <= '0';
		en_srai	 <= '0';
		en_xor	 <= '0';
			
		case ctrl is 
			when "0000" => 
					en_and		<= '1';
			when "0001" => 
					en_xor		<= '1';
			when "0010" => 
					en_adder	<= '1';
			when "0110" => 
					en_adder	<= '1';
			when "1000" => 
					en_srai		<= '1';
			when "1001" => 
					en_comp		<= '1';
			when others => 
					en_and 	 	<= '0';
					en_xor		<= '0';
					en_adder 	<= '0';
					en_srai	 	<= '0';
					en_comp	 	<= '0';
		end case;

	 end process; 
	
	-- Adder/Subtractor
	result_sum	<=  std_logic_vector(signed(a_adder) - signed(b_adder)) WHEN ctrl(2) = '1' ELSE
					std_logic_vector(signed(a_adder) + signed(b_adder));


	-- Comparator
	bit_comp 	<= '1' WHEN signed(a_comp) < signed(b_comp) ELSE '0';
	result_comp 	<= (30 downto 0 => '0') & bit_comp;
	
	-- Bitwise AND
	result_and 	<= a_and AND b_and;
	
	-- Bitwise XOR
	result_xor 	<= a_xor XOR b_xor;
	
	-- Arithmetic Right Shift
	result_srai 	<= std_logic_vector(shift_right(signed(a_srai), to_integer(signed(b_srai))));
	
	-- Output MUX
	result 		<= 	result_sum	WHEN en_adder = '1' ELSE 
				result_and	WHEN en_and = '1' ELSE
				result_xor 	WHEN en_xor = '1' ELSE
				result_srai 	WHEN en_srai = '1' ELSE
				result_comp 	WHEN en_comp = '1' ELSE
				(others => '0');
	
END behavioral;