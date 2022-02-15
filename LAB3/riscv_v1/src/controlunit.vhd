LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY controlunit IS
PORT(
	OPCODE		: IN  std_logic_vector(6 downto 0);
	branch		: OUT  std_logic;		      -- 1 If BEQ, 0 Otherwise
	MemRead		: OUT  std_logic;		      -- Read data memory: 1 If LW, 0 Otherwise
	DatatoReg	: OUT  std_logic_vector(1 downto 0);  -- Mux-selector for the REGFILE input data: "00" For the ALU result, "01" For data from mem, "10" For PC+4, "11" For Immediate
	MemWrite	: OUT  std_logic;		      -- Write data in memory: 1 If SW, 0 Otherwise
	RegWrite	: OUT  std_logic;		      -- Write data in REGFILE
	Jump		: OUT  std_logic;		      -- Unconditional jump
	ALUSrcPC	: OUT  std_logic;		      -- Mux-selector for first input data to ALU: 0 If data from REGFILE, 1 If PC
	ALUSrcIMM	: OUT  std_logic;		      -- Mux-selector for second input data to ALU: 0 If data from REGFILE, 1 If Immediate
	ALUOp		: OUT  std_logic_vector(1 downto 0)   -- Encoded two bits for ALUControl.
);
END ENTITY;


ARCHITECTURE behavioral OF controlunit IS


BEGIN
	
output_evaluation: process(OPCODE)
begin 

	branch 		<= '0';
	MemRead		<= '0';
	DatatoReg	<= "00";
	MemWrite	<= '0';
	RegWrite	<= '0';
	Jump		<= '0';
	ALUSrcPC	<= '0';
	ALUSrcIMM	<= '0';
	ALUOp		<= (others => '0');
        
	case OPCODE(6 downto 0) is 
    
		when "0000011" => -- LOAD
				MemRead		<= '1';
				DatatoReg	<= "01";
				RegWrite	<= '1';
				ALUSrcIMM	<= '1';
		when "0100011" => -- STORE
				MemWrite	<= '1';
				ALUSrcIMM	<= '1';
		when "1100011" => -- BRANCH
				branch 		<= '1';
				--ALUOp		<= "01";
		when "1101111" => -- JAL
				RegWrite	<= '1';
				Jump		<= '1';
				DatatoReg	<= "10";
		when "0010011" => -- OP-IMM
				RegWrite	<= '1';
				ALUSrcIMM	<= '1';
				DatatoReg   	<= "00";
				ALUOp		<= "11";
		when "0110011" => -- OP
				RegWrite	<= '1';
				DatatoReg   	<= "00";
				ALUOp		<= "10";
		when "0010111" => -- AUIPC
				RegWrite	<= '1';
				DatatoReg   	<= "00";
				ALUSrcPC	<= '1';
				ALUSrcIMM	<= '1';
		when "0110111" => -- LUI
				RegWrite	<= '1';
				DatatoReg   	<= "11";
		when others => 
				branch 		<= '0';
				MemRead		<= '0';
				DatatoReg	<= "00";
				MemWrite	<= '0';
				RegWrite	<= '0';
				ALUSrcPC	<= '0';
				Jump		<= '0';
				ALUSrcIMM	<= '0';
				ALUOp		<= (others => '0');
	end case;

 end process; 

END behavioral;