library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity decode is
    port (
        clk, reset : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from fetch
        pc_in      : in  pc_type;
        instr      : in  instr_type;

        -- from writeback
        reg_write  : in reg_write_type;

        -- towards next stages
        pc_out     : out pc_type;
        exec_op    : out exec_op_type;
        mem_op     : out mem_op_type;
        wb_op      : out wb_op_type;

        -- exceptions
        exc_dec    : out std_logic
    );
end entity;

architecture rtl of decode is

	constant OPCODE_WIDTH : integer := 7;
	subtype opcode_type      is std_logic_vector(OPCODE_WIDTH-1 downto 0);

	constant OPC_LOAD	: opcode_type	:= "0000011";
	constant OPC_STORE	: opcode_type	:= "0100011";
	constant OPC_BRANCH	: opcode_type	:= "1100011";
	constant OPC_JALR	: opcode_type	:= "1100111";
	constant OPC_JAL	: opcode_type	:= "1101111";
	constant OPC_OP_IMM	: opcode_type	:= "0010011";
	constant OPC_OP		: opcode_type	:= "0110011";
	constant OPC_AUIPC	: opcode_type	:= "0010111";
	constant OPC_LUI	: opcode_type	:= "0110111";
	constant OPC_NOP	: opcode_type	:= "0001111";

	constant OPCODE_BIT_WIDTH	: integer := 7;

	type instruction_format_type is (R, I, S, B, U, J, INVALID);

	signal instruction	: instr_type;
	signal instruction_next	: instr_type;
	signal pc		: pc_type;
	signal pc_next		: pc_type;

	signal opcode			: std_logic_vector(OPCODE_BIT_WIDTH-1 downto 0);
	signal instruction_format	: instruction_format_type;

	signal funct7	: std_logic_vector(6 downto 0);
	signal funct3	: std_logic_vector(2 downto 0);

	-- from registered instruction
	signal register_address1	: reg_adr_type;
	signal register_address2	: reg_adr_type;
	signal result_register_address	: reg_adr_type;

	signal register1	: data_type;
	signal register2	: data_type;
	signal immediate	: data_type;

	component regfile is
		port (
			clk			: in  std_logic;
			reset			: in  std_logic;
			stall			: in  std_logic;
			rdaddr1, rdaddr2	: in  reg_adr_type;
			rddata1, rddata2	: out data_type;
			wraddr			: in  reg_adr_type;
			wrdata			: in  data_type;
			regwrite		: in  std_logic
		);
	end component;

	signal source_register1 : std_logic;
	signal source_register2 : std_logic;
	signal source_immediate : std_logic;

	signal memory_read	: std_logic;
	signal memory_write	: std_logic;

	signal branch		: branch_type;


	signal writeback	: std_logic;
	signal writeback_source	: wbsrc_type;

	signal alu_op		: alu_op_type;
	signal branch_op	: branch_type;
	signal mem_type		: memtype_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		instruction <= NOP_INST;
		pc <= ZERO_PC;
	elsif rising_edge(clk) then

		if stall = '1' then
			pc <= pc;
			instruction <= instruction;
		else
			pc <= pc_in;
			instruction <= instr;
		end if;

		if flush = '1' then
			instruction <= NOP_INST;
		end if;
	end if;
end process;

instruction_next <= instruction;
pc_next <= pc;

opcode <= instruction(OPCODE_BIT_WIDTH-1 downto 0);

decode_instruction_format : process(opcode)
begin
	case opcode is
		when OPC_LOAD =>
			instruction_format <= I;
		when OPC_STORE =>
			instruction_format <= S;
		when OPC_BRANCH =>
			instruction_format <= B;
		when OPC_JALR =>
			instruction_format <= I;
		when OPC_JAL =>
			instruction_format <= J;
		when OPC_OP_IMM =>
			instruction_format <= I;
		when OPC_OP =>
			instruction_format <= R;
		when OPC_AUIPC =>
			instruction_format <= U;
		when OPC_LUI =>
			instruction_format <= U;
		when OPC_NOP =>
			instruction_format <= I;
		when others =>
			instruction_format <= INVALID;
	end case;
end process;

decode_funct7 : process(instruction_format, instruction)
begin
	funct7 <= (others => 'X');
	case instruction_format is
		when R =>
			funct7 <= instruction(31 downto 25);
		when others =>
	end case;
end process;

decode_funct3 : process(all)
begin
	funct3 <= (others => 'X');
	case instruction_format is
		when R|I|S|B =>
			funct3 <= instruction(14 downto 12);
		when others =>
	end case;
end process;

decode_register_adddress1 : process(instruction_format, instruction)
begin
	register_address1 <= (others => 'X');
	case instruction_format is
		when R|I|S|B =>
			register_address1 <= instruction(19 downto 15);
		when others =>
	end case;
end process;

