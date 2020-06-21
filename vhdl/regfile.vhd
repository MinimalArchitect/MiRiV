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

	signal read_address1		: reg_adr_type;
	signal read_address2		: reg_adr_type;
	signal write_address		: reg_adr_type;
	signal write_data		: data_type;
	signal register_write		: std_logic;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		regfile <= ((to_integer(unsigned(ZERO_REG))) => ZERO_DATA, others => INVALID_REG);

		read_address1 <= ZERO_REG;
		read_address2 <= ZERO_REG;
		write_address <= ZERO_REG;
		write_data <= INVALID_REG;
		register_write <= '0';
	elsif rising_edge(clk) then
		if stall = '1' then
			regfile <= regfile;
			read_address1 <= read_address1;
			read_address2 <= read_address2;
			write_address <= write_address;
			write_data <= write_data;
			register_write <= regwrite;
		else
			regfile <= regfile;
			if regwrite = '1' and to_integer(unsigned(wraddr)) /= 0 then
				regfile(to_integer(unsigned(wraddr))) <= wrdata;
			end if;

			read_address1 <= rdaddr1;
			read_address2 <= rdaddr2;
			write_address <= wraddr;
			write_data <= wrdata;
			register_write <= regwrite;
		end if;
	end if;
end process;

read : process(all)
begin
	rddata1 <= regfile(to_integer(unsigned(read_address1)));
	rddata2 <= regfile(to_integer(unsigned(read_address2)));

	-- these equality operations work, because the vector have the same length
	-- if write address is to reg0 don't forward write data to read data, because reg0 is never changed
	if register_write = '1'
	   and write_address = read_address1
	   and to_integer(unsigned(write_address)) /= 0 then
		rddata1 <= write_data;
	end if;

	if register_write = '1'
	   and write_address = read_address2
	   and to_integer(unsigned(write_address)) /= 0 then
		rddata2 <= write_data;
	end if;

end process;

end architecture;
