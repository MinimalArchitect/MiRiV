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
		('0', (others => '0')),
		('0', (others => '0'))
	);
	signal outp : OUTPUT;

	impure function read_next_input(file f : text) return INPUT is
		variable l : line;
		variable result : INPUT;
	begin
/*
	-- read stall
		l := get_next_valid_line(f);
		result.stall := str_to_sl(l(1));

	-- read flush
		l := get_next_valid_line(f);
		result.flush := str_to_sl(l(1));

	-- read pc_in
		l := get_next_valid_line(f);
		result.pc_in := hex_to_slv(l.all, PC_WIDTH);

	-- instr
		l := get_next_valid_line(f);
		result.instr := bin_to_slv(l.all, INSTR_WIDTH);

	-- read reg_write.write
		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));

	-- read reg_write.reg
		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);

	-- read reg_write.data
		l := get_next_valid_line(f);
		result.reg_write.data := hex_to_slv(l.all, DATA_WIDTH);
*/
		return result;
	end function;

	impure function read_next_output(file f : text) return OUTPUT is
		variable l : line;
		variable result : OUTPUT;
	begin
/*
	-- pc_out
		l := get_next_valid_line(f);
		result.pc_out := hex_to_slv(l.all, PC_WIDTH);

	-- exec_op.aluop
		l := get_next_valid_line(f);
		result.exec_op.aluop := str_to_alu_op(l.all);

	-- exec_op.alusrc1
		l := get_next_valid_line(f);
		result.exec_op.alusrc1 := str_to_sl(l(1));

	-- exec_op.alusrc2
		l := get_next_valid_line(f);
		result.exec_op.alusrc2 := str_to_sl(l(1));

	-- exec_op.alusrc3
		l := get_next_valid_line(f);
		result.exec_op.alusrc3 := str_to_sl(l(1));

	-- exec_op.rs1
		l := get_next_valid_line(f);
		result.exec_op.rs1 := bin_to_slv(l.all, REG_BITS);

	-- exec_op.rs2
		l := get_next_valid_line(f);
		result.exec_op.rs2 := bin_to_slv(l.all, REG_BITS);

	-- exec_op.readdata1
		l := get_next_valid_line(f);
		result.exec_op.readdata1 := hex_to_slv(l.all, DATA_WIDTH);

	-- exec_op.readdata2
		l := get_next_valid_line(f);
		result.exec_op.readdata2 := hex_to_slv(l.all, DATA_WIDTH);

	-- exec_op.imm
		l := get_next_valid_line(f);
		result.exec_op.imm := hex_to_slv(l.all, DATA_WIDTH);

	-- mem_op.branch
		l := get_next_valid_line(f);
		result.mem_op.branch := str_to_br(l.all);

	-- mem_op.mem.memread
		l := get_next_valid_line(f);
		result.mem_op.mem.memread := str_to_sl(l(1));

	-- mem_op.mem.memwrite
		l := get_next_valid_line(f);
		result.mem_op.mem.memwrite := str_to_sl(l(1));

	-- mem_op.mem.memtype
		l := get_next_valid_line(f);
		result.mem_op.mem.memtype := str_to_mem_op(l.all);

	-- wb_op.rd
		l := get_next_valid_line(f);
		result.wb_op.rd := bin_to_slv(l.all, REG_BITS);

	-- wb_op.write
		l := get_next_valid_line(f);
		result.wb_op.write := str_to_sl(l(1));

	-- wb_op.src
		l := get_next_valid_line(f);
		result.wb_op.src := str_to_wbs_op(l.all);

	-- exc_dec
		l := get_next_valid_line(f);
		result.exc_dec := str_to_sl(l(1));
*/
		return result;
	end function;

	procedure check_output(output_ref : OUTPUT) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);
 -- TODO
/*
		if passed then
			report " PASSED: "
			& " stall="	& to_string(inp.stall)
			& " flush="	& to_string(inp.flush)
			& " pc="	& slv_to_hex(inp.pc_in)
			& " instr="	& slv_to_hex(inp.instr)
			& " write="	& to_string(inp.reg_write.write)
			& " reg="	& to_string(inp.reg_write.reg)
			& " data="	& slv_to_hex(inp.reg_write.data) & lf
			severity note;
		else
			report "FAILED: "
			& " stall="	& to_string(inp.stall)
			& " flush="	& to_string(inp.flush)
			& " pc="	& slv_to_hex(inp.pc_in)
			& " instr="	& slv_to_hex(inp.instr)
			& " write="	& to_string(inp.reg_write.write)
			& " reg="	& to_string(inp.reg_write.reg)
			& " data="	& slv_to_hex(inp.reg_write.data) & lf
			-- pc-out
			& "** expected: pc_out=0x" & slv_to_hex(output_ref.pc_out) & lf
			& "** actual:   pc_out=0x" & slv_to_hex(outp.pc_out) & lf

			-- exec_op
			& "** expected: aluop=" & to_string(output_ref.exec_op.aluop)
			& " alusrc=" & to_string(output_ref.exec_op.alusrc1) & to_string(output_ref.exec_op.alusrc2) & to_string(output_ref.exec_op.alusrc3)
			& " rs1=0x" & slv_to_hex(output_ref.exec_op.rs1)
			& " rs2=0x" & slv_to_hex(output_ref.exec_op.rs2)
			& " readdata1=0x" & slv_to_hex(output_ref.exec_op.readdata1)
			& " readdata2=0x" & slv_to_hex(output_ref.exec_op.readdata2)
			& " imm=0x" & slv_to_hex(output_ref.exec_op.imm) & lf

			& "** actual:   aluop=" & to_string(outp.exec_op.aluop)
			& " alusrc=" & to_string(outp.exec_op.alusrc1) & to_string(outp.exec_op.alusrc2) & to_string(outp.exec_op.alusrc3)
			& " rs1=0x" & slv_to_hex(outp.exec_op.rs1)
			& " rs2=0x" & slv_to_hex(outp.exec_op.rs2)
			& " readdata1=0x" & slv_to_hex(outp.exec_op.readdata1)
			& " readdata2=0x" & slv_to_hex(outp.exec_op.readdata2)
			& " imm=0x" & slv_to_hex(outp.exec_op.imm) & lf

			-- mem_op
			& "** expected: branch=" & to_string(output_ref.mem_op.branch)
			& " memread=" & to_string(output_ref.mem_op.mem.memread)
			& " memwrite=" & to_string(output_ref.mem_op.mem.memwrite)
			& " memtype=" & to_string(output_ref.mem_op.mem.memtype) & lf

			& "** actual:   branch=" & to_string(outp.mem_op.branch)
			& " memread=" & to_string(outp.mem_op.mem.memread)
			& " memwrite=" & to_string(outp.mem_op.mem.memwrite)
			& " memtype=" & to_string(outp.mem_op.mem.memtype) & lf

			-- wb_op
			& "** expected: rd=" & to_string(output_ref.wb_op.rd)
			& " write=" & to_string(output_ref.wb_op.write)
			& " src=" & to_string(output_ref.wb_op.src) & lf

			& "** actual:   rd=" & to_string(outp.wb_op.rd)
			& " write=" & to_string(outp.wb_op.write)
			& " src=" & to_string(outp.wb_op.src) & lf

			-- exc_dec
			& "** expected: exc_dec=" & to_string(output_ref.exc_dec) & lf
			& "** actual:   exc_dec=" & to_string(outp.exc_dec) & lf
			severity error;
		end if;
*/
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
