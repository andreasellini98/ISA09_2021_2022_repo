LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY ks_adder IS
	GENERIC( N: integer:= 64);
	PORT(
		a		: IN  std_logic_vector(N-1 downto 0);
		b		: IN  std_logic_vector(N-1 downto 0);
		sum		: OUT std_logic_vector(N-1 downto 0)
	);
END ENTITY;


ARCHITECTURE KS OF ks_adder IS

SIGNAL C_fast : STD_LOGIC_VECTOR (N DOWNTO 0);
SIGNAL P_L0, G_L0 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L1, G_L1 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L2, G_L2 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L3, G_L3 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L4, G_L4 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L5, G_L5 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
SIGNAL P_L6, G_L6 : STD_LOGIC_VECTOR (N-1 DOWNTO 0);


BEGIN

C_fast(0) <= '0';

S0: FOR i IN 0 to N-1 GENERATE
		G_L0(i) <= a(i) AND b(i);
		P_L0(i) <= a(i) XOR b(i);
	END GENERATE;

S1: FOR i IN 0 to N-1 GENERATE
	S1_LOW:	IF i=0 GENERATE
				C_fast(i+1) <= G_L0(i) OR (C_fast(0) AND P_L0(i));
				P_L1(i) <= P_L0(i);
				G_L1(i) <= G_L0(i);
			END GENERATE S1_LOW;
	S1_UP:  IF i>=1 GENERATE 
			P_L1(i) <= P_L0(i) AND P_L0(i-1);
			G_L1(i) <= G_L0(i) OR (G_L0(i-1) AND P_L0(i));
			END GENERATE S1_UP;
	END GENERATE S1;
	
S2: FOR i IN 0 to N-1 GENERATE
	S2_LOW:	IF i<=1 GENERATE
				P_L2(i) <= P_L1(i);
				G_L2(i) <= G_L1(i);
			END GENERATE S2_LOW;
			
	S2_MED:	IF i<2 and i>=1 GENERATE
				C_fast(i+1) <= G_L1(i) OR (C_fast(0) AND P_L1(i));
			END GENERATE S2_MED;
					
	S2_UP:  IF i>=2 GENERATE 
			P_L2(i) <= P_L1(i) AND P_L1(i-2);
			G_L2(i) <= G_L1(i) OR (G_L1(i-2) AND P_L1(i));
			END GENERATE S2_UP;
	END GENERATE S2;
	
S3: FOR i IN 0 to N-1 GENERATE
	S3_LOW:	IF i<=3 GENERATE
				P_L3(i) <= P_L2(i);
				G_L3(i) <= G_L2(i);
			END GENERATE S3_LOW;
			
	S3_MED:	IF i<4 and i>=2 GENERATE
				C_fast(i+1) <= G_L2(i) OR (C_fast(0) AND P_L2(i));
			END GENERATE S3_MED;
			
	S3_UP:  IF i>=4 GENERATE 
			P_L3(i) <= P_L2(i) AND P_L2(i-4);
			G_L3(i) <= G_L2(i) OR (G_L2(i-4) AND P_L2(i));
			END GENERATE S3_UP;
	END GENERATE S3;
	
S4: FOR i IN 0 to N-1 GENERATE
	S4_LOW:	IF i<=7 GENERATE
				P_L4(i) <= P_L3(i);
				G_L4(i) <= G_L3(i);
			END GENERATE S4_LOW;
			
	S4_MED:	IF i<8 and i>=4 GENERATE
				C_fast(i+1) <= G_L3(i) OR (C_fast(0) AND P_L3(i));
			END GENERATE S4_MED;
			
	S4_UP:  IF i>=8 GENERATE 
			P_L4(i) <= P_L3(i) AND P_L3(i-8);
			G_L4(i) <= G_L3(i) OR (G_L3(i-8) AND P_L3(i));
			END GENERATE S4_UP;
	END GENERATE S4;
	
S5: FOR i IN 0 to N-1 GENERATE
	S5_LOW:	IF i<=15 GENERATE
				P_L5(i) <= P_L4(i);
				G_L5(i) <= G_L4(i);
			END GENERATE S5_LOW;
			
	S5_MED:	IF i<16 and i>=8 GENERATE
				C_fast(i+1) <= G_L4(i) OR (C_fast(0) AND P_L4(i));
			END GENERATE S5_MED;
			
	S5_UP:  IF i>=16 GENERATE 
			P_L5(i) <= P_L4(i) AND P_L4(i-16);
			G_L5(i) <= G_L4(i) OR (G_L4(i-16) AND P_L4(i));
			END GENERATE S5_UP;
	END GENERATE S5;

S6: FOR i IN 0 to N-1 GENERATE
	S6_LOW:	IF i<=31 GENERATE
				P_L6(i) <= P_L5(i);
				G_L6(i) <= G_L5(i);
			END GENERATE S6_LOW;
			
	S6_MED:	IF i<32 and i>=16 GENERATE
				C_fast(i+1) <= G_L5(i) OR (C_fast(0) AND P_L5(i));
			END GENERATE S6_MED;
			
	S6_UP:  IF i>=32 GENERATE 
			P_L6(i) <= P_L5(i) AND P_L5(i-32);
			G_L6(i) <= G_L5(i) OR (G_L5(i-32) AND P_L5(i));
			END GENERATE S6_UP;
	END GENERATE S6;	

S7: FOR i IN 0 to N-1 GENERATE
	S7_MED: IF i<64 and i>=32 GENERATE
				C_fast(i+1) <= G_L6(i) OR (C_fast(0) AND P_L6(i));
			END GENERATE S7_MED;
END GENERATE S7;

sum_bits: FOR i IN 0 to N-1 GENERATE
		sum(i) <= C_fast(i) XOR P_L0(i);
	END GENERATE sum_bits;

END ARCHITECTURE;