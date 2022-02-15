LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY hazardunit IS
PORT( 
	MemRead_EX  : IN std_logic;			-- MemRead control signal in Execution stage
	MemRead_MEM : IN std_logic;			-- MemRead control signal in Memory stage
	Jump	    : IN std_logic;			-- Jump = '1' when next insruction is not the next in the sequence
	branch	    : IN std_logic;			-- branch = '1' when there is a possible Jump
	rd_EX	    : IN std_logic_vector(4 downto 0);	-- Destination register in Execution stage
	rd_MEM	    : IN std_logic_vector(4 downto 0);	-- Destination register in Memory stage
	rs1	    : IN std_logic_vector(4 downto 0);	-- Source register 1
	rs2         : IN std_logic_vector(4 downto 0);	-- Source register 2
	Flush	    : OUT std_logic;			-- FLUSH = '1' when instruction in the pipeline are not correct
	Stall	    : BUFFER std_logic			-- STALL = '1' when there is a data hazard
);
END hazardunit ;

ARCHITECTURE beh OF hazardunit IS

BEGIN

-- Stall occurs when:
-- branch comparison has to be resolved but registers are not updated (branch in ID, data in EX)
-- branch comparison has to be resolved but registers are not updated due to Load (branch in ID, data read from mem in MEM)
-- register not updated due to LOAD-USE data hazard (instruction in ID, Load in EX)

Stall <= '1' WHEN (((rs1 = rd_EX AND rs1 /= (4 downto 0 => '0')) OR (rs2 = rd_EX AND rs2 /= (4 downto 0 => '0'))) AND (branch = '1' OR MemRead_EX = '1')) OR (((rs1 = rd_MEM AND rs1 /= (4 downto 0 => '0')) OR (rs2 = rd_MEM AND rs2 /= (4 downto 0 => '0'))) AND (branch = '1' AND MemRead_MEM = '1')) ELSE '0';
	

-- Flush occurs when:
-- a jump is taken ( and there is no stall, in order to avoid "fake" branches)

Flush <= '1' WHEN (Jump = '1' AND Stall = '0') ELSE '0';
	
	
END beh;