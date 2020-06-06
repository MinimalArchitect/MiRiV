library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity exec is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- from DEC
        op            : in  exec_op_type;
        pc_in         : in  pc_type;

        -- to MEM
        pc_old_out    : out pc_type;
        pc_new_out    : out pc_type;
        aluresult     : out data_type;
        wrdata        : out data_type;
        zero          : out std_logic;

        memop_in      : in  mem_op_type;
        memop_out     : out mem_op_type;
        wbop_in       : in  wb_op_type;
        wbop_out      : out wb_op_type;

        -- FWD
        exec_op       : out exec_op_type;
        reg_write_mem : in  reg_write_type;
        reg_write_wr  : in  reg_write_type
    );
end exec;

architecture rtl of exec is
begin
end architecture;
