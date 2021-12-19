library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use std.textio.all;
use ieee.std_logic_textio.all;
library work;

entity MBE_tb is 
end MBE_tb;

architecture TEST of MBE_tb is 
	constant NB : NATURAL := 32; 
	constant PERIOD : time := 10 ns; --CLOCK PERIOD 
	
	
	signal clk : std_logic := '0'; --CLK IS INITIALIZED
	signal in_b: std_logic_vector (2 downto 0); --INPUTS
	signal in_a : std_logic_vector (NB-1 downto 0);
	signal out_p : std_logic_vector (NB downto 0);
	

	COMPONENT MBE IS
		GENERIC ( NB : NATURAL := 32 );
		PORT( 
			a	: IN  std_logic_vector(NB-1 downto 0);
			b  	: IN  std_logic_vector(2 downto 0);
			p : OUT std_logic_vector(NB downto 0)
		);

	-- Declarations
	
	END COMPONENT ;




begin


	myMBE: MBE
		GENERIC MAP (NB => NB)
		PORT MAP (
					a => in_a,
					b => in_b,
					p => out_p); 
		
	clk <= not clk after PERIOD/2;
 
 process
 begin
	in_a <= std_logic_vector(to_unsigned(16,NB));
	in_b <= "000";
	wait for 17 ns;
	in_b <= "001";
	wait for 10 ns;
	in_b <= "010";
	wait for 10 ns;
	in_b <= "011";
	wait for 10 ns;
	in_b <= "100";
	wait for 10 ns;
	in_b <= "101";
	wait for 10 ns;
	in_b <= "111";
	wait;
	
 
 end process;
 
 end TEST;

