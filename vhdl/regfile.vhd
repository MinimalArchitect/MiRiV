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

	signal read_address1	: reg_adr_type;
	signal read_address2	: reg_adr_type;
	signal write_address	: reg_adr_type;

	signal read_address1_next		: reg_adr_type;
	signal read_address2_next		: reg_adr_type;
	signal write_address_next		: reg_adr_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		regfile <= ((to_integer(unsigned(ZERO_REG))) => ZERO_DATA, others => INVALID_REG);

		read_address1 <= ZERO_REG;
		read_address2 <= ZERO_REG;
		write_address <= ZERO_REG;

	elsif rising_edge(clk) then
		regfile <= regfile_next;

		read_address1 <= read_address1_next;
		read_address2 <= read_address2_next;
		write_address <= write_address_next;
	end if;
end process;

latch_or_stall : process(all)
begin
	if stall = '0' then
		write_address_next <= wraddr;
		read_address1_next <= rdaddr1;
		read_address2_next <= rdaddr2;
	else 
		write_address_next <= write_address;
		read_address1_next <= read_address1;
		read_address2_next <= read_address2;
	end if;
end process;

write : process(all)
begin
	regfile_next <= regfile;
	-- regfile cannot change if stalled or not written, also don't change reg0
	if stall = '0' and regwrite = '1' and to_integer(unsigned(write_address_next)) /= 0 then
		regfile_next(to_integer(unsigned(write_address_next))) <= wrdata;
	end if;
end process;

read : process(all)
begin
	rddata1 <= regfile(to_integer(unsigned(read_address1_next)));
	rddata2 <= regfile(to_integer(unsigned(read_address2_next)));

	-- these equality operations work, because the vector have the same length
	-- if stalled, regfile could not change, so no forwarding
	-- if write address is to reg0 don't forward write data to read data, because reg0 is never changed
	if stall = '0' and regwrite = '1' and wraddr = read_address1_next and to_integer(unsigned(wraddr)) /= 0 then
		rddata1 <= wrdata;
	end if;

	if stall = '0' and regwrite = '1' and wraddr = read_address2_next and to_integer(unsigned(wraddr)) /= 0 then
		rddata2 <= wrdata;
	end if;
end process;

end architecture;
