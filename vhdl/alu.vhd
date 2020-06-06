library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

-- ATTENTION: zero flag is only valid on SUB and SLT(U)

entity alu is
    port (
        op   : in  alu_op_type;
        A, B : in  data_type;
        R    : out data_type := (others => '0');
        Z    : out std_logic := '0'
    );
end alu;

architecture rtl of alu is
begin
end architecture;
