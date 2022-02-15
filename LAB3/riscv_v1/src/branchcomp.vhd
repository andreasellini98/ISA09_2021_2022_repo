LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY branchcomp IS
PORT(
	rs1		: IN  std_logic_vector(31 downto 0); 	-- Output1 of the register file
	rs2		: IN  std_logic_vector(31 downto 0);	-- Output2 of the register file
	rd_MEM		: IN  std_logic_vector(31 downto 0);	-- Data in the Memory stage
	forward1	: IN std_logic;				-- Mux ctrl 1
	forward2	: IN std_logic;				-- Mux ctrl 2
	equal		: OUT std_logic				-- Equal = '1' if the two compared data are equal
);
END ENTITY;


ARCHITECTURE beh OF branchcomp IS 

	signal comp1, comp2: signed(31 downto 0);
	
BEGIN 

	comp1 <= signed(rs1) WHEN forward1 = '0' ELSE signed(rd_MEM); -- MUX1
	
	comp2 <= signed(rs2) WHEN forward2 = '0' ELSE signed(rd_MEM); -- MUX2
	
	equal <= '1' WHEN (comp1 = comp2) ELSE '0';		      -- Comparator
	

END beh;