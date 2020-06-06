library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
    port (
        -- to mem
        op   : in  memu_op_type;
        A    : in  data_type;
        W    : in  data_type;
        R    : out data_type := (others => '0');

        B    : out std_logic := '0';
        XL   : out std_logic := '0';
        XS   : out std_logic := '0';

        -- to memory controller
        D    : in  mem_in_type;
        M    : out mem_out_type := MEM_OUT_NOP
    );
end memu;

architecture rtl of memu is
begin
end architecture;
