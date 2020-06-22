library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

use work.mem_pkg.all;
use work.op_pkg.all;
use work.core_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is

	constant CLK_PERIOD : time := 10 ns;

	signal clk : std_logic;
	signal res_n : std_logic := '0';

	file input_file : text;
	file output_ref_file : text;

	subtype data is std_logic_vector(DATA_WIDTH-1 downto 0);

	type INPUT is
		record
			stall	: std_logic;
			flush	: std_logic;
			pcsrc	: std_logic;
			pc_in	: pc_type;
			mem_in	: mem_in_type;
		end record;

	type OUTPUT is
		record
			mem_busy	: std_logic;
			pc_out		: pc_type;
			instr		: instr_type;
			mem_out		: mem_out_type;
		end record;

	signal inp : INPUT := (
		'0',
		'0',
		'0',
		(others => '0'),
		MEM_IN_NOP
	);
	signal outp : OUTPUT;

	impure function read_next_input(file f : text) return INPUT is
		variable l : line;
		variable result : INPUT;
	begin
	-- read stall
		l := get_next_valid_line(f);
		result.stall := str_to_sl(l(1));

	-- read flush
		l := get_next_valid_line(f);
		result.flush := str_to_sl(l(1));

	-- read pcsrc
		l := get_next_valid_line(f);
		result.pcsrc := str_to_sl(l(1));

	-- read pc_in
		l := get_next_valid_line(f);
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);

	-- read mem_in.busy
		l := get_next_valid_line(f);
		result.mem_in.busy := str_to_sl(l(1));
	-- read mem_in.rddata
		l := get_next_valid_line(f);
		result.mem_in.rddata := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return OUTPUT is
		variable l : line;
		variable result : OUTPUT;
	begin
	-- mem_busy
		l := get_next_valid_line(f);
		result.mem_busy := str_to_sl(l(1));
	-- pc_out
		l := get_next_valid_line(f);
		result.pc_out := bin_to_slv(l.all, PC_WIDTH);
	-- instr
		l := get_next_valid_line(f);
		result.instr := hex_to_slv(l.all, INSTR_WIDTH);
	-- mem_out.address
		l := get_next_valid_line(f);
		result.mem_out.address := bin_to_slv(l.all, ADDR_WIDTH);
	-- mem_out.rd
		l := get_next_valid_line(f);
		result.mem_out.rd := str_to_sl(l(1));
	-- mem_out.wr
		l := get_next_valid_line(f);
		result.mem_out.wr := str_to_sl(l(1));
	-- mem_out.byteena
		l := get_next_valid_line(f);
		result.mem_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);
	-- mem_out.wrdata
		l := get_next_valid_line(f);
		result.mem_out.wrdata := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : OUTPUT) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);
 -- TODO
		if passed then
			report " PASSED: "
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " pcsrc=" & to_string(inp.pcsrc)
			& " pcsrc=" & slv_to_bin(inp.pc_in)
			& " busy=" & to_string(inp.mem_in.busy)
			& " rddata=" & slv_to_hex(inp.mem_in.rddata) & lf

			& "** current pc=0x" & slv_to_hex(outp.pc_out) &
			  " instr=0x" & slv_to_hex(outp.instr) &
			  " mem_busy=" & to_string(outp.mem_busy) &
			  " fetch address=0x" & slv_to_bin(outp.mem_out.address) & lf
			severity note;
		else
			report "FAILED: "
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)
			& " pcsrc=" & to_string(inp.pcsrc)
			& " pc_in=" & slv_to_bin(inp.pc_in)
			& " busy=" & to_string(inp.mem_in.busy)
			& " rddata=0x" & slv_to_hex(inp.mem_in.rddata) & lf

			& "** expected: pc_out=0x" & slv_to_hex(output_ref.pc_out) &
			  " instr=0x" & slv_to_hex(output_ref.instr) &
			  " mem_busy=" & to_string(output_ref.mem_busy) &
			  " fetch address=0x" & slv_to_bin(output_ref.mem_out.address) & lf

			& "** actual:   pc_out=0x" & slv_to_hex(outp.pc_out) &
			  " instr=0x" & slv_to_hex(outp.instr) &
			  " mem_busy=" & to_string(outp.mem_busy) &
			  " fetch address=0x" & slv_to_bin(outp.mem_out.address) & lf & lf
			severity error;
		end if;
	end procedure;

begin

	fetch_inst : entity work.fetch
		port map
		(
			clk => clk,
			reset => res_n,
			stall => inp.stall,
			flush => inp.flush,
			mem_busy => outp.mem_busy,
			pcsrc => inp.pcsrc,
			pc_in => inp.pc_in,
			pc_out => outp.pc_out,
			instr => outp.instr,
			mem_out => outp.mem_out,
			mem_in => inp.mem_in
		);

	stimulus : process
		variable fstatus: file_open_status;
	begin
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
			timeout(1, CLK_PERIOD);
		end loop;

		wait;
	end process;

	output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : OUTPUT;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);

			wait until falling_edge(clk);
			check_output(output_ref);
			wait until rising_edge(clk);
		end loop;

		wait;
	end process;

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD);
		wait;
	end process;

	generate_reset : process
	begin
		res_n <= '0';
		wait until rising_edge(clk);
		res_n <= '1';
		wait;
	end process;

end architecture;
