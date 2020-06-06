library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.op_pkg.all;
use work.core_pkg.all;

package tb_util_pkg is
    -- Generates a clock on the given `clk` signal. Does not return.
    procedure clk_generate(signal clk : inout std_logic; constant clk_period : time);

    -- Invokes a low-active reset for a timespan of `reset_time`.
    procedure reset(signal reset : inout std_logic; constant reset_time : time);

    -- Waits for `num_cycles` cycles of the given period.
    procedure timeout(num_cycles : integer; constant clk_period : time);

    -- Prints a msg
    procedure print(msg : string);

    -- Reads lines from a file until the line isn't empty and doesn't start with a '#'.
    impure function get_next_valid_line(file f : text) return line;

    -- Converts a character to std_logic.
    function str_to_sl(c : character) return std_logic;

    -- Converts a bin to std_logic_vector.
    function bin_to_slv(bin : string; width : integer) return std_logic_vector;

    -- Converts a hex to std_logic_vector.
    function hex_to_slv(hex : string; width : integer) return std_logic_vector;

    -- Converts a std_logic_vector to bin.
    function slv_to_bin(slv : in std_logic_vector) return string;

    -- Converts a std_logic_vector to hex.
    function slv_to_hex(slv : in std_logic_vector) return string;

    -- Converts a string to a alu_op_type.
    function str_to_alu_op(str : string) return alu_op_type;

    -- Converts a string to a memtype_type.
    function str_to_mem_op(str : string) return memtype_type;
    
    -- Converts a string to a wbsrc_type.
    function str_to_wbs_op(str : string) return wbsrc_type;

    -- Trims a string (removes leading and tailing spaces
    function trim(str : string) return string;

    -- Removes comments (starting with #) from a line
    function rm_comment(str : string) return string;
end package;

package body tb_util_pkg is
    procedure clk_generate(signal clk : inout std_logic; constant clk_period : time) is
    begin
        while true loop
            clk <= '1', '0' after clk_period / 2;
            wait for clk_period;
        end loop;
    end procedure;

    procedure reset(signal reset : inout std_logic; constant reset_time : time) is
    begin
        reset <= '0';
        wait for reset_time;
        reset <= '1';
    end procedure;

    procedure timeout(num_cycles : integer; constant clk_period : time) is
    begin
        wait for CLK_PERIOD*num_cycles;
    end procedure;

    procedure print(msg : string) is
    begin
        report msg;
    end procedure;

    function str_to_sl(c : character) return std_logic is
    begin
        case c is
            when '0' =>
                return '0';
            when '1' =>
                return '1';
            when 'L' =>
                return 'L';
            when 'H' =>
                return 'H';
            when 'X' =>
                return 'X';
            when 'Z' =>
                return 'Z';
            when 'W' =>
                return 'W';
            when '-' =>
                return '-';
            when 'U' =>
                return 'U';
            when others =>
                return 'U';
        end case;
    end function;

    function max(a,b : integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
    end function;

    function trim(str : string) return string is
        alias src : string(1 to str'length) is str;
        variable ltrim, rtrim : natural;
    begin
        ltrim := 0;
        for i in src'range loop
            if src(i) /= ' ' then -- not space
                ltrim := i;
                exit;
            end if;
        end loop;

        if ltrim = 0 then
            return "";
        end if;

        rtrim := src'right;
        for i in src'reverse_range loop
            if src(i) /= ' ' then -- not space
                rtrim := i;
                exit;
            end if;
        end loop;
        return src(ltrim to rtrim);
    end function;

    function rm_comment(str : string) return string is
    begin
        for i in str'range loop
            if str(i) = '#' then
                return trim(str(1 to i-1));
            end if;
        end loop;
        return str;
    end function;

    function bin_to_slv(bin : string; width : integer) return std_logic_vector is
        variable ret_value : std_logic_vector(width-1 downto 0) := (others=>'0');
        variable temp : std_logic;
        variable j : integer := 0;
    begin
        for i in bin'high downto bin'low loop
            next when bin(i) = ' ';
            temp := str_to_sl(bin(i));
            ret_value(j) := temp;
            j := j+1;
        end loop;
        return ret_value;
    end function;

    function hex_to_slv(hex : string; width : integer) return std_logic_vector is
        variable ret_value : std_logic_vector(width-1 downto 0) := (others=>'0');
        variable temp : std_logic_vector(3 downto 0);
    begin
        for i in 0 to hex'length-1 loop
            case hex(hex'high-i) is
                when '0' => temp := x"0";
                when '1' => temp := x"1";
                when '2' => temp := x"2";
                when '3' => temp := x"3";
                when '4' => temp := x"4";
                when '5' => temp := x"5";
                when '6' => temp := x"6";
                when '7' => temp := x"7";
                when '8' => temp := x"8";
                when '9' => temp := x"9";
                when 'a' | 'A' => temp := x"a";
                when 'b' | 'B' => temp := x"b";
                when 'c' | 'C' => temp := x"c";
                when 'd' | 'D' => temp := x"d";
                when 'e' | 'E' => temp := x"e";
                when 'f' | 'F' => temp := x"f";
                when others => report "Conversion Error: char: " & hex(hex'high-i) severity error;
            end case;
            ret_value((i+1)*4-1 downto i*4) := temp;
        end loop;
        return ret_value;
    end function;

    function slv_to_bin(slv : in std_logic_vector) return string is
        variable ret_value : string(slv'length downto 1);
        variable temp : character;
    begin
        for i in 0 to slv'length-1 loop
            temp := std_logic'image(slv(i))(2);
            ret_value(i + 1) := temp;
        end loop;

        return ret_value;
    end function;

    function slv_to_hex(slv : in std_logic_vector) return string is
        constant hex_digits : string(1 to 16) := "0123456789abcdef";
        constant num_hex_digits : integer := integer((slv'length+3)/4);
        variable ret_value : string(1 to num_hex_digits);
        variable zero_padded_slv : std_logic_vector((4*num_hex_digits)-1 downto 0) := (others=>'0');
        variable r : integer := 0;
    begin
        zero_padded_slv(slv'range) := slv;
        loop
            ret_value(num_hex_digits-r) :=  hex_digits(to_integer(unsigned( zero_padded_slv( (r+1)*4-1 downto 4*r) ))+1);
            r := r + 1;
            if num_hex_digits-r = 0 then
                exit;
            end if;
        end loop;
        return ret_value;
    end function;

    impure function get_next_valid_line(file f : text) return line is
        variable l : line;
    begin
        readline(f, l);

        while l'length = 0 or l(1) = '#' loop
            readline(f, l);
        end loop;

        return l;
    end function;

    function str_to_alu_op(str : string) return alu_op_type is
    begin
        if str = "ALU_NOP" then
            return ALU_NOP;
        elsif str = "ALU_SLT" then
            return ALU_SLT;
        elsif str = "ALU_SLTU" then
            return ALU_SLTU;
        elsif str = "ALU_SLL" then
            return ALU_SLL;
        elsif str = "ALU_SRL" then
            return ALU_SRL;
        elsif str = "ALU_SRA" then
            return ALU_SRA;
        elsif str = "ALU_ADD" then
            return ALU_ADD;
        elsif str = "ALU_SUB" then
            return ALU_SUB;
        elsif str = "ALU_AND" then
            return ALU_AND;
        elsif str = "ALU_OR" then
            return ALU_OR;
        elsif str = "ALU_XOR" then
            return ALU_XOR;
        else
            -- This shouldn't happen
            report "Unknown op-code '" & str & "' -- defaulting to ALU_NOP" severity warning;
            return ALU_NOP;
        end if;
    end function;

    function str_to_mem_op(str : string) return memtype_type is
    begin
        if str = "MEM_W" then
            return MEM_W;
        elsif str = "MEM_H" then
            return MEM_H;
        elsif str = "MEM_HU" then
            return MEM_HU;
        elsif str = "MEM_B" then
            return MEM_B;
        elsif str = "MEM_BU" then
            return MEM_BU;
        else
            -- This shouldn't happen
            report "Unknown op-code '" & str & "' -- defaulting to MEM_W" severity warning;
            return MEM_W;
        end if;
    end function;

    function str_to_wbs_op(str : string) return wbsrc_type is
    begin
        if str = "WBS_ALU" then
            return WBS_ALU;
        elsif str = "WBS_MEM" then
            return WBS_MEM;
        elsif str = "WBS_OPC" then
            return WBS_OPC;
        else
            -- This shouldn't happen
            report "Unknown op-code '" & str & "' -- defaulting to WBS_ALU" severity warning;
            return WBS_ALU;
        end if;
    end function;
end package body;

