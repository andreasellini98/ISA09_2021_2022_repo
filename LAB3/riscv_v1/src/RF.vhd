LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY RegisterFile IS
PORT( 
	clk	: IN std_logic;
	rstn	: IN std_logic;
	bypass1 : IN std_logic;
	bypass2	: IN std_logic;
	rr1	: IN  std_logic_vector(4 downto 0);  -- Address first register to be read
	rr2  	: IN  std_logic_vector(4 downto 0);  -- Address second register to be read
	rd1	: OUT std_logic_vector(31 downto 0); -- Data read from first register
	rd2	: OUT std_logic_vector(31 downto 0); -- Data read from second register
	wr	: IN std_logic_vector(4 downto 0);   -- Address register to be written
	wd	: IN std_logic_vector(31 downto 0);  -- Data to be written
	rw	: IN std_logic			     -- 1 If write, 0 If read
);
END RegisterFile ;


ARCHITECTURE beh OF RegisterFile IS

   TYPE mytype IS ARRAY(0 to 31) OF std_logic_vector(31 DOWNTO 0);
   SIGNAL REGout : mytype;
   
BEGIN
	
	process(clk, rstn)
	begin
		if rstn = '0' then
			for i in 0 to 31 loop
				REGout(i) <= (OTHERS => '0'); -- Initialization
			end loop;
		else if rising_edge(clk) then
				if(rw = '1')then              -- Write enable
					REGout(to_integer(unsigned(wr))) <= wd; -- Write operation
				end if;
			 end if;
		end if;
	end process;
	
	rd1 <= REGout(to_integer(unsigned(rr1))) WHEN bypass1 = '0' ELSE wd;
	rd2 <= REGout(to_integer(unsigned(rr2))) WHEN bypass2 = '0' ELSE wd;
		
END beh;