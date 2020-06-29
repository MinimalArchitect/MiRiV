library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity exec is
	port (
		clk		: in  std_logic;
		reset		: in  std_logic;
		stall		: in  std_logic;
		flush		: in  std_logic;

		-- from DEC
		op		: in  exec_op_type;
		pc_in		: in  pc_type;

		-- to MEM
		pc_old_out	: out pc_type;
		pc_new_out	: out pc_type;
		aluresult	: out data_type;
		wrdata		: out data_type;
		zero		: out std_logic;

		memop_in	: in  mem_op_type;
		memop_out	: out mem_op_type;
		wbop_in		: in  wb_op_type;
		wbop_out	: out wb_op_type;

		-- FWD
		exec_op		: out exec_op_type;
		reg_write_mem	: in  reg_write_type;
		reg_write_wr	: in  reg_write_type
	);
end exec;

architecture rtl of exec is
	signal operation		: exec_op_type;
	signal program_counter		: pc_type;
	signal memory_operation		: mem_op_type;
	signal writeback_operation	: wb_op_type;

	signal next_operation		: exec_op_type;
	signal next_program_counter	: pc_type;
	signal next_memory_operation	: mem_op_type;
	signal next_writeback_operation	: wb_op_type;

	component alu is
		port (
			op	: in  alu_op_type;
			A, B	: in  data_type;
			R	: out data_type	:= (others => '0');
			Z	: out std_logic	:= '0'
		);
	end component;

	signal alu_a	: data_type;
	signal alu_b	: data_type;

	signal pc_add_a	: pc_type;
	signal pc_add_b	: pc_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		operation <= EXEC_NOP;
		program_counter <= ZERO_PC;
		memory_operation <= MEM_NOP;
		writeback_operation <= WB_NOP;
	elsif rising_edge(clk) then
		program_counter <= next_program_counter;
		operation <= next_operation;
		memory_operation <= next_memory_operation;
		writeback_operation <= next_writeback_operation;
	end if;
end process;

state_input : process(flush, stall, program_counter, operation, memory_operation, writeback_operation, pc_in, op, memop_in, wbop_in)
begin
	if flush = '1' then
		next_program_counter <= pc_in;
		next_operation <= EXEC_NOP;
		next_memory_operation <= MEM_NOP;
		next_writeback_operation <= WB_NOP;
	elsif stall = '1' then
		next_program_counter <= program_counter;
		next_operation <= operation;
		next_memory_operation <= memory_operation;
		next_writeback_operation <= writeback_operation;
	else
		next_program_counter <= pc_in;
		next_operation <= op;
		next_memory_operation <= memop_in;
		next_writeback_operation <= wbop_in;
	end if;
end process;

pc_old_out <= program_counter;

new_program_counter : process(operation, program_counter)
	variable tmp_a		: unsigned(pc_type'range);
	variable tmp_b		: unsigned(pc_type'range);
	variable selector	: std_logic_vector(2 downto 0);
begin
	selector := operation.alusrc3 & operation.alusrc2 & operation.alusrc1;

	tmp_a := (others => '0');
	tmp_b := (others => '0');

	case selector is
		when "000"|"010"|"001"|"011" =>
			tmp_a := unsigned(program_counter);
			tmp_b := (others => '0');
		when "100"|"111" =>
			tmp_a := unsigned(program_counter);
			tmp_b := unsigned(to_pc_type(operation.imm));
		when "101" =>
			tmp_a := unsigned(to_pc_type(operation.imm));
			tmp_b := unsigned(to_pc_type(operation.readdata1));
		when others =>
	end case;
	pc_new_out <= std_logic_vector(tmp_a + tmp_b);
end process;

get_alu_data : process(operation, program_counter)
	variable selector	: std_logic_vector(2 downto 0);
begin
	alu_a <= (others => '0');
	alu_b <= (others => '0');

	selector := operation.alusrc3 & operation.alusrc2 & operation.alusrc1;

	case selector is
		when "000" =>
			alu_b <= operation.imm;
			alu_a <= (others => '0');
		when "010" =>
			alu_a <= to_data_type(program_counter);
			alu_b <= operation.imm;
		when "001" =>
			alu_a <= operation.readdata1;
			alu_b <= operation.imm;
		when "011"|"111" =>
			alu_a <= operation.readdata1;
			alu_b <= operation.readdata2;
		when "100"|"101" =>
			alu_a <= to_data_type(program_counter);
			alu_b <= std_logic_vector(to_unsigned(4, data_type'length));
		when others =>
	end case;
end process;

alu_inst : alu
	port map(
		op => operation.aluop,
		A => alu_a,
		B => alu_b,
		R => aluresult,
		Z => zero
	);

memop_out <= memory_operation;
wbop_out <= writeback_operation;

wrdata <= operation.readdata2;

exec_op <= EXEC_NOP;

end architecture;
