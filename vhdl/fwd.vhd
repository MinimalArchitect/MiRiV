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

check : process(reg, reg_write_mem, reg_write_wb)
begin
	val <= (others => '0');
	do_fwd <= '0';

	-- if the register is read and it is the one in the execute stage then forward
	-- use the latest value possible (first check mem, then wb)
	if (unsigned(reg) = 0) then
		-- if it is the x0 register, then don't forward the value
	elsif (reg_write_mem.write = '1') and (reg = reg_write_mem.reg) then
		val <= reg_write_mem.data;
		do_fwd <= '1';
	elsif (reg_write_wb.write = '1') and (reg = reg_write_wb.reg) then
		val <= reg_write_wb.data;
		do_fwd <= '1';
	end if;
end process;

end architecture;
