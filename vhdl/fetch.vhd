library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- to control
        mem_busy   : out std_logic;

        pcsrc      : in  std_logic;
        pc_in      : in  pc_type;
        pc_out     : out pc_type := (others => '0');
        instr      : out instr_type;

        -- memory controller interface
        mem_out   : out mem_out_type;
        mem_in    : in  mem_in_type
    );
end fetch;

architecture rtl of fetch is
begin
end architecture;
