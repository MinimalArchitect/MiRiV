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

    subtype addr is std_logic_vector(REG_BITS-1 downto 0);
    subtype data is std_logic_vector(DATA_WIDTH-1 downto 0);

    type INPUT is
        record
            stall     : std_logic;
            rdaddr1   : addr;
            rdaddr2   : addr;
            wraddr    : addr;
            wrdata    : data;
            regwrite  : std_logic;
        end record;

    type OUTPUT is
        record
            rddata1 : data;
            rddata2 : data;
        end record;

    signal inp  : INPUT := (
        '0',
        (others => '0'),
        (others => '0'),
        (others => '0'),
        (others => '0'),
        '0'
    );
    signal outp : OUTPUT;

    impure function read_next_input(file f : text) return INPUT is
        variable l : line;
        variable result : INPUT;
    begin
        l := get_next_valid_line(f);
        result.stall := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.rdaddr1 := bin_to_slv(l.all, REG_BITS);

        l := get_next_valid_line(f);
        result.rdaddr2 := bin_to_slv(l.all, REG_BITS);

        l := get_next_valid_line(f);
        result.wraddr := bin_to_slv(l.all, REG_BITS);

        l := get_next_valid_line(f);
        result.wrdata := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.regwrite := str_to_sl(l(1));

        return result;
    end function;

    impure function read_next_output(file f : text) return OUTPUT is
        variable l : line;
        variable result : OUTPUT;
    begin
        l := get_next_valid_line(f);
        result.rddata1 := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.rddata2 := bin_to_slv(l.all, DATA_WIDTH);

        return result;
    end function;

    procedure check_output(output_ref : OUTPUT) is
        variable passed : boolean;
    begin
        passed := (outp = output_ref);

        if passed then
            report " PASSED: "
            & "stall=" & std_logic'image(inp.stall)
            & " rdaddr1=" & slv_to_bin(inp.rdaddr1)
            & " rdaddr2=" & slv_to_bin(inp.rdaddr2)
            & " wraddr=" & slv_to_bin(inp.wraddr)
            & " wrdata=" & slv_to_bin(inp.wrdata)
            & " regwrite=" & std_logic'image(inp.regwrite) & lf
            severity note;
        else
            report "FAILED: "
            & "stall=" & std_logic'image(inp.stall)
            & " rdaddr1=" & slv_to_bin(inp.rdaddr1)
            & " rdaddr2=" & slv_to_bin(inp.rdaddr2)
            & " wraddr=" & slv_to_bin(inp.wraddr)
            & " wrdata=" & slv_to_bin(inp.wrdata)
            & " regwrite=" & std_logic'image(inp.regwrite) & lf
            & "**      expected: rddata1=" & slv_to_bin(output_ref.rddata1) & " rddata2=" & slv_to_bin(output_ref.rddata2) & lf
            & "**        actual: rddata1=" & slv_to_bin(outp.rddata1) & " rddata2=" & slv_to_bin(outp.rddata2) & lf
            severity error;
        end if;
    end procedure;

begin

    regfile_inst : entity work.regfile
        port map
        (
            clk       => clk,
            reset     => res_n,
            stall     => inp.stall,
            rdaddr1   => inp.rdaddr1,
            rdaddr2   => inp.rdaddr2,
            rddata1   => outp.rddata1,
            rddata2   => outp.rddata2,
            wraddr    => inp.wraddr,
            wrdata    => inp.wrdata,
            regwrite  => inp.regwrite
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
