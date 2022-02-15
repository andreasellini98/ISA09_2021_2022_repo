LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY riscv IS
PORT(
	clk		: IN std_logic;
	rstn		: IN std_logic;
	instruction	: IN  std_logic_vector(31 downto 0); 	-- Instruction coming from Program RAM
	address_dm	: OUT std_logic_vector(31 downto 0); 	-- Address of Data RAM
	address_instr	: OUT std_logic_vector(31 downto 0); 	-- Address of Program RAM
	data_to_mem	: OUT std_logic_vector(31 downto 0); 	-- Data to be written in Data RAM
	data_from_mem	: IN std_logic_vector(31 downto 0);   	-- Data read from Data RAM
	read_mem	: OUT std_logic;			-- Read enable Data RAM
	write_mem	: OUT std_logic				-- Write enable Data RAM
);
END ENTITY;


ARCHITECTURE beh OF riscv is

-- Pipeline register signals:
				
-- IF/ID
signal IFID_in, IFID_out: std_logic_vector(95 downto 0);

-- ID/EX
signal IDEX_forward: std_logic_vector(9 downto 0);
signal IDEX_ctrl_in: std_logic_vector(8 downto 0);
signal IDEX_dp_in: std_logic_vector(167 downto 0);
signal IDEX_in, IDEX_out: std_logic_vector(186 downto 0);

-- EX/MEM
signal EXMEM_ctrl_in: std_logic_vector(4 downto 0);
signal EXMEM_dp_in: std_logic_vector(132 downto 0);
signal EXMEM_in, EXMEM_out: std_logic_vector(137 downto 0);

-- MEM/WB
signal MEMWB_ctrl_in: std_logic_vector(2 downto 0);
signal MEMWB_dp_in: std_logic_vector(132 downto 0);
signal MEMWB_in, MEMWB_out: std_logic_vector(135 downto 0);


