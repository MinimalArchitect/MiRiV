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

	constant OPCODE_BIT_WIDTH : integer := 7;
	constant FUNCT7_BIT_WIDTH : integer := 7;
	constant FUNCT3_BIT_WIDTH : integer := 3;

	subtype opcode_type      is std_logic_vector(OPCODE_BIT_WIDTH-1 downto 0);

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


	signal funct7	: std_logic_vector(FUNCT7_BIT_WIDTH-1 downto 0);
	signal funct3	: std_logic_vector(FUNCT3_BIT_WIDTH-1 downto 0);

        signal program_counter	: pc_type;
        signal instruction	: instr_type;

	signal opcode	: std_logic_vector(OPCODE_BIT_WIDTH-1 downto 0);

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

	signal source : std_logic_vector(2 downto 0);

	signal memory_read	: std_logic;
	signal memory_write	: std_logic;

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
		program_counter <= ZERO_PC;
	elsif rising_edge(clk) then

		if stall = '1' then
			program_counter <= program_counter;
			instruction <= instruction;
		else
			program_counter <= pc_in;
			instruction <= instr;
		end if;

		if flush = '1' then
			instruction <= NOP_INST;
		end if;
	end if;
end process;

opcode <= instruction(OPCODE_BIT_WIDTH-1 downto 0);

funct7 <= instruction(31 downto 25);
funct3 <= instruction(14 downto 12);

register_address1 <= instruction(19 downto 15);
register_address2 <= instruction(24 downto 20);

result_register_address <= instruction(11 downto 7);

decode_immediate : process(opcode, instruction)
begin
	immediate <= (others => '0');
	case opcode is
		when OPC_LOAD|OPC_JALR|OPC_OP_IMM|OPC_NOP =>
			immediate(31 downto 11)	<= (others => instruction(31));
			immediate(10 downto  0)	<= instruction(30 downto 20);
		when OPC_STORE =>
			immediate(31 downto 11)	<= (others => instruction(31));
			immediate(10 downto 5)	<= instruction(30 downto 25);
			immediate(4 downto 0)	<= instruction(11 downto 7);
		when OPC_BRANCH =>
			immediate(31 downto 12)	<= (others => instruction(31));
			immediate(11)		<= instruction(7);
			immediate(10 downto 5)	<= instruction(30 downto 25);
			immediate(4 downto 1)	<= instruction(11 downto 8);
			immediate(0)		<= '0';
		when OPC_AUIPC|OPC_LUI =>
			immediate(31 downto 12)	<= instruction(31 downto 12);
			immediate(11 downto 0)	<= (others => '0');
		when OPC_JAL =>
			immediate(31 downto 20)	<= (others => instruction(31));
			immediate(19 downto 12)	<= instruction(19 downto 12);
			immediate(11)		<= instruction(20);
			immediate(10 downto 1)	<= instruction(30 downto 21);
			immediate(0)		<= '0';
		when others =>
	end case;
end process;

which_register_or_immediate : process(opcode)
begin
	source <= "000";
	case opcode is
		when OPC_LOAD =>
			source <= "001";
		when OPC_STORE =>
			source <= "001";
		when OPC_BRANCH =>
			source <= "111";
		when OPC_JALR =>
			source <= "101";
		when OPC_JAL =>
			source <= "100";
		when OPC_OP_IMM =>
			source <= "001";
		when OPC_OP =>
			source <= "011";
		when OPC_AUIPC =>
			source <= "010";
		when OPC_LUI =>
			source <= "000";
		when OPC_NOP =>
			source <= "000";
		when others =>
	end case;
end process;

check_if_writeback : process(opcode)
begin
	writeback <= '0';
	case opcode is
		when OPC_OP =>
			writeback <= '1';
		when OPC_LOAD|OPC_JALR|OPC_OP_IMM|OPC_NOP =>
			writeback <= '1';
		when OPC_STORE|OPC_BRANCH =>
			writeback <= '0';
		when OPC_AUIPC|OPC_LUI|OPC_JAL =>
			writeback <= '1';
		when others =>
	end case;

	if opcode = OPC_NOP then
		writeback <= '0';
	end if;
end process;

