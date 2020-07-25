library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
	port (
		clk, reset	: in std_logic;
		stall		: in std_logic;

		stall_fetch	: out std_logic;
		stall_dec	: out std_logic;
		stall_exec	: out std_logic;
		stall_mem	: out std_logic;
		stall_wb	: out std_logic;

		flush_fetch	: out std_logic;
		flush_dec	: out std_logic;
		flush_exec	: out std_logic;
		flush_mem	: out std_logic;
		flush_wb	: out std_logic;

		-- from FWD
		wb_op_mem	: in  wb_op_type;
		exec_op		: in  exec_op_type;

		pcsrc_in	: in std_logic;
		pcsrc_out	: out std_logic
	);
end ctrl;

architecture rtl of ctrl is
begin

stall_cntrl : process(stall, wb_op_mem, exec_op)
begin
	stall_fetch <= stall;
	stall_dec <= stall;
	stall_exec <= stall;
	stall_mem <= stall;
	stall_wb <= stall;
/*
	if wb_op_mem.rd = exec_op.rs1 and wb_op_mem.src = WBS_MEM then
		stall_fetch <= '1';
		stall_dec <= '1';
		stall_exec <= '1';
		stall_mem <= '1';
		stall_wb <= '1';
	end if;

	if wb_op_mem.rd = exec_op.rs2 and wb_op_mem.src = WBS_MEM then
		stall_fetch <= '1';
		stall_dec <= '1';
		stall_exec <= '1';
		stall_mem <= '1';
		stall_wb <= '1';
	end if;
*/
end process;

-- if pcsrc_in is high, let a clock cycle pass, then flush decode, execute and memory stage.

flush_cntrl : process(pcsrc_in)
begin
	flush_fetch <= '0';
	flush_dec <= '0';
	flush_exec <= '0';
	flush_mem <= '0';
	flush_wb <= '0';

	pcsrc_out <= pcsrc_in;

	-- these stages are affected from a branch
	if pcsrc_in = '1' then
		flush_dec <= '1';
		flush_exec <= '1';
		flush_mem <= '1';
	end if;
end process;

end architecture;