decode_register_address2 : process(instruction_format, instruction)
begin
	register_address2 <= (others => 'X');
	case instruction_format is
		when R|S|B =>
			register_address2 <= instruction(24 downto 20);
		when others =>
	end case;
end process;

decode_result_address : process(instruction_format, instruction)
begin
	result_register_address <= (others => 'X');
	case instruction_format is
		when R|I|U|J =>
			result_register_address <= instruction(11 downto 7);
		when others =>
	end case;
end process;

decode_immediate : process(instruction_format, instruction)
begin
	immediate <= (others => 'X');
	case instruction_format is
		when I =>
			immediate(31 downto 11)	<= (others => instruction(31));
			immediate(10 downto  0)	<= instruction(30 downto 20);
		when S =>
			immediate(31 downto 11)	<= (others => instruction(31));
			immediate(10 downto 5)	<= instruction(30 downto 25);
			immediate(4 downto 0)	<= instruction(11 downto 7);
		when B =>
			immediate(31 downto 12)	<= (others => instruction(31));
			immediate(11)		<= instruction(7);
			immediate(10 downto 5)	<= instruction(30 downto 25);
			immediate(4 downto 1)	<= instruction(11 downto 8);
			immediate(0)		<= '0';
		when U =>
			immediate(31 downto 12)	<= instruction(31 downto 12);
			immediate(11 downto 0)	<= (others => '0');
		when J =>
			immediate(31 downto 20)	<= (others => instruction(31));
			immediate(19 downto 12)	<= instruction(19 downto 12);
			immediate(11)		<= instruction(20);
			immediate(10 downto 1)	<= instruction(30 downto 21);
			immediate(0)		<= '0';
		when others =>
	end case;
end process;

which_register_or_immediate : process(instruction_format)
begin
	source_register1 <= '0';
	source_register2 <= '0';
	source_immediate <= '0';
	case instruction_format is
		when R =>
			source_register1 <= '1';
			source_register2 <= '1';
			source_immediate <= '0';
		when I =>
			source_register1 <= '1';
			source_register2 <= '0';
			source_immediate <= '1';
		when S|B =>
			source_register1 <= '1';
			source_register2 <= '1';
			source_immediate <= '1';
		when U|J =>
			source_register1 <= '0';
			source_register2 <= '0';
			source_immediate <= '1';
		when others =>
	end case;
end process;

check_if_writeback : process(instruction_format)
begin
	writeback <= '0';
	case instruction_format is
		when R =>
			writeback <= '1';
		when I =>
			writeback <= '1';
		when S|B =>
			writeback <= '0';
		when U|J =>
			writeback <= '1';
		when others =>
	end case;
end process;

