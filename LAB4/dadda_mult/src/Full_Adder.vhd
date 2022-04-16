LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Full_Adder IS
PORT (
	a 		: IN STD_LOGIC;
	b 		: IN STD_LOGIC;
	cin 	: IN STD_LOGIC;
	s 		: OUT STD_LOGIC;
	cout	: OUT STD_LOGIC);
END Full_Adder;

ARCHITECTURE Behaviour OF Full_Adder IS
--Segnale di supporto per il circuito
SIGNAL x : STD_LOGIC; 

--Funzioni logiche per creare il full adder
BEGIN

--Calcolo del bit di somma
Porta1: x 	<= a 	XOR b;
Porta2: s 	<= cin 	XOR x;

--Calcolo del carry in uscita (FULL_ADDER_COUT)
cout <= (NOT (x) AND b) OR (x AND cin); --FUNZIONE LOGICA DEL MUX

END Behaviour;