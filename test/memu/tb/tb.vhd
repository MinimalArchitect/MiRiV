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
            memu_op  : memu_op_type;
            A        : data_type;
            W        : data_type;
            D        : mem_in_type;
        end record;

    type OUTPUT is
        record
            R        : data_type;
            B        : std_logic;
            XL       : std_logic;
            XS       : std_logic;
            M        : mem_out_type;
        end record;

    signal inp  : INPUT := (
        MEMU_NOP,
        (others => '0'),
        (others => '0'),
        MEM_IN_NOP
    );
    signal outp : OUTPUT;

    impure function read_next_input(file f : text) return INPUT is
        variable l : line;
        variable result : INPUT;
    begin
        l := get_next_valid_line(f);
        result.memu_op.memread := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.memu_op.memwrite := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.memu_op.memtype := str_to_mem_op(l.all);

        l := get_next_valid_line(f);
        result.A := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.W := bin_to_slv(l.all, DATA_WIDTH);
                
        l := get_next_valid_line(f);
        result.D.busy := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.D.rddata := bin_to_slv(l.all, DATA_WIDTH);

        return result;
    end function;

    impure function read_next_output(file f : text) return OUTPUT is
        variable l : line;
        variable result : OUTPUT;
    begin
        l := get_next_valid_line(f);
        result.R := bin_to_slv(l.all, DATA_WIDTH);
        
        l := get_next_valid_line(f);
        result.B := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.XL := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.XS := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.M.address := bin_to_slv(l.all, ADDR_WIDTH);
        
        l := get_next_valid_line(f);
        result.M.rd := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.M.wr := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.M.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);
        
        l := get_next_valid_line(f);
        result.M.wrdata := bin_to_slv(l.all, DATA_WIDTH);

        return result;
    end function;

    procedure check_output(output_ref : OUTPUT) is
        variable passed : boolean;
    begin
        passed := (outp = output_ref);

        if passed then
            report " PASSED: "
            & "op=" & memtype_type'image(inp.memu_op.memtype)
            & " r/w=" & std_logic'image(inp.memu_op.memread) & "/" & std_logic'image(inp.memu_op.memwrite)
            & " A=" & slv_to_bin(inp.A)
            & " W=" & slv_to_bin(inp.W) & lf
            & " D.busy=" & std_logic'image(inp.D.busy) 
            & " D.rddata=" & slv_to_bin(inp.D.rddata) & lf
            severity note;
        else
            report "FAILED: "
            & "op=" & memtype_type'image(inp.memu_op.memtype)
            & " r/w=" & std_logic'image(inp.memu_op.memread) & "/" & std_logic'image(inp.memu_op.memwrite)
            & " A=" & slv_to_bin(inp.A)
            & " W=" & slv_to_bin(inp.W) & lf
            & " D.busy=" & std_logic'image(inp.D.busy) 
            & " D.rddata=" & slv_to_bin(inp.D.rddata) & lf
            & "**      expected:"
            & " R=" & slv_to_bin(output_ref.R) 
            & " B=" & std_logic'image(output_ref.B) 
            & " XL=" & std_logic'image(output_ref.XL) 
            & " XS=" & std_logic'image(output_ref.XS)
            & " M.address=" & slv_to_bin(output_ref.M.address)
            & " M.r/w=" & std_logic'image(output_ref.M.rd) & "/" & std_logic'image(output_ref.M.wr) 
            & " M.byteena=" & slv_to_bin(output_ref.M.byteena) 
            & " M.wrdata=" & slv_to_bin(output_ref.M.wrdata) & lf
            & "**        actual:"
            & " R=" & slv_to_bin(output_ref.R) 
            & " B=" & std_logic'image(outp.B) 
            & " XL=" & std_logic'image(outp.XL) 
            & " XS=" & std_logic'image(outp.XS)
            & " M.address=" & slv_to_bin(outp.M.address)
            & " M.r/w=" & std_logic'image(outp.M.rd) & "/" & std_logic'image(outp.M.wr) 
            & " M.byteena=" & slv_to_bin(outp.M.byteena) 
            & " M.wrdata=" & slv_to_bin(outp.M.wrdata) & lf
            severity error;
        end if;
    end procedure;

begin

    memu_inst : entity work.memu
        port map
        (
            op => inp.memu_op,
            A  => inp.A,
            W  => inp.W,
            R  => outp.R,
            B  => outp.B,
            XL => outp.XL,
            XS => outp.XS,
            D => inp.D,
            M => outp.M
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
