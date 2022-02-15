LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY REG32PC IS
PORT(	D	: IN STD_LOGIC_VECTOR(31 downto 0);
	CLK, RSTn, EN : IN STD_LOGIC;
	Q 	: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END REG32PC;

ARCHITECTURE Behavior OF REG32PC IS

BEGIN

	PROCESS(CLK, RSTn)
	BEGIN			
		IF (RSTn = '0') THEN
			Q <= X"00400000";		-- Async reset to first memory address
		ELSIF rising_edge(CLK) THEN
			IF (EN = '1') THEN
			   Q <= D;
			END IF;
		END IF;
	END PROCESS;
	
END Behavior;
