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
			stall		: std_logic;
			flush		: std_logic;

			-- from DEC
			op		: exec_op_type;
			pc_in		: pc_type;

			memop_in	: mem_op_type;
			wbop_in		: wb_op_type;

			-- FWD
			reg_write_mem	: reg_write_type;
			reg_write_wr	: reg_write_type;
		end record;

	type OUTPUT is
		record
			-- to MEM
			pc_old_out	: pc_type;
			pc_new_out	: pc_type;
			aluresult	: data_type;
			wrdata		: data_type;
			zero		: std_logic;

			memop_out	: mem_op_type;
			wbop_out	: wb_op_type;

			-- FWD
			exec_op		: exec_op_type;
		end record;

	signal inp : INPUT := (
		'0',
		'0',

		EXEC_NOP,
		ZERO_PC,

		MEM_NOP,
		WB_NOP,

		('0', (others => '0'), (others => '0')),
		('0', (others => '0'), (others => '0'))
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

	-- op.aluop
		l := get_next_valid_line(f);
		result.op.aluop := str_to_alu_op(l.all);

	-- read op.alusrc1
		l := get_next_valid_line(f);
		result.op.alusrc1 := str_to_sl(l(1));

	-- read op.alusrc2
		l := get_next_valid_line(f);
		result.op.alusrc2 := str_to_sl(l(1));

	-- read op.alusrc3
		l := get_next_valid_line(f);
		result.op.alusrc3 := str_to_sl(l(1));

	-- read op.rs1
		l := get_next_valid_line(f);
		result.op.rs1 := bin_to_slv(l.all, REG_BITS);

	-- read op.rs2
		l := get_next_valid_line(f);
		result.op.rs2 := bin_to_slv(l.all, REG_BITS);

	-- read op.readdata1
		l := get_next_valid_line(f);
		result.op.readdata1 := hex_to_slv(l.all, DATA_WIDTH);

	-- read op.readdata2
		l := get_next_valid_line(f);
		result.op.readdata2 := hex_to_slv(l.all, DATA_WIDTH);

	-- read op.imm
		l := get_next_valid_line(f);
		result.op.imm := hex_to_slv(l.all, DATA_WIDTH);


	-- read pc_in
		l := get_next_valid_line(f);
		result.pc_in := hex_to_slv(l.all, PC_WIDTH);


	-- memop_in.branch
		l := get_next_valid_line(f);
		result.memop_in.branch := str_to_br(l.all);

	-- memop_in.mem.memread
		l := get_next_valid_line(f);
		result.memop_in.mem.memread := str_to_sl(l(1));

	-- memop_in.mem.memwrite
		l := get_next_valid_line(f);
		result.memop_in.mem.memwrite := str_to_sl(l(1));

	-- memop_in.mem.memtype
		l := get_next_valid_line(f);
		result.memop_in.mem.memtype := str_to_mem_op(l.all);


	-- wbop_in.rd
		l := get_next_valid_line(f);
		result.wbop_in.rd := bin_to_slv(l.all, REG_BITS);

	-- wbop_in.write
		l := get_next_valid_line(f);
		result.wbop_in.write := str_to_sl(l(1));

	-- wbop_in.src
		l := get_next_valid_line(f);
		result.wbop_in.src := str_to_wbs_op(l.all);


	-- read reg_write_mem.write
		l := get_next_valid_line(f);
		result.reg_write_mem.write := str_to_sl(l(1));

	-- read reg_write_mem.reg
		l := get_next_valid_line(f);
		result.reg_write_mem.reg := bin_to_slv(l.all, REG_BITS);

	-- read reg_write_mem.data
		l := get_next_valid_line(f);
		result.reg_write_mem.data := hex_to_slv(l.all, DATA_WIDTH);


	-- read reg_write_wr.write
		l := get_next_valid_line(f);
		result.reg_write_wr.write := str_to_sl(l(1));

	-- read reg_write_wr.reg
		l := get_next_valid_line(f);
		result.reg_write_wr.reg := bin_to_slv(l.all, REG_BITS);

	-- read reg_write_wr.data
		l := get_next_valid_line(f);
		result.reg_write_wr.data := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return OUTPUT is
		variable l : line;
		variable result : OUTPUT;
	begin
	-- read pc_old_out
		l := get_next_valid_line(f);
		result.pc_old_out := hex_to_slv(l.all, PC_WIDTH);

	-- read pc_new_out
		l := get_next_valid_line(f);
		result.pc_new_out := hex_to_slv(l.all, PC_WIDTH);


	-- read aluresult
		l := get_next_valid_line(f);
		result.aluresult := hex_to_slv(l.all, DATA_WIDTH);

	-- read wrdata
		l := get_next_valid_line(f);
		result.wrdata := hex_to_slv(l.all, DATA_WIDTH);

	-- read zero
		l := get_next_valid_line(f);
		result.zero := str_to_sl(l(1));


	-- memop_out.branch
		l := get_next_valid_line(f);
		result.memop_out.branch := str_to_br(l.all);

	-- memop_out.mem.memread
		l := get_next_valid_line(f);
		result.memop_out.mem.memread := str_to_sl(l(1));

	-- memop_out.mem.memwrite
		l := get_next_valid_line(f);
		result.memop_out.mem.memwrite := str_to_sl(l(1));

	-- memop_out.mem.memtype
		l := get_next_valid_line(f);
		result.memop_out.mem.memtype := str_to_mem_op(l.all);


	-- wbop_out.rd
		l := get_next_valid_line(f);
		result.wbop_out.rd := bin_to_slv(l.all, REG_BITS);

	-- wbop_out.write
		l := get_next_valid_line(f);
		result.wbop_out.write := str_to_sl(l(1));

	-- wbop_out.src
		l := get_next_valid_line(f);
		result.wbop_out.src := str_to_wbs_op(l.all);

	-- exec_op.aluop
		l := get_next_valid_line(f);
		result.exec_op.aluop := str_to_alu_op(l.all);

	-- read exec_op.alusrc1
		l := get_next_valid_line(f);
		result.exec_op.alusrc1 := str_to_sl(l(1));

	-- read exec_op.alusrc2
		l := get_next_valid_line(f);
		result.exec_op.alusrc2 := str_to_sl(l(1));

	-- read exec_op.alusrc3
		l := get_next_valid_line(f);
		result.exec_op.alusrc3 := str_to_sl(l(1));

	-- read exec_op.rs1
		l := get_next_valid_line(f);
		result.exec_op.rs1 := bin_to_slv(l.all, REG_BITS);

	-- read exec_op.rs2
		l := get_next_valid_line(f);
		result.exec_op.rs2 := bin_to_slv(l.all, REG_BITS);

	-- read exec_op.readdata1
		l := get_next_valid_line(f);
		result.exec_op.readdata1 := hex_to_slv(l.all, DATA_WIDTH);

	-- read exec_op.readdata2
		l := get_next_valid_line(f);
		result.exec_op.readdata2 := hex_to_slv(l.all, DATA_WIDTH);

	-- read exec_op.imm
		l := get_next_valid_line(f);
		result.exec_op.imm := hex_to_slv(l.all, DATA_WIDTH);

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

			& " aluop=" & to_string(inp.op.aluop)
			& " alusrc=" & to_string(inp.op.alusrc1) & to_string(inp.op.alusrc2) & to_string(inp.op.alusrc3)
			& " rs1=" & slv_to_hex(inp.op.rs1)
			& " rs2=" & slv_to_hex(inp.op.rs2)
			& " readdata1=" & slv_to_hex(inp.op.readdata1)
			& " readdata2=" & slv_to_hex(inp.op.readdata2)
			& " imm=" & slv_to_hex(inp.op.imm) & lf
			& "**                 pc_in=" & slv_to_hex(inp.pc_in) & lf
			& "**                 branch=" & to_string(inp.memop_in.branch)
			& " memread=" & to_string(inp.memop_in.mem.memread)
			& " memwrite=" & to_string(inp.memop_in.mem.memwrite)
			& " memtype=" & to_string(inp.memop_in.mem.memtype) & lf

			& "**                 rd=" & to_string(inp.wbop_in.rd)
			& " write=" & to_string(inp.wbop_in.write)
			& " src=" & to_string(inp.wbop_in.src) & lf

			& "**                 write=" & to_string(inp.reg_write_mem.write)
			& " reg=" & to_string(inp.reg_write_mem.reg)
			& " data=" & to_string(inp.reg_write_mem.data) & lf

			& "**                 write=" & to_string(inp.reg_write_wr.write)
			& " reg=" & to_string(inp.reg_write_wr.reg)
			& " data=" & to_string(inp.reg_write_wr.data) & lf
			severity note;
		else
			report "FAILED: "
			& " stall=" & to_string(inp.stall)
			& " flush=" & to_string(inp.flush)

			& " aluop=" & to_string(inp.op.aluop)
			& " alusrc=" & to_string(inp.op.alusrc3) & to_string(inp.op.alusrc2) & to_string(inp.op.alusrc1)
			& " rs1=" & slv_to_hex(inp.op.rs1)
			& " rs2=" & slv_to_hex(inp.op.rs2)
			& " readdata1=" & slv_to_hex(inp.op.readdata1)
			& " readdata2=" & slv_to_hex(inp.op.readdata2)
			& " imm=" & slv_to_hex(inp.op.imm) & lf
			& "**                 pc_in=" & slv_to_hex(inp.pc_in) & lf
			& "**                 branch=" & to_string(inp.memop_in.branch)
			& " memread=" & to_string(inp.memop_in.mem.memread)
			& " memwrite=" & to_string(inp.memop_in.mem.memwrite)
			& " memtype=" & to_string(inp.memop_in.mem.memtype) & lf

			& "**                 rd=" & to_string(inp.wbop_in.rd)
			& " write=" & to_string(inp.wbop_in.write)
			& " src=" & to_string(inp.wbop_in.src) & lf

			& "**                 write=" & to_string(inp.reg_write_mem.write)
			& " reg=" & to_string(inp.reg_write_mem.reg)
			& " data=" & to_string(inp.reg_write_mem.data) & lf

			& "**                 write=" & to_string(inp.reg_write_wr.write)
			& " reg=" & to_string(inp.reg_write_wr.reg)
			& " data=" & to_string(inp.reg_write_wr.data) & lf

			& "** expected: pc_old_out=" & slv_to_hex(output_ref.pc_old_out)
			& " pc_new_out=" & slv_to_hex(output_ref.pc_new_out) & lf

			& "** actual:   pc_old_out=" & slv_to_hex(outp.pc_old_out)
			& " pc_new_out=" & slv_to_hex(outp.pc_new_out) & lf

			& "** expected: aluresult=" & slv_to_hex(output_ref.aluresult)
			& " wrdata=" & slv_to_hex(output_ref.wrdata)
			& " zero=" & to_string(output_ref.zero) & lf

			& "** actual:   aluresult=" & slv_to_hex(outp.aluresult)
			& " wrdata=" & slv_to_hex(outp.wrdata)
			& " zero=" & to_string(outp.zero) & lf

			& "** expected: branch=" & to_string(output_ref.memop_out.branch)
			& " memread=" & to_string(output_ref.memop_out.mem.memread)
			& " memwrite=" & to_string(output_ref.memop_out.mem.memwrite)
			& " memtype=" & to_string(output_ref.memop_out.mem.memtype) & lf

			& "** actual:   branch=" & to_string(outp.memop_out.branch)
			& " memread=" & to_string(outp.memop_out.mem.memread)
			& " memwrite=" & to_string(outp.memop_out.mem.memwrite)
			& " memtype=" & to_string(outp.memop_out.mem.memtype) & lf

			& "** expected: rd=" & to_string(output_ref.wbop_out.rd)
			& " write=" & to_string(output_ref.wbop_out.write)
			& " src=" & to_string(output_ref.wbop_out.src) & lf

			& "** actual:   rd=" & to_string(outp.wbop_out.rd)
			& " write=" & to_string(outp.wbop_out.write)
			& " src=" & to_string(outp.wbop_out.src) & lf

			& "** expected: aluop=" & to_string(output_ref.exec_op.aluop)
			& " alusrc=" & to_string(output_ref.exec_op.alusrc3) & to_string(output_ref.exec_op.alusrc2) & to_string(output_ref.exec_op.alusrc1)
			& " rs1=" & to_string(output_ref.exec_op.rs1)
			& " rs2=" & to_string(output_ref.exec_op.rs2)
			& " data1=" & slv_to_hex(output_ref.exec_op.readdata1)
			& " data2=" & slv_to_hex(output_ref.exec_op.readdata2)
			& " imm=" & slv_to_hex(output_ref.exec_op.imm) & lf

			& "** actual:   aluop=" & to_string(outp.exec_op.aluop)
			& " alusrc=" & to_string(outp.exec_op.alusrc3) & to_string(outp.exec_op.alusrc2) & to_string(outp.exec_op.alusrc1)
			& " rs1=" & to_string(outp.exec_op.rs1)
			& " rs2=" & to_string(outp.exec_op.rs2)
			& " data1=" & slv_to_hex(outp.exec_op.readdata1)
			& " data2=" & slv_to_hex(outp.exec_op.readdata2)
			& " imm=" & slv_to_hex(outp.exec_op.imm) & lf

/*

			& "** expected: current pc=0x" & slv_to_hex(output_ref.pc_out) &
			  " instr=0x" & slv_to_hex(output_ref.instr) &
			  " mem_busy=" & to_string(output_ref.mem_busy) &
			  " fetch address=0x" & slv_to_bin(output_ref.mem_out.address) & lf

			& "** actual:   current pc=0x" & slv_to_hex(outp.pc_out) &
			  " instr=0x" & slv_to_hex(outp.instr) &
			  " mem_busy=" & to_string(outp.mem_busy) &
			  " fetch address=0x" & slv_to_bin(outp.mem_out.address) & lf
*/
			severity error;
		end if;

	end procedure;

begin

	exec_inst : entity work.exec
		port map
		(
			clk => clk,
			reset => res_n,
			stall => inp.stall,
			flush => inp.flush,
			op => inp.op,
			pc_in => inp.pc_in,
			pc_old_out => outp.pc_old_out,
			pc_new_out => outp.pc_new_out,
			aluresult => outp.aluresult,
			wrdata => outp.wrdata,
			zero => outp.zero,
			memop_in => inp.memop_in,
			memop_out => outp.memop_out,
			wbop_in => inp.wbop_in,
			wbop_out => outp.wbop_out,
			exec_op => outp.exec_op,
			reg_write_mem => inp.reg_write_mem,
			reg_write_wr => inp.reg_write_wr
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
