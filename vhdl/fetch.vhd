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
        instr      : out instr_type := NOP_INST;

        -- memory controller interface
        mem_out   : out mem_out_type;
        mem_in    : in  mem_in_type
    );
end fetch;

architecture rtl of fetch is
	signal pc	: pc_type;
	signal next_pc	: pc_type;
	signal new_pc	: pc_type;

	signal inner_flush	: std_logic;
	signal next_inner_flush	: std_logic;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		pc <= std_logic_vector(to_signed(-4, pc_type'length));
		inner_flush <= '0';
	elsif rising_edge(clk) then
		pc <= next_pc;
		inner_flush <= next_inner_flush;
	end if;
end process;

state_input : process(all)
begin
	if stall = '1' then
		next_pc <= pc;
		next_inner_flush <= inner_flush;
	elsif pcsrc = '1' then
		next_pc <= pc_in;
		next_inner_flush <= flush;
	else
		next_pc <= new_pc;
		next_inner_flush <= flush;
	end if;
end process;

pc_out <= pc;


new_process_counter : process(all)
begin
	if pcsrc = '1' and stall = '0' then
		new_pc <= pc_in;
	else
		new_pc <= std_logic_vector(unsigned(pc) + 4);
	end if;
end process;



mem_out.address <= new_pc(PC_WIDTH-1 downto 2);
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

	if inner_flush = '1' then
		instr <= NOP_INST;
	end if;
end process;

end architecture;
