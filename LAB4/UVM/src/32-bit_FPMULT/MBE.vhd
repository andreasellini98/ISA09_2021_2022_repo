--descritption
--This circuit calculates the corret partial product (p) using a and triplets of b
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY MBE IS
	GENERIC ( NB : NATURAL := 32 );
	PORT( 
		a	: IN  std_logic_vector(NB-1 downto 0);
		b  	: IN  std_logic_vector(2 downto 0);
		p : OUT std_logic_vector(NB downto 0)
   );

-- Declarations

END MBE ;


ARCHITECTURE beh OF MBE IS

   -- Architecture declarations
	
   -- Internal signal declarations
   SIGNAL f1,f2,f3, sign : std_logic;
   SIGNAL sel : std_logic_vector(1 downto 0);
   SIGNAL s_mux : std_logic_vector(NB downto 0);
   
BEGIN
	f1 <= not( b(1) xor b(0) )  and not ( b(2) xor b(1) );
	f2 <= ( b(1) xor b(0) );
	f3 <= not( b(1) xor b(0) ) and ( b(2) xor b(1) ) ;
	
	sign <= b(2);
	
	sel <=  "00" when f1 = '1'  else
			"01" when f2 = '1' else
			"10" when f3 = '1' else "00";
			
	process(sel, a, b)
	begin
		if sel = "00" then
			s_mux <= (others => '0');
			else if sel = "01" then 
				s_mux <= '0' & a;
				else if sel = "10" then 
						s_mux <= a & '0';
						else 
						s_mux <= (others => '0');
				end if;
			end if;
		end if;
	
	end process;
	
	XOR_GEN : for i in 0 to NB generate
	
		p(i) <= s_mux(i) xor sign;
		
	end generate  XOR_GEN;

END beh;
