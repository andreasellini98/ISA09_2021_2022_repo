LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY REG_N_SIGNED IS
	GENERIC ( N : NATURAL := 9 );
	PORT(	D			  : IN SIGNED(N-1 downto 0);
			CLK, RSTn, EN : IN STD_LOGIC;
			Q 				  : OUT SIGNED(N-1 downto 0)
		  );
END REG_N_SIGNED;

ARCHITECTURE Behavior OF REG_N_SIGNED IS

BEGIN

	PROCESS(CLK, RSTn)
	BEGIN			
		IF (RSTn = '0') THEN
			Q <= to_signed(0, N);		-- async reset
		ELSIF rising_edge(CLK) THEN
			IF (EN = '1') THEN
			   Q <= D;					-- transparent mode
			END IF;
		END IF;
	END PROCESS;
	
END Behavior;
