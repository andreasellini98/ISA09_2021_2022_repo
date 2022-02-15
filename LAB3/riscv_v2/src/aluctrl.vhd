LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY aluctrl IS
PORT(
	aluop: IN std_logic_vector(1 downto 0); 	-- Two bits encoded coming from CU
	funct: IN std_logic_vector(2 downto 0);		-- Funct3		
	control: OUT std_logic_vector(3 downto 0)   	-- ALUControl bits
);
END ENTITY;


ARCHITECTURE behavioral OF aluctrl IS

BEGIN

op_evaluation: process(aluop, funct)
begin 
if aluop = "00" then 
	control	<= "0010"; -- Addition
else 
	if aluop = "01" then
		control	<= "0110"; -- Abs
	else
		if aluop = "10" then -- OP
			if funct = "000" then
				control	<= "0010"; -- Addition
			else 
				if funct = "100" then
					control	<= "0001"; -- Bitwise XOR
				else 
					if funct = "010" then
						control	<= "1001"; -- Comparison
					else
						control	<= "1111"; -- No operation
					end if;
				end if;
			end if;
		else
			if aluop = "11" then -- IMMEDIATE
				if funct = "000" then
					control	<= "0010"; -- Addition
				else
					if funct = "101" then
						control	<= "1000"; -- Arithmetic Right Shift
					else
						if funct = "111" then
							control	<= "0000"; -- Bitwise AND
						else
							control	<= "1111"; -- No operation
						end if;
					end if;
				end if;
			else
				control	<= "1111"; -- No operation
			end if;
		end if;
	end if;
end if;
					       
end process;


END behavioral;
