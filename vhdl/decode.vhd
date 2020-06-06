library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity decode is
    port (
        clk, reset : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from fetch
        pc_in      : in  pc_type;
        instr      : in  instr_type;

        -- from writeback
        reg_write  : in reg_write_type;

        -- towards next stages
        pc_out     : out pc_type;
        exec_op    : out exec_op_type;
        mem_op     : out mem_op_type;
        wb_op      : out wb_op_type;

        -- exceptions
        exc_dec    : out std_logic
    );
end entity;

architecture rtl of decode is
begin
end architecture;
