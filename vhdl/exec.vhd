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

	component fwd is
		port (
			reg_write_mem : in reg_write_type;
			reg_write_wb  : in reg_write_type;
			reg    : in  reg_adr_type;
			val    : out data_type;
			do_fwd : out std_logic
		);
	end component;


	signal alu_a	: data_type;
	signal alu_b	: data_type;

	signal pc_add_a	: pc_type;
	signal pc_add_b	: pc_type;

	signal fwddata1		: data_type;
	signal fwddata2		: data_type;
	signal do_fwddata1	: std_logic;
	signal do_fwddata2	: std_logic;
	signal data1		: data_type;
	signal data2		: data_type;
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

state_input : process(reset, clk, pc_in, program_counter, operation, memory_operation, writeback_operation, op, memop_in, wbop_in, flush, stall)
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

new_program_counter : process(all)
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
			tmp_b := unsigned(to_pc_type(data1));
		when others =>
	end case;
	pc_new_out <= std_logic_vector(tmp_a + tmp_b);
end process;

get_alu_data : process(all)
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
			alu_a <= data1;
			alu_b <= operation.imm;
		when "011"|"111" =>
			alu_a <= data1;
			alu_b <= data2;
		when "100"|"101" =>
			alu_a <= to_data_type(program_counter);
			alu_b <= std_logic_vector(to_unsigned(4, data_type'length));
		when others =>
	end case;
end process;

alu_inst : entity work.alu
	port map(
		op => operation.aluop,
		A => alu_a,
		B => alu_b,
		R => aluresult,
		Z => zero
	);
	
memop_out <= memory_operation;
wbop_out <= writeback_operation;

wrdata <= data2;

exec_op <= operation;

fwd_inst1 : entity work.fwd
	port map(
		reg_write_mem	=> reg_write_mem,
		reg_write_wb	=> reg_write_wr,
		reg		=> operation.rs1,
		val		=> fwddata1,
		do_fwd		=> do_fwddata1
	);

forward_data1 : process(all)
begin
	if (do_fwddata1 = '1') then
		data1 <= fwddata1;
	else
		data1 <= operation.readdata1;
	end if;
end process;

fwd_inst2 : entity work.fwd
	port map(
		reg_write_mem	=> reg_write_mem,
		reg_write_wb	=> reg_write_wr,
		reg		=> operation.rs2,
		val		=> fwddata2,
		do_fwd		=> do_fwddata2
	);

forward_data2 : process(all)
begin
	if (do_fwddata2 = '1') then
		data2 <= fwddata2;
	else
		data2 <= operation.readdata2;
	end if;
end process;

end architecture;

