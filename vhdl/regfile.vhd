library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;

entity regfile is
	port (
		clk			: in  std_logic;
		reset			: in  std_logic;
		stall			: in  std_logic;
		rdaddr1, rdaddr2	: in  reg_adr_type := ZERO_REG;
		rddata1, rddata2	: out data_type;
		wraddr			: in  reg_adr_type := ZERO_REG;
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

	signal next_regfile		: regfile_t;
	signal next_read_address1	: reg_adr_type;
	signal next_read_address2	: reg_adr_type;
	signal next_write_address	: reg_adr_type;
	signal next_write_data		: data_type;
	signal next_register_write	: std_logic;
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
		regfile <= next_regfile;

		read_address1 <= next_read_address1;
		read_address2 <= next_read_address2;
		write_address <= next_write_address;
		write_data <= next_write_data;
		register_write <= next_register_write;
	end if;
end process;


state_input : process(stall, regfile, read_address1, read_address2, write_address, write_data, regwrite, rdaddr1, rdaddr2, wraddr, wrdata)
begin
	if stall = '1' then
		next_regfile <= regfile;
		next_read_address1 <= read_address1;
		next_read_address2 <= read_address2;
		next_write_address <= write_address;
		next_write_data <= write_data;
		next_register_write <= regwrite;
	else
		next_regfile <= regfile;
		if regwrite = '1' and to_integer(unsigned(wraddr)) /= 0 then
			next_regfile(to_integer(unsigned(wraddr))) <= wrdata;
		end if;

		next_read_address1 <= rdaddr1;
		next_read_address2 <= rdaddr2;
		next_write_address <= wraddr;
		next_write_data <= wrdata;
		next_register_write <= regwrite;
	end if;
end process;

read : process(reset, regfile, read_address1, read_address2, register_write, write_address, write_data)
begin
	if reset = '1' then
		rddata1 <= regfile(to_integer(unsigned(read_address1)));
		rddata2 <= regfile(to_integer(unsigned(read_address2)));

		-- if write address equals that of reg0, do not forward data to read, because reg0 can never change
		-- if stalled we do not pass through values that won't be saved in a register
		if register_write = '1' and write_address = read_address1 and write_address /= ZERO_REG then
			rddata1 <= write_data;
		end if;

		if register_write = '1' and write_address = read_address2 and write_address /= ZERO_REG then
			rddata2 <= write_data;
		end if;
	else
		rddata1 <= ZERO_DATA;
		rddata2 <= ZERO_DATA;
	end if;

end process;

end architecture;
