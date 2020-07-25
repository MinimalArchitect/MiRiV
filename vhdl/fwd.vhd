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
		-- if the register is read and it is the one in the execute stage then forward
		-- use the latest value possible (first check mem, then wb)
			-- if it is the x0 register, then don't forward the value

		if reg = reg_write_mem.reg and unsigned(reg) /= 0 then
			do_fwd <= '1';
			val <= reg_write_mem.data;
		elsif reg = reg_write_wb.reg and unsigned(reg) /= 0 then
			do_fwd <= '1';
			val <= reg_write_wb.data;
		else
			do_fwd <= '0';
			val <= (others => '0');
		end if;
	end process;

end architecture;
