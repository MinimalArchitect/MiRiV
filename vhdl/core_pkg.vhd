library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;

package core_pkg is


    -- width of an instruction word
    constant INSTR_WIDTH_BITS : integer := 5;
    constant INSTR_WIDTH      : integer := 2**INSTR_WIDTH_BITS;

    -- size of instruction memory
    constant PC_WIDTH         : integer := ADDR_WIDTH+2;

    -- regfile properties
    constant REG_BITS         : integer := 5;
    constant REG_COUNT        : integer := 2**REG_BITS;

    -- To make things easier, we make CPU data types identical to memory types.
    subtype data_type       is mem_data_type;

    -- types for the interfaces
    subtype pc_type         is std_logic_vector(PC_WIDTH-1 downto 0);
    subtype instr_type      is std_logic_vector(INSTR_WIDTH-1 downto 0);
    subtype reg_adr_type    is std_logic_vector(REG_BITS-1 downto 0);

    -- useful constants
    constant ZERO_REG         : reg_adr_type := (others => '0');
    constant ZERO_DATA        : data_type    := (others => '0');
    constant ZERO_PC          : pc_type      := (others => '0');
    constant NOP_INST         : instr_type   := X"0000000F";

    constant INVALID_REG      : data_type := (others => '0');

    pure function to_data_type(pc : pc_type) return data_type;
    pure function to_pc_type(data : data_type) return pc_type;

end core_pkg;

package body core_pkg is

    pure function to_data_type(pc : pc_type) return data_type is
    begin
        return std_logic_vector(resize(unsigned(pc), data_type'length));
    end function;

    pure function to_pc_type(data : data_type) return pc_type is
    begin
        return std_logic_vector(resize(unsigned(data), pc_type'length));
    end function;

end package body core_pkg;
