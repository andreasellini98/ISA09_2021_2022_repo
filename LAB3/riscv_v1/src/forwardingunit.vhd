LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY forwardingunit IS
PORT( 
	forward1a  	: OUT std_logic;			-- Mux ctrl 1: Bit 0 
	forward1b  	: OUT std_logic;			-- Mux ctrl 2: Bit 0
	forward2a  	: OUT std_logic;			-- Mux ctrl 1: Bit 1
	forward2b 	: OUT std_logic;			-- Mux ctrl 2: Bit 1
	RegWrite_MEM 	: IN std_logic;				-- RegWrite control signal in Memory stage
	RegWrite_WB  	: IN std_logic;				-- RegWrite control signal in Write Back stage
	rs1		: IN std_logic_vector(4 downto 0); 	-- Source register 1
	rs2		: IN std_logic_vector(4 downto 0); 	-- Source register 2
	rd_MEM	 	: IN std_logic_vector(4 downto 0);	-- Destination register from Memory stage
	rd_WB	 	: IN std_logic_vector(4 downto 0)	-- Destination register from Write Back stage
);
END forwardingunit ;

ARCHITECTURE beh OF forwardingunit IS

BEGIN

	forward1a <= '1' WHEN ((rs1 = rd_MEM AND RegWrite_MEM = '1') AND rd_MEM /= (4 downto 0 => '0')) ELSE '0';
	forward1b <= '1' WHEN ((rs2 = rd_MEM AND RegWrite_MEM = '1') AND rd_MEM /= (4 downto 0 => '0')) ELSE '0';
	
	forward2a <= '1' WHEN ((rs1 = rd_WB AND RegWrite_WB = '1') AND rd_WB /= (4 downto 0 => '0')) ELSE '0';
	forward2b <= '1' WHEN ((rs2 = rd_WB AND RegWrite_WB = '1') AND rd_WB /= (4 downto 0 => '0')) ELSE '0';
	

END beh;