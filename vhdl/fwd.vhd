library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity fwd is
    port (
        -- from Mem
        reg_write_mem : in reg_write_type;

        -- from WB
        reg_write_wb  : in reg_write_type;

        -- from/to EXEC
        reg    : in  reg_adr_type;
        val    : out data_type;
        do_fwd : out std_logic
    );
end fwd;

architecture rtl of fwd is
begin
end architecture;
