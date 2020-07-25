library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity mem is
	 port (
		clk		: in  std_logic;
		reset		: in  std_logic;
		stall		: in  std_logic;
		flush		: in  std_logic;

		-- to Ctrl
		mem_busy	: out std_logic;

		-- from EXEC
		mem_op		: in  mem_op_type;
		wbop_in		: in  wb_op_type;
		pc_new_in	: in  pc_type;
		pc_old_in	: in  pc_type;
		aluresult_in	: in  data_type;
		wrdata		: in  data_type;
		zero		: in  std_logic;

		-- to EXEC (forwarding)
		reg_write	: out reg_write_type;

		-- to FETCH
		pc_new_out	: out pc_type;
		pcsrc		: out std_logic;

		-- to WB
		wbop_out	: out wb_op_type;
		pc_old_out	: out pc_type;
		aluresult_out	: out data_type;
		memresult	: out data_type;

		-- memory controller interface
		mem_out		: out mem_out_type;
		mem_in		: in  mem_in_type;

		-- exceptions
		exc_load	: out std_logic;
		exc_store	: out std_logic
	 );
end mem;

architecture rtl of mem is
	signal memory_operation		: mem_op_type;
	signal memory_operation_next	: mem_op_type;

	signal writeback_operation	: wb_op_type;
	signal writeback_operation_next	: wb_op_type;

	signal pc_new			: pc_type;
	signal pc_new_next		: pc_type;

	signal pc_old			: pc_type;
	signal pc_old_next		: pc_type;

	signal aluresult		: data_type;
	signal aluresult_next		: data_type;

	signal write_data		: data_type;
	signal write_data_next		: data_type;
begin
	memu_inst : entity work.memu
	port map(
		op	=> memory_operation.mem,
		A	=> aluresult,
		W	=> write_data,
		R	=> memresult,
		B	=> mem_busy,
		XL	=> exc_load,
		XS	=> exc_store,
		-- to memory controller
		D	=> mem_in,
		M	=> mem_out
	);

	sync : process(clk, reset)
	begin
		if reset = '0' then
			memory_operation <= MEM_NOP;
			writeback_operation <= WB_NOP;
			pc_new <= ZERO_PC;
			pc_old <= ZERO_PC;
			aluresult <= ZERO_DATA;
			write_data <= ZERO_DATA;
		elsif rising_edge(clk) then
			memory_operation <= memory_operation_next;
			writeback_operation <= writeback_operation_next;
			pc_new <= pc_new_next;
			pc_old <= pc_old_next;
			aluresult <= aluresult_next;
			write_data <= write_data_next;
		end if;
	end process;

	proc : process(flush, stall, memory_operation, writeback_operation, pc_new, pc_old, aluresult, write_data, mem_op, wbop_in, pc_new_in, pc_old_in, aluresult_in, wrdata)
	begin
		if flush = '1' then
			memory_operation_next <= MEM_NOP;
			writeback_operation_next <= WB_NOP;
			pc_new_next <= ZERO_PC;
			pc_old_next <= ZERO_PC;
			aluresult_next <= ZERO_DATA;
			write_data_next <= ZERO_DATA;
		elsif stall = '1' then
			memory_operation_next <= memory_operation;
			memory_operation_next.mem.memread <= '0';
			memory_operation_next.mem.memwrite <= '0';
			writeback_operation_next <= writeback_operation;
			pc_new_next <= pc_new;
			pc_old_next <= pc_old;
			aluresult_next <= aluresult;
			write_data_next <= write_data;
		else
			memory_operation_next <= mem_op;
			writeback_operation_next <= wbop_in;
			pc_new_next <= pc_new_in;
			pc_old_next <= pc_old_in;
			aluresult_next <= aluresult_in;
			write_data_next <= wrdata;
		end if;
	end process;

	output : process (writeback_operation, pc_new, pc_old, aluresult, memory_operation, zero)
	begin
		wbop_out <= writeback_operation;
		pc_new_out <= pc_new;
		pcsrc <= '0';
		pc_old_out <= pc_old;
		aluresult_out <= aluresult;
		case memory_operation.branch is
			when BR_NOP =>
				pcsrc <= '0';
			when BR_BR =>
				pcsrc <= '1';
			when BR_CND =>
				pcsrc <= zero;
			when BR_CNDI =>
				pcsrc <= not zero;
			when others =>
		end case;
	end process;

	forwarding : process(writeback_operation, aluresult, memresult)
	begin
		reg_write.write <= writeback_operation.write;
		reg_write.reg <= writeback_operation.rd;
		if writeback_operation.src = WBS_MEM then
			reg_write.data <= memresult;
		else
			reg_write.data <= aluresult;
		end if;
	end process;
end architecture;