memory_type : process(opcode, funct3)
begin
	mem_type <= MEM_W;
	case opcode is
		when OPC_LOAD =>
			case funct3 is
				when "000" =>
					mem_type <= MEM_B;
				when "001" =>
					mem_type <= MEM_H;
				when "010" =>
					mem_type <= MEM_W;
				when "100" =>
					mem_type <= MEM_BU;
				when "101" =>
					mem_type <= MEM_HU;
				when others =>
			end case;
		when OPC_STORE =>
			case funct3 is
				when "000" =>
					mem_type <= MEM_B;
				when "001" =>
					mem_type <= MEM_H;
				when "010" =>
					mem_type <= MEM_W;
				when others =>
			end case;
		when others =>
	end case;
end process;

with opcode select
memory_read <=
	'1' when OPC_LOAD,
	'0' when others;

with opcode select
memory_write <=
	'1' when OPC_STORE,
	'0' when others;

wb_source : process(opcode)
begin
	writeback_source <= WBS_ALU;
	case opcode is
		when OPC_LOAD =>
			writeback_source <= WBS_MEM;
		when OPC_STORE =>
			writeback_source <= WBS_ALU;
		when OPC_BRANCH =>
			writeback_source <= WBS_ALU;
		when OPC_JALR =>
			writeback_source <= WBS_OPC;
		when OPC_JAL =>
			writeback_source <= WBS_OPC;
		when OPC_OP_IMM =>
			writeback_source <= WBS_ALU;
		when OPC_OP =>
			writeback_source <= WBS_ALU;
		when OPC_AUIPC =>
			writeback_source <= WBS_ALU;
		when OPC_LUI =>
			writeback_source <= WBS_ALU;
		when OPC_NOP =>
			writeback_source <= WBS_ALU;
		when others =>
	end case;
end process;

fetch_alu_opcode : process(opcode, funct3, funct7, immediate)
begin
	alu_op <= ALU_NOP;
	case opcode is
		when OPC_LOAD =>
			case funct3 is
				when "000" =>
					alu_op <= ALU_ADD;
				when "001" =>
					alu_op <= ALU_ADD;
				when "010" =>
					alu_op <= ALU_ADD;
				when "100" =>
					alu_op <= ALU_ADD;
				when "101" =>
					alu_op <= ALU_ADD;
				when others =>
			end case;
		when OPC_STORE =>
			case funct3 is
				when "000" =>
					alu_op <= ALU_ADD;
				when "001" =>
					alu_op <= ALU_ADD;
				when "010" =>
					alu_op <= ALU_ADD;
				when others =>
			end case;
		when OPC_BRANCH =>
			case funct3 is
				when "000" =>
					alu_op <= ALU_SUB;
				when "001" =>
					alu_op <= ALU_SUB;
				when "100" =>
					alu_op <= ALU_SLT;
				when "101" =>
					alu_op <= ALU_SLT;
				when "110" =>
					alu_op <= ALU_SLTU;
				when "111" =>
					alu_op <= ALU_SLTU;
				when others =>
			end case;
		when OPC_JALR =>
			case funct3 is
				when "000" =>
					alu_op <= ALU_ADD;
				when others =>
			end case;
		when OPC_JAL =>
			alu_op <= ALU_ADD;
		when OPC_OP_IMM =>
			case funct3 is
				when "000" =>
					alu_op <= ALU_ADD;
				when "010" =>
					alu_op <= ALU_SLT;
				when "011" =>
					alu_op <= ALU_SLTU;
				when "100" =>
					alu_op <= ALU_XOR;
				when "110" =>
					alu_op <= ALU_OR;
				when "111" =>
					alu_op <= ALU_AND;
				when "001" =>
					if immediate(10) = '0' then
						alu_op <= ALU_SLL;
					end if;
				when "101" =>
					if immediate(10) = '0' then
						alu_op <= ALU_SRL;
					else
						alu_op <= ALU_SRA;
					end if;
				when others =>
			end case;
		when OPC_OP =>
			-- R Instruction
			case funct3&funct7 is
				when "000"&"0000000" =>
					alu_op <= ALU_ADD;
				when "000"&"0100000" =>
					alu_op <= ALU_SUB;
				when "001"&"0000000" =>
					alu_op <= ALU_SLL;
				when "010"&"0000000" =>
					alu_op <= ALU_SLT;
				when "011"&"0000000" =>
					alu_op <= ALU_SLTU;
				when "100"&"0000000" =>
					alu_op <= ALU_XOR;
				when "101"&"0000000" =>
					alu_op <= ALU_SRL;
				when "101"&"0100000" =>
					alu_op <= ALU_SRA;
				when "110"&"0000000" =>
					alu_op <= ALU_OR;
				when "111"&"0000000" =>
					alu_op <= ALU_AND;
				when others =>
			end case;
		when OPC_AUIPC =>
			alu_op <= ALU_ADD;
		when OPC_LUI =>
			alu_op <= ALU_NOP;
		when OPC_NOP =>
			alu_op <= ALU_NOP;
		when others =>
	end case;
