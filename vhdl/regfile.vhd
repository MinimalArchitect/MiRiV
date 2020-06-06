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

	signal regfile		: regfile_t;
	signal regfile_next	: regfile_t;

	signal rdaddr1_latch	: reg_adr_type;
	signal rdaddr2_latch	: reg_adr_type;
	signal wraddr_latch	: reg_adr_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		regfile <= (0 => (others => '0'), others => (others => 'X'));
	elsif rising_edge(clk) then
		regfile <= regfile_next;

		-- also latch read and write addresses, if not stalled
		if stall = '0' then
			rdaddr1_latch	<= rdaddr1;
			rdaddr2_latch	<= rdaddr2;
			wraddr_latch	<= wraddr;
		end if;
	end if;
end process;

write : process(all)
begin
	regfile_next <= regfile;
	-- regfile cannot change if stalled or not written, also don't change reg0
	if stall = '0' and regwrite = '1' and to_integer(unsigned(wraddr_latch)) /= 0 then
		regfile_next(to_integer(unsigned(wraddr_latch))) <= wrdata;
	end if;
end process;

read : process(all)
begin
	rddata1 <= regfile(to_integer(unsigned(rdaddr1_latch)));
	rddata2 <= regfile(to_integer(unsigned(rdaddr2_latch)));

	-- these equality operations work, because the vector have the same length
	-- if stalled, regfile could not change, so no forwarding
	-- if write address is to reg0 don't forward write data to read data, because reg0 is never changed
	if stall = '0' and regwrite = '1' and wraddr = rdaddr1_latch and to_integer(unsigned(wraddr_latch)) /= 0 then
		rddata1 <= wrdata;
	end if;

	if stall = '0' and regwrite = '1' and wraddr = rdaddr2_latch and to_integer(unsigned(wraddr_latch)) /= 0 then
		rddata2 <= wrdata;
	end if;
end process;

end architecture;
