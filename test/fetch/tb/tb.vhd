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
            stall    : std_logic;
            flush    : std_logic;
            pcsrc    : std_logic;
            pc_in    : pc_type;
            mem_in   : mem_in_type;
        end record;

    type OUTPUT is
        record
            mem_busy : std_logic;
            pc_out   : pc_type := (others => '0');
            instr    : instr_type;
            mem_out  : mem_out_type;
        end record;

    signal inp  : INPUT := (
        '0',
        '0',
        '0',
        (others => '0'),
        (others => '0')
    );
    signal outp : OUTPUT;

    impure function read_next_input(file f : text) return INPUT is
        variable l : line;
        variable result : INPUT;
    begin
        l := get_next_valid_line(f);
        result.alu_op := str_to_alu_op(l.all);

        l := get_next_valid_line(f);
        result.data_a := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.data_b := bin_to_slv(l.all, DATA_WIDTH);

        return result;
    end function;

    impure function read_next_output(file f : text) return OUTPUT is
        variable l : line;
        variable result : OUTPUT;
    begin
        l := get_next_valid_line(f);
        result.data_res := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.z_flag := str_to_sl(l(1));

        return result;
    end function;

    procedure check_output(output_ref : OUTPUT) is
        variable passed : boolean;
    begin
        passed := (outp = output_ref);

        if passed then
            report " PASSED: "
            & "op=" & alu_op_type'image(inp.alu_op)
            & " A=" & slv_to_bin(inp.data_a)
            & " B=" & slv_to_bin(inp.data_b) & lf
            severity note;
        else
            report "FAILED: "
            & "op=" & alu_op_type'image(inp.alu_op)
            & " A=" & slv_to_bin(inp.data_a)
            & " B=" & slv_to_bin(inp.data_b) & lf
            & "**      expected: R=" & slv_to_bin(output_ref.data_res) & " Z=" & std_logic'image(output_ref.z_flag) & lf
            & "**        actual: R=" & slv_to_bin(outp.data_res) & " Z=" & std_logic'image(outp.z_flag) & lf
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
            mem_busy => outp.busy,
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
