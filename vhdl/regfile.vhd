library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;

entity regfile is
	port (
		clk			: in  std_logic;
		reset			: in  std_logic;
		stall			: in  std_logic;
		rdaddr1, rdaddr2	: in  reg_adr_type;
		rddata1, rddata2	: out data_type;
		wraddr			: in  reg_adr_type;
		wrdata			: in  data_type;
		regwrite		: in  std_logic
	);
end entity;

architecture rtl of regfile is
	type regfile_t is ARRAY(REG_COUNT-1 downto 0) of data_type;

	signal regfile			: regfile_t;
	signal regfile_next		: regfile_t;

	signal read_address1		: reg_adr_type;
	signal read_address2		: reg_adr_type;

	signal read_address1_next	: reg_adr_type;
	signal read_address2_next	: reg_adr_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		regfile <= ((to_integer(unsigned(ZERO_REG))) => ZERO_DATA, others => INVALID_REG);

		read_address1 <= ZERO_REG;
		read_address2 <= ZERO_REG;

	elsif rising_edge(clk) then
		regfile <= regfile_next;
		read_address1 <= read_address1_next;
		read_address2 <= read_address2_next;
	end if;
end process;

write : process(all)
begin
	regfile_next <= regfile;
	-- regfile cannot change if stalled or not written, also never change reg0
	if stall = '0' and regwrite = '1' and to_integer(unsigned(wraddr)) /= 0 then
		regfile_next(to_integer(unsigned(wraddr))) <= wrdata;
	end if;
end process;

read : process(all)
begin

	if stall = '1' then
		-- can be latched this way, because next state is unchanged and is just a buffer
		read_address1_next <= read_address1;
		read_address2_next <= read_address2;

		rddata1 <= regfile(to_integer(unsigned(read_address1)));
		rddata2 <= regfile(to_integer(unsigned(read_address2)));
	else
		read_address1_next <= rdaddr1;
		read_address2_next <= rdaddr2;

		rddata1 <= regfile(to_integer(unsigned(rdaddr1)));
		rddata2 <= regfile(to_integer(unsigned(rdaddr2)));
		-- these equality operations work, because the vector have the same length
		-- if write address is to reg0 don't forward write data to read data, because reg0 is never changed
		if regwrite = '1' and wraddr = rdaddr1 and to_integer(unsigned(wraddr)) /= 0 then
			rddata1 <= wrdata;
		end if;

		if regwrite = '1' and wraddr = rdaddr2 and to_integer(unsigned(wraddr)) /= 0 then
			rddata2 <= wrdata;
		end if;
	end if;
end process;

end architecture;
