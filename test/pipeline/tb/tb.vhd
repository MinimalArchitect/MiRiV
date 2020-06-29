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
			mem_i_in		: mem_in_type;
			mem_d_in		: mem_in_type;
		end record;

	type OUTPUT is
		record
			mem_i_out		: mem_out_type;
			mem_d_out		: mem_out_type;
		end record;

	signal inp : INPUT := (
		MEM_IN_NOP,
		MEM_IN_NOP
	);
	signal outp : OUTPUT;

	impure function read_next_input(file f : text) return INPUT is
		variable l : line;
		variable result : INPUT;
	begin

	-- instruction memory busy
		l := get_next_valid_line(f);
		result.mem_i_in.busy := str_to_sl(l(1));

	-- instruction memory value
		l := get_next_valid_line(f);
		result.mem_i_in.rddata := bin_to_slv(l.all, INSTR_WIDTH);

	-- data memory busy
		l := get_next_valid_line(f);
		result.mem_d_in.busy := str_to_sl(l(1));

	-- data memory value
		l := get_next_valid_line(f);
		result.mem_d_in.rddata := bin_to_slv(l.all, INSTR_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return OUTPUT is
		variable l : line;
		variable result : OUTPUT;
	begin
		l := get_next_valid_line(f);
		result.mem_i_out.address := bin_to_slv(l.all, ADDR_WIDTH);

		l := get_next_valid_line(f);
		result.mem_i_out.rd := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_i_out.wr := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_i_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);

		l := get_next_valid_line(f);
		result.mem_i_out.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.mem_d_out.address := bin_to_slv(l.all, ADDR_WIDTH);

		l := get_next_valid_line(f);
		result.mem_d_out.rd := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_d_out.wr := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_d_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);

		l := get_next_valid_line(f);
		result.mem_d_out.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : OUTPUT) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);
		if passed then
			report " PASSED: "
			& " instruction=" & to_string(inp.mem_i_in.rddata)
			& " data=" & to_string(inp.mem_d_in.rddata) & lf
			severity note;
		else
			report " FAILED: "
			& " instruction=" & to_string(inp.mem_i_in.rddata)
			& " data=" & to_string(inp.mem_d_in.rddata) & lf
			& "** expected: " 
			& " instruction address=" & to_string(output_ref.mem_i_out.address) 
			& "; rd/wr=" & to_string(output_ref.mem_i_out.rd) & "/" & to_string(output_ref.mem_i_out.wr)
			& "; byteena=" & to_string(output_ref.mem_d_out.byteena)
			& "; wrdata=" & to_string(output_ref.mem_d_out.wrdata)
			& " data address=" & to_string(output_ref.mem_d_out.address)
			& "; rd/wr=" & to_string(output_ref.mem_d_out.rd) & "/" & to_string(output_ref.mem_d_out.wr)
			& "; byteena=" & to_string(output_ref.mem_d_out.byteena)
			& "; wrdata=" & to_string(output_ref.mem_d_out.wrdata) & lf
			& "** actual: " 
			& " instruction address=" & to_string(outp.mem_i_out.address)
			& "; rd/wr=" & to_string(outp.mem_i_out.rd) & "/" & to_string(outp.mem_i_out.wr)
			& "; byteena=" & to_string(outp.mem_i_out.byteena) 
			& "; wrdata=" & to_string(outp.mem_i_out.wrdata) 
			& " data address=" & to_string(outp.mem_d_out.address) 
			& "; rd/wr=" & to_string(outp.mem_d_out.rd) & "/" & to_string(outp.mem_d_out.wr)
			& "; byteena=" & to_string(outp.mem_d_out.byteena)
			& "; wrdata=" & to_string(outp.mem_d_out.wrdata) & lf
			severity error;
		end if;
	end procedure;

begin

	pipeline_inst : entity work.pipeline
		port map
		(
			clk	=> clk,
			reset	=> res_n,

			-- instruction interface
			mem_i_out	=> outp.mem_i_out,
			mem_i_in	=> inp.mem_i_in,

			-- data interface
			mem_d_out	=> outp.mem_d_out,
			mem_d_in	=> inp.mem_d_in
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