fetch_alu_opcode : process(opcode, funct3, funct7, immediate)
begin
	exc_dec <= '0';

	memory_read <= '0';
	memory_write <= '0';
	mem_type <= MEM_W;

	branch <= BR_NOP;

	writeback_source <= WBS_ALU;

	case opcode is
		when OPC_LOAD =>
			-- I Instruction
			writeback_source <= WBS_MEM;
			memory_read <= '1';
			case funct3 is
				when "000" =>
					-- LB rd,rs1,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_B;
				when "001" =>
					-- LH rd,rs1,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_H;
				when "010" =>
					-- LW rd,rs1,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_W;
				when "100" =>
					-- LBU rd,rs1,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_BU;
				when "101" =>
					-- LHU rd,rs1,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_HU;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_STORE =>
			-- S Instruction
			memory_write <= '1';
			case funct3 is
				when "000" =>
					-- SB rs1,rs2,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_B;
				when "001" =>
					-- SH rs1,rs2,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_H;
				when "010" =>
					-- SW rs1,rs2,imm
					alu_op <= ALU_ADD;
					mem_type <= MEM_W;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_BRANCH =>
			-- B Instruction
			case funct3 is
				when "000" =>
					-- BEQ rs1,rs2,imm
					-- use zero flag to determine if equal
					alu_op <= ALU_SUB;
					branch <= BR_CND;
				when "001" =>
					-- BNE rs1,rs2,imm
					-- use zero flag to determine if not equal
					alu_op <= ALU_SUB;
					branch <= BR_CNDI;
				when "100" =>
					-- BLT rs1,rs2,imm
					-- use zero flag to determine if smaller
					alu_op <= ALU_SLT;
					branch <= BR_CND;
				when "101" =>
					-- BGE rs1,rs2,imm
					-- use zero flag to determine if not smaller
					alu_op <= ALU_SLT;
					branch <= BR_CNDI;
				when "110" =>
					-- BLTU rs1,rs2,imm
					-- use zero flag to determine if smaller
					alu_op <= ALU_SLTU;
					branch <= BR_CND;
				when "111" =>
					-- BGEU rs1,rs2,imm
					-- use zero flag to determine if not smaller
					alu_op <= ALU_SLTU;
					branch <= BR_CNDI;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_JALR =>
			-- I Instruction
			writeback_source <= WBS_OPC;
			case funct3 is
				when "000" =>
					-- JALR rd,rs1,imm
					alu_op <= ALU_ADD;
					branch <= BR_BR;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_JAL =>
			-- J Instruction
			-- JAL rd, imm
			alu_op <= ALU_ADD;
			branch <= BR_BR;
			writeback_source <= WBS_OPC;
		when OPC_OP_IMM =>
			-- I Instruction
			case funct3 is
				when "000" =>
					-- ADDI rd,rs1,imm
					alu_op <= ALU_ADD;
				when "010" =>
					-- SLTI rd,rs1,imm
					alu_op <= ALU_SLT;
				when "011" =>
					-- SLTIU rd,rs1,imm
					alu_op <= ALU_SLTU;
				when "100" =>
					-- XORI rd,rs1,imm
					alu_op <= ALU_XOR;
				when "110" =>
					-- ORI rd,rs1,imm
					alu_op <= ALU_OR;
				when "111" =>
					-- ANDI rd,rs1,imm
					alu_op <= ALU_AND;
				when "001" =>
					if immediate(10) = '0' then
						-- SLLI rd,rs1,shamt
						alu_op <= ALU_SLL;
					else
						exc_dec <= '1';
					end if;
				when "101" =>
					-- should read the smallprint of the assignment
					if immediate(10) = '0' then
						-- SRLI rd,rs1,shamt
						alu_op <= ALU_SRL;
					else
						-- SRAI rs,rs1,shamt
						alu_op <= ALU_SRA;
					end if;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_OP =>
			-- R Instruction
			case funct3&funct7 is
				when "000"&"0000000" =>
					-- ADD rd,rs1,rs2
					alu_op <= ALU_ADD;
				when "000"&"0100000" =>
					-- SUB rd,rs1,rs2
					alu_op <= ALU_SUB;
				when "001"&"0000000" =>
					-- SLL rd,rs1,rs2
					alu_op <= ALU_SLL;
				when "010"&"0000000" =>
					-- SLT rd,rs1,rs2
					alu_op <= ALU_SLT;
				when "011"&"0000000" =>
					-- SLTU rd,rs1,rs2
					alu_op <= ALU_SLTU;
				when "100"&"0000000" =>
					-- XOR rd,rs1,rs2
					alu_op <= ALU_XOR;
				when "101"&"0000000" =>
					-- SRL rd,rs1,rs2
					alu_op <= ALU_SRL;
				when "101"&"0100000" =>
					-- SRA rd,rs1,rs2
					alu_op <= ALU_SRA;
				when "110"&"0000000" =>
					-- OR rd,rs1,rs2
					alu_op <= ALU_OR;
				when "111"&"0000000" =>
					-- AND rd,rs1,rs2
					alu_op <= ALU_AND;
				when others =>
					exc_dec <= '1';
			end case;
		when OPC_AUIPC =>
			-- U Instruction
			-- AUIPC rd, imm
			-- forward imm<<12 directly to alu through B
			alu_op <= ALU_ADD;
		when OPC_LUI =>
			-- U Instruction
			-- LUI rd, imm
			alu_op <= ALU_NOP;
			-- forward imm<<12 directly to alu through B
		when OPC_NOP =>
			-- FENCE
			alu_op <= ALU_NOP;
		when others =>
			exc_dec <= '1';
	end case;
end process;

-- pure instruction (register inside)
-- write back stage signals directly into regfile
regfile_inst : regfile
port map(
	clk		=> clk,
	reset		=> reset,
	stall		=> stall,
	rdaddr1		=> instr(19 downto 15),
	rdaddr2		=> instr(24 downto 20),
	rddata1		=> register1,
	rddata2		=> register2,
	wraddr		=> reg_write.reg,
	wrdata		=> reg_write.data,
	regwrite	=> reg_write.write
);

output : process(all)
begin
	-- pc_out
	pc_out <= pc;

	-- exec_op
	exec_op.aluop <= alu_op;
	exec_op.alusrc1 <= source_register1;
	exec_op.alusrc2 <= source_register2;
	exec_op.alusrc3 <= source_immediate;
	exec_op.rs1 <= register_address1;
	exec_op.rs2 <= register_address2;
	exec_op.readdata1 <= register1;
	exec_op.readdata2 <= register2;
	exec_op.imm <= immediate;

	-- mem_op

	mem_op.branch <= branch;
	mem_op.mem.memread <= memory_read;
	mem_op.mem.memwrite <= memory_write;
	mem_op.mem.memtype <= mem_type;

	-- wb_op
	wb_op.rd <= result_register_address;
	wb_op.write <= writeback;
	wb_op.src <= writeback_source;
end process;
end architecture;
