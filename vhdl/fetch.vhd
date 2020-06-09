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
	signal pc			: pc_type;

	signal pc_next			: pc_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		pc <= std_logic_vector(to_signed(-4, pc_type'length));
	elsif rising_edge(clk) then
		if stall = '1' then
			pc <= pc;
		elsif pcsrc = '1' then
			pc <= pc_in;
		else
			pc <= pc_next;
		end if;
	end if;
end process;

pc_out <= pc;
pc_next <= std_logic_vector(unsigned(pc) + 4);

mem_out.address <= pc_next(PC_WIDTH-1 downto 2);
mem_out.rd <= '1';
mem_out.wr <= '0';
mem_out.byteena <= (others => '1');
mem_out.wrdata <= (others => '0');

mem_busy <= mem_in.busy;

memory_read : process(all)
begin
	instr(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= mem_in.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
	instr(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= mem_in.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
	instr(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= mem_in.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
	instr(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= mem_in.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);

	if flush = '1' then
		-- nop code
		instr <= NOP_INST;
	end if;
end process;

end architecture;
