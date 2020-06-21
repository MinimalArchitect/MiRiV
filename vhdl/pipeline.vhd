library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity pipeline is
	 port (
		clk		: in  std_logic;
		reset		: in  std_logic;

		-- instruction interface
		mem_i_out	: out mem_out_type;
		mem_i_in	: in  mem_in_type;

		-- data interface
		mem_d_out	: out mem_out_type;
		mem_d_in	: in  mem_in_type
	 );
end pipeline;

architecture impl of pipeline is
	signal stall : std_logic;
	signal flush : std_logic;

	signal mem_busy_fetch	: std_logic;
	signal mem_busy_mem	: std_logic;

	-- FETCH STAGE
	signal pc_fetch			: pc_type;
	signal instr			: instr_type;
	-- DECODE STAGE
	signal pc_decode		: pc_type;
	signal exec_op_decode		: exec_op_type;
	signal mem_op_decode		: mem_op_type;
	signal wb_op_decode		: wb_op_type;
	signal exc_dec			: std_logic;
	-- EXECUTE STAGE
	signal mem_op_execute		: mem_op_type;
	signal pc_old_execute		: pc_type;
	signal pc_new_execute		: pc_type;
	signal aluresult_execute	: data_type;
	signal wrdata			: data_type;
	signal zero			: std_logic;
	signal wb_op_execute		: wb_op_type;
	-- MEMORY STAGE
	signal aluresult_memory		: data_type;
	signal wb_op_mem		: wb_op_type;
	signal memresult		: data_type;
	signal exc_load			: std_logic;
	signal exc_store		: std_logic;
	signal reg_write_memory		: reg_write_type;
	-- WRITEBACK STAGE
	signal pcsrc			: std_logic;
	signal pc_old			: pc_type;
	signal pc_new			: pc_type;
	signal reg_write_writeback	: reg_write_type;
begin
	sync : process(clk, reset)
	begin
		if reset = '0' then
			stall <= '0';
		elsif rising_edge(clk) then
			stall <= '0';
			
			if mem_busy_fetch = '1' or mem_busy_mem = '1' then
				stall <= '1';
			end if;
		end if;
	end process;
	
	flush <= '0';
	
	fetch_inst : entity work.fetch
	port map(
		clk		=> clk,
		reset		=> reset,
		stall		=> stall,
		flush		=> flush,
		mem_busy	=> mem_busy_fetch,
		pcsrc		=> pcsrc,
		pc_in		=> pc_new,
		pc_out		=> pc_fetch,
		instr		=> instr,
		mem_out		=> mem_i_out,
		mem_in		=> mem_i_in
	);
	
	decode_inst : entity work.decode
	port map(
		clk		=> clk,
		reset		=> reset,
		stall		=> stall,
		flush		=> flush,
		pc_in		=> pc_fetch,
		instr		=> instr,
		reg_write	=> reg_write_writeback,
		pc_out		=> pc_decode,
		exec_op		=> exec_op_decode,
		mem_op		=> mem_op_decode,
		wb_op		=> wb_op_decode,
		exc_dec		=> exc_dec
	);
	
	exec_inst : entity work.exec
	port map(
		clk		=> clk,
		reset		=> reset,
		stall		=> stall,
		flush		=> flush,
		op		=> exec_op_decode,
		pc_in		=> pc_decode,
		pc_old_out	=> pc_old_execute,
		pc_new_out	=> pc_new_execute,
		aluresult	=> aluresult_execute,
		wrdata		=> wrdata,
		zero		=> zero,
		memop_in	=> mem_op_decode,
		memop_out	=> mem_op_execute,
		wbop_in		=> wb_op_decode,
		wbop_out	=> wb_op_execute,

		exec_op		=> open,
		reg_write_mem	=> reg_write_memory,
		reg_write_wr	=> reg_write_writeback
	);
	
	mem_inst : entity work.mem
	port map(
		clk		=> clk,
		reset		=> reset,
		stall		=> stall,
		flush		=> flush,
		mem_busy	=> mem_busy_mem,
		mem_op		=> mem_op_execute,
		wbop_in		=> wb_op_execute,
		pc_new_in	=> pc_old_execute,
		pc_old_in	=> pc_new_execute,
		aluresult_in	=> aluresult_execute,
		wrdata		=> wrdata,
		zero		=> zero,
		reg_write	=> reg_write_memory,
		pc_new_out	=> pc_new,
		pcsrc		=> pcsrc,
		wbop_out	=> wb_op_mem,
		pc_old_out	=> pc_old,
		aluresult_out	=> aluresult_memory,
		memresult	=> memresult,
		mem_out		=> mem_d_out,
		mem_in		=> mem_d_in,
		exc_load	=> exc_load,
		exc_store	=> exc_store
	);
	
	wb_inst : entity work.wb
	port map(
		clk		=> clk,
		reset		=> reset,
		stall		=> stall,
		flush		=> flush,
		op		=> wb_op_mem,
		aluresult	=> aluresult_memory,
		memresult	=> memresult,
		pc_old_in	=> pc_old,
		reg_write	=> reg_write_writeback
	);
end architecture;
