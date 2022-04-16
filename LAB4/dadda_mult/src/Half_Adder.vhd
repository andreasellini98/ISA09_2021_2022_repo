LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Half_Adder IS
PORT (
	a : IN STD_LOGIC;
	b : IN STD_LOGIC;
	s : OUT STD_LOGIC;
	cout : OUT STD_LOGIC);
END ENTITY Half_Adder;

ARCHITECTURE Structural OF Half_Adder IS

--Funzioni logiche per creare il full adder
BEGIN

--Calcolo del bit di somma
s <= a XOR b;
cout <= a AND b;


END Structural;