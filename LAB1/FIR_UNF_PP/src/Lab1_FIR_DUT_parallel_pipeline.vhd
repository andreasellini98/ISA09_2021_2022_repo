LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

ENTITY Lab1_FIR_DUT IS
	PORT	(	DIN_x,DIN_y,DIN_z, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10 : IN SIGNED(10-1 downto 0);
				VIN, RSTn, CLK : IN STD_LOGIC;
				DOUT_x, DOUT_y, DOUT_z : OUT SIGNED(10-1 downto 0);
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

TYPE mytype_VIN IS ARRAY(0 to N-2) OF STD_LOGIC;
SIGNAL VIN_int : mytype_VIN;

TYPE mytype IS ARRAY(0 to N-1) OF SIGNED(NB-1 DOWNTO 0);
TYPE mytype_MULT IS ARRAY(0 to N-1) OF SIGNED((2*NB-1) DOWNTO 0);
TYPE mytype_ADD IS ARRAY(0 to N-1) OF SIGNED((NB-3) DOWNTO 0);
SIGNAL b, x_x, x_x_reg , x_y, x_y_reg, x_z, x_z_reg : mytype;
SIGNAL w_MULT_x, w_MULT_y, w_MULT_z 		: mytype_MULT;
SIGNAL w_ADD_x, w_ADD_y, w_ADD_z, w_ADD_reg_x, w_ADD_reg_y, w_ADD_reg_z 		: mytype_ADD;
--SIGNAL DINreg : SIGNED(NB-1 DOWNTO 0);
signal w_out_x, w_out_y, w_out_z : SIGNED(NB-1 DOWNTO 0);


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
SH: SHREG
	GENERIC MAP ( 12 )
	PORT MAP( VIN, CLK, RSTn, VOUT );

FFs: for i in 0 to N-2 generate
	initial: if i=0 generate
	FF0: process(CLK, RSTn)
		begin
			if (RSTn = '0') then
				VIN_int(0) <= '0';
				else if (rising_edge(CLK)) then
					VIN_int(0) <= VIN;
				end if;
			end if;
		end process;
	end generate initial;
	core: if i>0 and i <= N-2 generate
		FFi: process(CLK, RSTn)
		begin
			IF (RSTn = '0') then
				VIN_int(i) <= '0';
				else if (rising_edge(CLK)) then
					VIN_int(i) <= VIN_int(i-1);
				end if;
			end if;
		end process;
	end generate core;
	

end generate FFs;
	
	
-- VINint: process (VIN, VIN_sh)
-- begin 
	-- if (rising_edge(VIN) or rising_edge(VIN_sh)) then
		-- VIN_int <= '1';
	-- end if;
	-- if (falling_edge(VIN_sh)) then
		-- VIN_int <= '0';
	-- end if;
-- end process;

REGin_x : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( DIN_x, CLK, RSTn, VIN, x_x(0) );
	
REGin_y : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( DIN_y, CLK, RSTn, VIN, x_y(0) );
	
REGin_z : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( DIN_z, CLK, RSTn, VIN, x_z(0) );	
	
FIRx: for i in 0 to N-1 generate
	
	initial: if i=0 generate
		w_MULT_x(i) <= (x_x(i)*b(i)) SRL FractionalCut; 

		w_ADD_x(i) <= w_MULT_x(i)(NB DOWNTO 3);
	end generate initial;
	core: if i>0 and i <= N-1 generate
		REGi_x : REG_N_SIGNED
			GENERIC MAP ( NB )
			PORT MAP( x_z(i-1), CLK, RSTn, VIN_int(i-1), x_x_reg(i) );
			
		REGi_x2 : REG_N_SIGNED
			GENERIC MAP ( NB )
			PORT MAP( x_x_reg(i), CLK, RSTn, VIN_int(i-1), x_x(i) );
				
		w_MULT_x(i) <= (x_x(i)*b(i)) SRL FractionalCut ;
		
		REG_pipe_sum : REG_N_SIGNED
			GENERIC MAP ( NB-2 )
			PORT MAP( w_ADD_x(i-1), CLK, RSTn, VIN_int(i-1), w_ADD_reg_x(i-1));
		
		w_ADD_x(i) <= w_MULT_x(i)(NB DOWNTO 3) + w_ADD_reg_x(i-1);
		
	end generate core;


end generate FIRx;

FIRy: for i in 0 to N-1 generate
	
	initial: if i=0 generate
		w_MULT_y(i) <= (x_y(i)*b(i)) SRL FractionalCut; 
		
		w_ADD_y(i) <= w_MULT_y(i)(NB DOWNTO 3);
	end generate initial;
	core: if i>0 and i <= N-1 generate
		REGi_y : REG_N_SIGNED
			GENERIC MAP ( NB )
			PORT MAP( x_x(i-1), CLK, RSTn, VIN_int(i-1), x_y(i) );
		w_MULT_y(i) <= (x_y(i)*b(i)) SRL FractionalCut ;
		
		REG_pipe_sum : REG_N_SIGNED
			GENERIC MAP ( NB-2 )
			PORT MAP( w_ADD_y(i-1), CLK, RSTn, VIN_int(i-1), w_ADD_reg_y(i-1));
		
		w_ADD_y(i) <= w_MULT_y(i)(NB DOWNTO 3) + w_ADD_reg_y(i-1);
	end generate core;


end generate FIRy;

FIRz: for i in 0 to N-1 generate
	
	initial: if i=0 generate
		w_MULT_z(i) <= (x_z(i)*b(i)) SRL FractionalCut; 
		
		w_ADD_z(i) <= w_MULT_z(i)(NB DOWNTO 3);
	end generate initial;
	core: if i>0 and i <= N-1 generate
		REGi_z : REG_N_SIGNED
			GENERIC MAP ( NB )
			PORT MAP( x_y(i-1), CLK, RSTn, VIN_int(i-1), x_z(i) );
		
		w_MULT_z(i) <= (x_z(i)*b(i)) SRL FractionalCut ;
		
		REG_pipe_sum : REG_N_SIGNED
			GENERIC MAP ( NB-2 )
			PORT MAP( w_ADD_z(i-1), CLK, RSTn, VIN_int(i-1), w_ADD_reg_z(i-1));
		
		w_ADD_z(i) <= w_MULT_z(i)(NB DOWNTO 3) + w_ADD_reg_z(i-1);
	end generate core;


end generate FIRz;

w_out_x <= w_ADD_x(N-1)(NB-1-3) & w_ADD_x(N-1)(NB-1-3) & w_ADD_x(N-1)(NB-1-3) & w_ADD_x(N-1)((NB-1-3) downto 0);

w_out_y <= w_ADD_y(N-1)(NB-1-3) & w_ADD_y(N-1)(NB-1-3) & w_ADD_y(N-1)(NB-1-3) & w_ADD_y(N-1)((NB-1-3) downto 0);

w_out_z <= w_ADD_z(N-1)(NB-1-3) & w_ADD_z(N-1)(NB-1-3) & w_ADD_z(N-1)(NB-1-3) & w_ADD_z(N-1)((NB-1-3) downto 0);
	
REGout_x : REG_N_SIGNED
	GENERIC MAP ( NB )
	PORT MAP( w_out_x, CLK, RSTn, '1', DOUT_x );
	
REGout_y : REG_N_SIGNED
GENERIC MAP ( NB )
PORT MAP( w_out_y, CLK, RSTn, '1', DOUT_y );

REGout_z : REG_N_SIGNED
GENERIC MAP ( NB )
PORT MAP( w_out_z, CLK, RSTn, '1', DOUT_z );
	

	

	

END Structure;