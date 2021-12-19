library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use std.textio.all;
use ieee.std_logic_textio.all;
library work;

entity fp_multiplier_tb is 
end fp_multiplier_tb;

architecture TEST of fp_multiplier_tb is 

	constant PERIOD : time := 16 ns; --CLOCK PERIOD 
	signal clk : std_logic := '0'; --CLK IS INITIALIZED
	signal in_a, in_b, out_op : std_logic_vector (31 downto 0); --INPUTS


	COMPONENT FPmul IS
	   PORT( 
		  FP_A : IN     std_logic_vector (31 DOWNTO 0);
		  FP_B : IN     std_logic_vector (31 DOWNTO 0);
		  clk  : IN     std_logic;
		  FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
	   );

	-- Declarations
	
	END COMPONENT ;


begin
	
	clk <= not clk after PERIOD/2;

	multiply1: FPmul
	PORT MAP (
	FP_A => in_a,
	FP_B => in_b,
	clk => clk,
	FP_Z => out_op); 
		


	process --READS INPUT FROM FILE, SIMULATES, WRITES RESULT IN OUTPUT FILE
		file input_file, op_out_file: text;
		variable in_line, out_line : line;
		variable space : character;
		variable in_line_a, in_line_b : std_logic_vector (31 downto 0);
		variable pipe_number : integer := 4; 
		variable resolution : time := PERIOD / 10; --TIME INTERVAL AFTER WHICH ENABLE STATUS IS CHECKED	

	begin

		file_open(input_file, "fp_samples.hex", read_mode);
		file_open(op_out_file, "fp_results.txt", write_mode);

		while not endfile(input_file) loop
	
			readline(input_file, in_line);
			hread(in_line, in_line_a);
			in_a <= in_line_a;
			
			readline(input_file, in_line);
			hread(in_line, in_line_b);		
			in_b <= in_line_b;
			
			wait for PERIOD*6;
			
			write(out_line, out_op); --WRITE RESULT ON FILE
			
			writeline(op_out_file, out_line);
								
		end loop;
	
		file_close(input_file);
		file_close(op_out_file);
			
		wait;
	end process;
end TEST;