-- Program Counter Register
COMPONENT REG32PC IS
PORT(	
	D			: IN STD_LOGIC_VECTOR(31 downto 0);
	CLK, RSTn, EN 		: IN STD_LOGIC;
	Q 			: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

-- REGFILE
COMPONENT RegisterFile IS
PORT( 
	clk		: IN std_logic;
	rstn		: IN std_logic;
	bypass1		: IN std_logic;
	bypass2 	: IN std_logic;
	rr1		: IN  std_logic_vector(4 downto 0);
	rr2  		: IN  std_logic_vector(4 downto 0);
	rd1		: OUT std_logic_vector(31 downto 0);
	rd2		: OUT std_logic_vector(31 downto 0);
	wr		: IN std_logic_vector(4 downto 0);
	wd		: IN std_logic_vector(31 downto 0);
	rw		: IN std_logic
);
END COMPONENT ;

-- Register File bypass
COMPONENT bypass IS
PORT( 
	bypass1 	: OUT std_logic;
	bypass2		: OUT std_logic;
	RegWrite	: IN std_logic;
	rs1		: IN std_logic_vector(4 downto 0); 	
	rs2		: IN std_logic_vector(4 downto 0); 	
	rd		: IN std_logic_vector(4 downto 0)  	
);
END COMPONENT ;

-- Forwarding Unit: MEM -> EX, WB -> EX
COMPONENT forwardingunit IS
PORT( 
	forward1a  	: OUT std_logic;
	forward1b  	: OUT std_logic;
	forward2a  	: OUT std_logic;
	forward2b  	: OUT std_logic;
	RegWrite_MEM	: IN std_logic;
	RegWrite_WB	: IN std_logic;
	rs1		: IN std_logic_vector(4 downto 0); 	
	rs2		: IN std_logic_vector(4 downto 0); 	
	rd_MEM	 	: IN std_logic_vector(4 downto 0);
	rd_WB	 	: IN std_logic_vector(4 downto 0)
);
END COMPONENT ;

-- Forwarding Branch Unit: Mem -> ID
COMPONENT forwardingbranch IS
PORT( 
	RegWrite_MEM	: IN std_logic;
	rd_MEM		: IN std_logic_vector(4 downto 0);
	rs1		: IN std_logic_vector(4 downto 0);
	rs2         	: IN std_logic_vector(4 downto 0);
	forward1	: OUT std_logic;
	forward2	: OUT std_logic	
);
END COMPONENT ;

-- Branch solver
COMPONENT branchcomp IS
PORT(
	rs1		: IN std_logic_vector(31 downto 0);
	rs2		: IN std_logic_vector(31 downto 0);
	rd_MEM		: IN std_logic_vector(31 downto 0);
	forward1	: IN std_logic;
	forward2	: IN std_logic;
	equal		: OUT std_logic
);
END COMPONENT;

-- Hazard Detection Unit
COMPONENT hazardunit IS
PORT( 
	MemRead_EX  : IN std_logic;
	MemRead_MEM : IN std_logic;
	Jump	    : IN std_logic;
	branch	    : IN std_logic;
	rd_EX	    : IN std_logic_vector(4 downto 0);
	rd_MEM	    : IN std_logic_vector(4 downto 0);
	rs1         : IN std_logic_vector(4 downto 0);
	rs2         : IN std_logic_vector(4 downto 0);
	Flush	    : OUT std_logic;
	Stall	    : BUFFER std_logic
);
END COMPONENT ;

-- CU
COMPONENT controlunit IS
PORT(
	OPCODE		: IN  std_logic_vector(6 downto 0);
	branch		: OUT  std_logic;
	MemRead		: OUT  std_logic;
	DatatoReg	: OUT  std_logic_vector(1 downto 0);
	MemWrite	: OUT  std_logic;
	RegWrite	: OUT  std_logic;
	Jump		: OUT  std_logic;
	ALUSrcPC	: OUT  std_logic;
	ALUSrcIMM	: OUT  std_logic;
	ALUOp		: OUT  std_logic_vector(1 downto 0)
);
END COMPONENT;

-- ALUControl
COMPONENT aluctrl IS
PORT(
	aluop		: IN std_logic_vector(1 downto 0);
	funct		: IN std_logic_vector(2 downto 0);
	control		: OUT std_logic_vector(3 downto 0)
);
END COMPONENT;

-- ALU
COMPONENT ALU IS
PORT(
	a		: IN  std_logic_vector(31 downto 0);
	b		: IN  std_logic_vector(31 downto 0);
	result		: BUFFER std_logic_vector(31 downto 0);
	ctrl		: IN std_logic_vector(3 downto 0)
);
END COMPONENT;

-- Immediate Generator
COMPONENT immgen IS
PORT(
	instr		: IN  std_logic_vector(31 downto 0);
	immediate	: OUT  std_logic_vector(31 downto 0)
);
END COMPONENT;

-- Instruction fetch stage
signal PC_out_IF: std_logic_vector(31 downto 0);
signal PC_seq_IF: std_logic_vector(31 downto 0);
	-- Hazard Detection Unit
signal Stall	: std_logic;
signal Flush	: std_logic;
signal enable_IFID : std_logic;
signal enable_PC   : std_logic;

-- Instruction decode stage
	-- Instruction
signal instruction_ID	: std_logic_vector(31 downto 0);
	-- Program counter
signal PC_out_ID 	: std_logic_vector(31 downto 0);
signal PC_seq_ID	: std_logic_vector(31 downto 0);
signal PC_jump_ID		: std_logic_vector(31 downto 0);
	-- Immediate generated
signal Immediate_ID			: std_logic_vector(31 downto 0);
signal Immediate_shifted2	: std_logic_vector(31 downto 0);
	-- Register file outputs
signal rs1_ID		: std_logic_vector(31 downto 0);
signal rs2_ID		: std_logic_vector(31 downto 0);
signal bypass_r1, bypass_r2 : std_logic;
signal equal_ID 	: std_logic;
-- Forwarding Branch Unit
signal forward_b1, forward_b2: std_logic;
	-- Control unit outputs
signal branch_ID, MemRead_ID, MemWrite_ID, RegWrite_ID, Jump_ID, ALUSrcPC_ID, ALUSrcIMM_ID : std_logic;
signal DatatoReg_ID, ALUOp_ID : std_logic_vector(1 downto 0);
signal Control_ID : std_logic_vector(8 downto 0);
signal Stall_ID   : std_logic_vector(8 downto 0);

-- Execution stage
	-- Program counter
signal PC_out_EX		: std_logic_vector(31 downto 0);
signal PC_seq_EX		: std_logic_vector(31 downto 0);
	-- Immediate
signal Immediate_EX		: std_logic_vector(31 downto 0);
	-- Register file outputs
signal rs1_EX			: std_logic_vector(31 downto 0);
signal rs2_EX			: std_logic_vector(31 downto 0);
signal rr1			: std_logic_vector(4 downto 0);
signal rr2			: std_logic_vector(4 downto 0);
	-- Control unit outputs
signal MemRead_EX, MemWrite_EX, RegWrite_EX, ALUSrcPC_EX, ALUSrcIMM_EX : std_logic;
signal DatatoReg_EX, ALUOp_EX	: std_logic_vector(1 downto 0);
signal Control_EX : std_logic_vector(4 downto 0);
signal Stall_EX   : std_logic_vector(4 downto 0);
	-- Instruction (14 downto 12)
signal funct_EX			: std_logic_vector(2 downto 0);
	-- ALUCtrl output
signal control			: std_logic_vector(3 downto 0);
	-- ALU
signal forward1a, forward1b	: std_logic;
signal forward2a, forward2b : std_logic;
signal In_ALU1, In_ALU2		: std_logic_vector(31 downto 0);
signal In_ALU1_nofw, In_ALU2_nofw	: std_logic_vector(31 downto 0);
signal Out_ALU_EX		: std_logic_vector(31 downto 0);
signal zero_EX			: std_logic;
	-- Instruction (11 downto 7)
signal wr_EX			: std_logic_vector(4 downto 0);

-- Memory stage
	-- Program counter
signal PC_seq_MEM		: std_logic_vector(31 downto 0);
	-- Immediate
signal Immediate_MEM		: std_logic_vector(31 downto 0);
	-- Register file output
signal rs2_MEM			: std_logic_vector(31 downto 0);
	-- Control unit outputs
signal MemRead_MEM, MemWrite_MEM, RegWrite_MEM : std_logic;
signal DatatoReg_MEM: std_logic_vector(1 downto 0);
	-- ALU 
signal Out_ALU_MEM		: std_logic_vector(31 downto 0);
signal rd_MEM			: std_logic_vector(31 downto 0);
signal zero_MEM			: std_logic;
	-- Instruction (11 downto 7)
signal wr_MEM			: std_logic_vector(4 downto 0);

-- Write back
	-- Program counter
signal PC_in 		: std_logic_vector(31 downto 0);
signal PC_seq_WB		: std_logic_vector(31 downto 0);
	-- Immediate
signal Immediate_WB		: std_logic_vector(31 downto 0);
	-- Control unit output
signal RegWrite_WB		: std_logic;
signal DatatoReg_WB		: std_logic_vector(1 downto 0);
	-- ALU
signal Out_ALU_WB		: std_logic_vector(31 downto 0);
	-- Instruction (11 downto 7)
signal wr_WB			: std_logic_vector(4 downto 0);
	-- Data to be written in REGFile
signal rd			: std_logic_vector(31 downto 0);
	-- Data from memory
signal data_from_mem_WB		: std_logic_vector(31 downto 0);
	-- PC mux selector
signal PC_mux			: std_logic;



BEGIN

-- Program Counter

PC : REG32PC PORT MAP( PC_in , clk, rstn, enable_PC, PC_out_IF ); 	

PC_seq_IF <= std_logic_vector(signed(PC_out_IF) + to_signed(4,32)); 		-- Sequential addressing: PC = PC + 4

PC_jump_ID <= std_logic_vector(signed(PC_out_ID) + signed(Immediate_shifted2)); -- Jump or Branch addressing: PC = PC + 2*IMMEDIATE

PC_in <= PC_seq_IF WHEN PC_mux = '0' ELSE PC_jump_ID;				-- PC Mux

-- Immediate generator
immediategenerator : immgen PORT MAP(instruction_ID, Immediate_ID); 		-- Immediate Generator

Immediate_shifted2 <= Immediate_ID(30 downto 0) & '0'; 				-- Immediate x 2

-- Register File Bypass
bypassRF: bypass PORT MAP( bypass_r1, bypass_r2, RegWrite_WB, instruction_ID(19 downto 15), instruction_ID(24 downto 20), wr_WB);

-- Register File	     
RegFile : RegisterFile PORT MAP( clk, rstn, bypass_r1, bypass_r2, instruction_ID(19 downto 15), instruction_ID(24 downto 20), rs1_ID, rs2_ID, wr_WB, rd, RegWrite_WB);

-- Branch Comparator
branchcheck: branchcomp PORT MAP (rs1_ID, rs2_ID, rd_MEM, forward_b1, forward_b2, equal_ID);

-- Forwarding Branch
fwbranch: forwardingbranch PORT MAP (RegWrite_MEM, wr_MEM, instruction_ID(19 downto 15), instruction_ID(24 downto 20), forward_b1, forward_b2);

-- Forwarding Unit
fwunit: forwardingunit PORT MAP(forward1a, forward1b, forward2a, forward2b, RegWrite_MEM, RegWrite_WB, rr1, rr2, wr_MEM, wr_WB);

-- Hazard Detection Unit
hazdetunit: hazardunit PORT MAP(MemRead_EX, MemRead_MEM, PC_mux, branch_ID, wr_EX, wr_MEM, instruction_ID(19 downto 15), instruction_ID(24 downto 20), Flush, Stall);

enable_IFID <= not Stall;

enable_PC   <= not Stall;

-- Control Unit
CU : controlunit PORT MAP( instruction_ID(6 downto 0), branch_ID, MemRead_ID, DatatoReg_ID, MemWrite_ID, RegWrite_ID, Jump_ID, ALUSrcPC_ID, ALUSrcIMM_ID, ALUOp_ID);

Control_ID <= RegWrite_ID & DatatoReg_ID & MemRead_ID & MemWrite_ID & ALUOp_ID & ALUSrcPC_ID & ALUSrcIMM_ID;
Stall_ID   <= (Others => '0');

Control_EX <= RegWrite_EX & DatatoReg_EX & MemRead_EX & MemWrite_EX;
Stall_EX   <= (Others => '0');

-- ALU source signals
In_ALU1 <= rd_MEM		WHEN (forward1a = '1' AND forward2a = '0') ELSE
	   rd			WHEN (forward1a = '0' AND forward2a = '1') ELSE
	   In_ALU1_nofw;

In_ALU2 <= rd_MEM		WHEN (forward1b = '1' AND forward2b = '0') ELSE
	   rd			WHEN (forward1b = '0' AND forward2b = '1') ELSE
           In_ALU2_nofw;		

In_ALU1_nofw <= rs1_EX WHEN ALUSrcPC_EX = '0' ELSE PC_out_EX;
In_ALU2_nofw <= rs2_EX WHEN ALUSrcIMM_EX = '0' ELSE Immediate_EX;
		   
ALUcontrol: aluctrl PORT MAP (ALUOp_EX, funct_EX, control);

ALUnit : ALU PORT MAP (In_ALU1, In_ALU2, Out_ALU_EX, control);

rd_MEM <= Immediate_MEM WHEN DatatoReg_MEM = "11" ELSE Out_ALU_MEM;

-- Data to Register File
rd <= 	Out_ALU_WB 		WHEN DatatoReg_WB = "00" ELSE
	PC_seq_WB 		WHEN DatatoReg_WB = "10" ELSE
	data_from_mem_WB 	WHEN DatatoReg_WB = "01" ELSE
	Immediate_WB;

PC_mux <= (branch_ID AND equal_ID) OR Jump_ID; 		-- 0 If sequential addressing, 1 If jump/branch addressing

address_dm <= Out_ALU_MEM; 				-- Address of Data RAM

data_to_mem <= rs2_MEM; 				-- Data to be written in Data RAM

address_instr <= PC_out_IF; 				-- Address of Program RAM

read_mem <= MemRead_MEM; 				-- Read enable Data RAM

write_mem <= MemWrite_MEM; 				-- Write enable Data RAM


-- -- -- IF -> ID pipeline register -- -- -- 

IFID_in <= PC_seq_IF & PC_out_IF & instruction; 

IF_ID: process(clk, rstn)
begin
	if rstn = '0' then
		IFID_out <= (OTHERS => '0');
	else if rising_edge(clk) then
			if (Flush = '1') then
				IFID_out <= (others => '0');
			else if (enable_IFID = '1') then
					IFID_out <= IFID_in;
				end if;
			end if;
		 end if;
	end if;
end process;

instruction_ID 	<= IFID_out(31 downto 0);
PC_out_ID 	<= IFID_out(63 downto 32);
PC_seq_ID 	<= IFID_out(95 downto 64);

-- -- -- ID -> EX pipeline register -- -- --

IDEX_forward	<= instruction_ID(19 downto 15) & instruction_ID(24 downto 20);
IDEX_ctrl_in 	<= Control_ID WHEN Stall = '0' ELSE Stall_ID; 

IDEX_dp_in 	<= PC_seq_ID & PC_out_ID & rs1_ID & rs2_ID & instruction_ID(11 downto 7) & instruction_ID(14 downto 12) & Immediate_ID;

IDEX_in <= IDEX_forward & IDEX_ctrl_in & IDEX_dp_in;

ID_EX: process(clk, rstn)
begin
	if rstn = '0' then
		IDEX_out <= (OTHERS => '0');
	else if rising_edge(clk) then
			IDEX_out <= IDEX_in;
		 end if;
	end if;
end process;

rr1		<= IDEX_out(186 downto 182);
rr2		<= IDEX_out(181 downto 177);
RegWrite_EX 	<= IDEX_out(176);
DatatoReg_EX 	<= IDEX_out(175 downto 174);
MemRead_EX	<= IDEX_out(173);
MemWrite_EX	<= IDEX_out(172);
ALUOp_EX	<= IDEX_out(171 downto 170);
ALUSrcPC_EX  	<= IDEX_out(169);
ALUSrcIMM_EX 	<= IDEX_out(168);

PC_seq_EX	<= IDEX_out(167 downto 136);
PC_out_EX	<= IDEX_out(135 downto 104);
rs1_EX		<= IDEX_out(103 downto 72);
rs2_EX		<= IDEX_out(71 downto 40);
wr_EX		<= IDEX_out(39 downto 35);
funct_EX	<= IDEX_out(34 downto 32);
Immediate_EX 	<= IDEX_out(31 downto 0);

-- -- -- EX -> MEM pipeline register -- -- --

EXMEM_ctrl_in 	<= Control_EX;
EXMEM_dp_in 	<= PC_seq_EX & Out_ALU_EX & rs2_EX & wr_EX & Immediate_EX;

EXMEM_in <= EXMEM_ctrl_in & EXMEM_dp_in;

EX_MEM: process(clk, rstn)
begin
	if rstn = '0' then
		EXMEM_out <= (OTHERS => '0');
	else if rising_edge(clk) then
			EXMEM_out <= EXMEM_in;
		 end if;
	end if;
end process;

RegWrite_MEM 	<= EXMEM_out(137);
DatatoReg_MEM 	<= EXMEM_out(136 downto 135);
MemRead_MEM	<= EXMEM_out(134);
MemWrite_MEM	<= EXMEM_out(133);
PC_seq_MEM	<= EXMEM_out(132 downto 101);
Out_ALU_MEM	<= EXMEM_out(100 downto 69);
rs2_MEM		<= EXMEM_out(68 downto 37);
wr_MEM		<= EXMEM_out(36 downto 32);
Immediate_MEM	<= EXMEM_out(31 downto 0);

-- -- -- MEM -> WB pipeline register -- -- --

MEMWB_ctrl_in 	<= RegWrite_MEM & DatatoReg_MEM;
MEMWB_dp_in 	<= PC_seq_MEM & data_from_mem & Out_ALU_MEM & wr_MEM & Immediate_MEM;

MEMWB_in 	<= MEMWB_ctrl_in & MEMWB_dp_in;

MEM_WB: process(clk, rstn)
begin
	if rstn = '0' then
		MEMWB_out <= (OTHERS => '0');
	else if rising_edge(clk) then
			MEMWB_out <= MEMWB_in;
		 end if;
	end if;
end process;

RegWrite_WB 	 <= MEMWB_out(135);
DatatoReg_WB	 <= MEMWB_out(134 downto 133);
PC_seq_WB	 <= MEMWB_out(132 downto 101);
data_from_mem_WB <= MEMWB_out(100 downto 69);
Out_ALU_WB	 <= MEMWB_out(68 downto 37);
wr_WB		 <= MEMWB_out(36 downto 32);
Immediate_WB	 <= MEMWB_out(31 downto 0);


END beh;