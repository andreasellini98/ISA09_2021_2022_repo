LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

ENTITY Lab1_FIR_DUT IS
	PORT	(	DIN, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10 : IN SIGNED(10-1 downto 0);
				VIN, RSTn, CLK : IN STD_LOGIC;
				DOUT : OUT SIGNED(10-1 downto 0);
				VOUT: OUT STD_LOGIC
			);
END Lab1_FIR_DUT;

ARCHITECTURE Structure OF Lab1_FIR_DUT IS
CONSTANT N : integer := 11; -- order number = stages number
CONSTANT NB : integer := 10;
CONSTANT FractionalCut : NATURAL := NB-1; 

COMPONENT REG_N_SIGNED IS
	GENERIC ( N : NATURAL := 9 );
	PORT(	D			  : IN SIGNED(N-1 downto 0);
			CLK, RSTn, EN : IN STD_LOGIC;
			Q 				  : OUT SIGNED(N-1 downto 0)
		  );
END COMPONENT;

COMPONENT SHREG IS
	GENERIC ( N : NATURAL :=  12);
	PORT(	D,CLK, RSTn : IN STD_LOGIC;
			Q 				  : OUT STD_LOGIC
		  );
END COMPONENT;

-- Internal signals

TYPE mytype IS ARRAY(0 to N-1) OF SIGNED(NB-1 DOWNTO 0);
TYPE mytype_MULT IS ARRAY(0 to N-1) OF SIGNED((2*NB-1) DOWNTO 0);
TYPE mytype_ADD IS ARRAY(0 to N-1) OF SIGNED((NB-3) DOWNTO 0);
SIGNAL b,x : mytype;
SIGNAL w_MULT 		: mytype_MULT;
SIGNAL w_ADD 		: mytype_ADD;
SIGNAL y, DINreg : SIGNED(NB-1 DOWNTO 0);
signal w_out : SIGNED(NB-1 DOWNTO 0);


BEGIN
b(0) <= b0;
b(1) <= b1;
b(2) <= b2;
b(3) <= b3;
b(4) <= b4;
b(5) <= b5;
b(6) <= b6;
b(7) <= b7;
b(8) <= b8;
b(9) <= b9; 
b(10) <= b10;    

--DINreg <= DIN WHEN VIN = '1' ELSE (others=>'0');  -- used only when we want to clear memory of the filter real-time w/out RST
REGin : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( DIN, CLK, RSTn, VIN, x(0) );
	
FIR: for i in 0 to N-1 generate
	
	initial: if i=0 generate
		w_MULT(i) <= (x(i)*b(i)) SRL FractionalCut; 
		w_ADD(i) <= w_MULT(i) ((NB) DOWNTO 3);
	end generate initial;
	core: if i>0 and i <= N-1 generate
		REGi : REG_N_SIGNED
			GENERIC MAP ( NB )
			PORT MAP( x(i-1), CLK, RSTn, VIN, x(i) );
		w_MULT(i) <= (x(i)*b(i)) SRL FractionalCut ;

		w_ADD(i) <= w_MULT(i) ((NB) DOWNTO 3) + w_ADD(i-1);
	end generate core;

end generate FIR;
w_out <= w_ADD(N-1)(NB-1-3) & w_ADD(N-1)(NB-1-3) & w_ADD(N-1)(NB-1-3) & w_ADD(N-1)((NB-1-3) downto 0);
REGout : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( w_out, CLK, RSTn, '1', DOUT );
	
SH: SHREG
	GENERIC MAP ( 2 )
	PORT MAP( VIN, CLK, RSTn, VOUT );
	

	

END Structure;
