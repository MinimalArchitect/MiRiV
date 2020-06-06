library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;

entity regfile is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        stall            : in  std_logic;
        rdaddr1, rdaddr2 : in  reg_adr_type;
        rddata1, rddata2 : out data_type;
        wraddr           : in  reg_adr_type;
        wrdata           : in  data_type;
        regwrite         : in  std_logic
    );
end entity;

architecture rtl of regfile is
begin
end architecture;
