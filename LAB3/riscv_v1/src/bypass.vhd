LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY bypass IS
PORT( 
	bypass1  : OUT std_logic;
	bypass2	 : OUT std_logic;
	RegWrite : IN std_logic;
	rs1	 : IN std_logic_vector(4 downto 0); 	
	rs2	 : IN std_logic_vector(4 downto 0); 	
	rd	 : IN std_logic_vector(4 downto 0)  	
);
END bypass ;

ARCHITECTURE beh OF bypass IS

BEGIN

	bypass1 <= '1' WHEN ((rs1 = rd AND RegWrite = '1') AND rd /= (4 downto 0 => '0')) ELSE '0';
	
	bypass2 <= '1' WHEN ((rs2 = rd AND RegWrite = '1') AND rd /= (4 downto 0 => '0')) ELSE '0';


END beh;