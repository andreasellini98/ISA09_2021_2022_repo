LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY forwardingbranch IS
PORT( 
	RegWrite_MEM	: IN std_logic;				-- RegWrite control signal in Memory stage
	rd_MEM		: IN std_logic_vector(4 downto 0);	-- Destination register from Memory stage
	rs1		: IN std_logic_vector(4 downto 0);	-- Source register 1
	rs2         	: IN std_logic_vector(4 downto 0);	-- Source register 2
	forward1	: OUT std_logic;			-- Mux ctrl 1
	forward2	: OUT std_logic				-- Mux ctrl 2
	
);
END forwardingbranch ;

ARCHITECTURE beh OF forwardingbranch IS

BEGIN

	forward1 <= '1' WHEN (((rs1 = rd_MEM) AND RegWrite_MEM = '1') AND rs1 /= (4 downto 0 => '0')) ELSE '0';
	
	forward2 <= '1' WHEN (((rs2 = rd_MEM) AND RegWrite_MEM = '1') AND rs1 /= (4 downto 0 => '0')) ELSE '0';

END beh;