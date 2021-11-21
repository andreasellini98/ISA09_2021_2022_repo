LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SHREG IS
	GENERIC ( N : NATURAL := 9 );
	PORT(	D,CLK, RSTn : IN STD_LOGIC;
			Q 				  : OUT STD_LOGIC
		  );
END SHREG;

ARCHITECTURE Behavior OF SHREG IS
SIGNAL r : std_logic_vector(0 to N-1);
BEGIN
	
	PROCESS(CLK, RSTn)
	BEGIN			
		IF (RSTn = '0') THEN
			r <= (others => '0'); --Q <= '0';		-- async reset
		ELSIF rising_edge(CLK) THEN
			r <= D & r(0 to N-2);
			
		END IF;
	END PROCESS;
	Q <= r(N-1);
	
END Behavior;