end process;

branch_type : process(opcode, funct3)
begin
	branch_op <= BR_NOP;
	case opcode is
		when OPC_BRANCH =>
			case funct3 is
				when "000"|"100"|"110" =>
					branch_op <= BR_CND;
				when "001"|"101"|"111" =>
					branch_op <= BR_CNDI;
				when others =>
			end case;
		when OPC_JALR =>
			branch_op <= BR_BR;
		when OPC_JAL =>
			branch_op <= BR_BR;
		when others =>
	end case;
end process;

decode_exception : process(opcode, funct3, funct7, immediate)
begin
	exc_dec <= '1';
	case opcode is
		when OPC_LOAD =>
			case funct3 is
				when "000" =>
					exc_dec <= '0';
				when "001" =>
					exc_dec <= '0';
				when "010" =>
					exc_dec <= '0';
				when "100" =>
					exc_dec <= '0';
				when "101" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_STORE =>
			case funct3 is
				when "000" =>
					exc_dec <= '0';
				when "001" =>
					exc_dec <= '0';
				when "010" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_BRANCH =>
			case funct3 is
				when "000" =>
					exc_dec <= '0';
				when "001" =>
					exc_dec <= '0';
				when "100" =>
					exc_dec <= '0';
				when "101" =>
					exc_dec <= '0';
				when "110" =>
					exc_dec <= '0';
				when "111" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_JALR =>
			case funct3 is
				when "000" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_JAL =>
			exc_dec <= '0';
		when OPC_OP_IMM =>
			case funct3 is
				when "000" =>
					exc_dec <= '0';
				when "010" =>
					exc_dec <= '0';
				when "011" =>
					exc_dec <= '0';
				when "100" =>
					exc_dec <= '0';
				when "110" =>
					exc_dec <= '0';
				when "111" =>
					exc_dec <= '0';
				when "001" =>
					if immediate(10) = '0' then
						exc_dec <= '0';
					end if;
				when "101" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_OP =>
			-- R Instruction
			case funct3&funct7 is
				when "000"&"0000000" =>
					exc_dec <= '0';
				when "000"&"0100000" =>
					exc_dec <= '0';
				when "001"&"0000000" =>
					exc_dec <= '0';
				when "010"&"0000000" =>
					exc_dec <= '0';
				when "011"&"0000000" =>
					exc_dec <= '0';
				when "100"&"0000000" =>
					exc_dec <= '0';
				when "101"&"0000000" =>
					exc_dec <= '0';
				when "101"&"0100000" =>
					exc_dec <= '0';
				when "110"&"0000000" =>
					exc_dec <= '0';
				when "111"&"0000000" =>
					exc_dec <= '0';
				when others =>
			end case;
		when OPC_AUIPC =>
			exc_dec <= '0';
		when OPC_LUI =>
			exc_dec <= '0';
		when OPC_NOP =>
			exc_dec <= '0';
		when others =>
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

-- pc_out
pc_out <= program_counter;

-- exec_op
exec_op.aluop <= alu_op;
exec_op.alusrc1 <= source(0);
exec_op.alusrc2 <= source(1);
exec_op.alusrc3 <= source(2);
exec_op.rs1 <= register_address1;
exec_op.rs2 <= register_address2;
exec_op.readdata1 <= register1;
exec_op.readdata2 <= register2;
exec_op.imm <= immediate;

-- mem_op
mem_op.branch <= branch_op;
mem_op.mem.memread <= memory_read;
mem_op.mem.memwrite <= memory_write;
mem_op.mem.memtype <= mem_type;

-- wb_op
wb_op.rd <= result_register_address;
wb_op.write <= writeback;
wb_op.src <= writeback_source;

end architecture;
