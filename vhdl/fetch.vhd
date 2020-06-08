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
	signal pc		: pc_type;
	signal pc_next		: pc_type;
	signal instruction	: instr_type;
	signal instruction_next	: instr_type;
begin

update : process(reset, clk)
begin
	if reset = '0' then
		-- will  be incremented to 0 and will output start of the instruction memory
		pc <= std_logic_vector(to_signed(-4, pc_type'length));

		instruction <= NOP_INST;
	elsif rising_edge(clk) then
		-- stops from latching when stalled (better?, hope its sythezisable)
		if stall = '0' then
			pc <= pc_next;
			instruction <= instruction_next;
		else
			pc <= pc;
			instruction <= instruction;
		end if;
	end if;
end process;

memory_read : process(all)
begin
	mem_out.address <= pc_next(PC_WIDTH-1 downto 2);
	mem_out.rd <= '1';
	mem_out.wr <= '0';
	mem_out.byteena <= (others => '1');
	mem_out.wrdata <= (others => '0');

	instruction_next(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= mem_in.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
	instruction_next(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= mem_in.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
	instruction_next(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= mem_in.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
	instruction_next(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= mem_in.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);

	if flush = '1' then
		-- nop code
		instruction_next <= NOP_INST;
	end if;

end process;

program_counter : process(all)
begin
	if pcsrc = '1' then
		pc_next <= pc_in;
	else
		pc_next <= std_logic_vector(unsigned(pc) + 4);
	end if;
end process;

output : process(all)
begin
	mem_busy <= mem_in.busy;
	instr <= instruction_next;
	pc_out <= pc;
end process;

end architecture;
