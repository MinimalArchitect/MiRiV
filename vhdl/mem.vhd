library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity mem is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- to Ctrl
        mem_busy      : out std_logic;

        -- from EXEC
        mem_op        : in  mem_op_type;
        wbop_in       : in  wb_op_type;
        pc_new_in     : in  pc_type;
        pc_old_in     : in  pc_type;
        aluresult_in  : in  data_type;
        wrdata        : in  data_type;
        zero          : in  std_logic;

        -- to EXEC (forwarding)
        reg_write     : out reg_write_type;

        -- to FETCH
        pc_new_out    : out pc_type;
        pcsrc         : out std_logic;

        -- to WB
        wbop_out      : out wb_op_type;
        pc_old_out    : out pc_type;
        aluresult_out : out data_type;
        memresult     : out data_type;

        -- memory controller interface
        mem_out       : out mem_out_type;
        mem_in        : in  mem_in_type;

        -- exceptions
        exc_load      : out std_logic;
        exc_store     : out std_logic
    );
end mem;

architecture rtl of mem is
   signal sig_mem_op       : mem_op_type;
   signal sig_mem_op_next  : mem_op_type;
   
   signal sig_wb_op        : wb_op_type;
   signal sig_wb_op_next   : wb_op_type;
   
   signal sig_pc_new       : pc_type;
   signal sig_pc_new_next  : pc_type;
   
   signal sig_pc_old       : pc_type;
   signal sig_pc_old_next  : pc_type;
   
   signal sig_mem_in       : mem_in_type;
   signal sig_mem_in_next  : mem_in_type;
   
   signal sig_aluresult    : data_type;
   signal sig_aluresult_next : data_type;
   
   signal sig_wrdata       : data_type;
   signal sig_wrdata_next  : data_type;
begin
   memu_inst : entity work.memu
   port map(
      op	=> sig_mem_op.mem,
		A	=> sig_aluresult,
		W	=> sig_wrdata,
		R	=> memresult,
		B	=> mem_busy,
		XL	=> exc_load,
		XS	=> exc_store,
		-- to memory controller
		D	=> sig_mem_in,
		M	=> mem_out
   );
   
   sync : process(clk, reset)
   begin
      if reset = '0' then
         sig_mem_op <= MEM_NOP;
         sig_wb_op <= WB_NOP;
         sig_pc_new <= ZERO_PC;
         sig_pc_old <= ZERO_PC;
         sig_mem_in <= MEM_IN_NOP;
         sig_aluresult <= ZERO_DATA;
         sig_wrdata <= ZERO_DATA;
      elsif rising_edge(clk) then
         sig_mem_op <= sig_mem_op_next;
         sig_wb_op <= sig_wb_op_next;
         sig_pc_new <= sig_pc_new_next;
         sig_pc_old <= sig_pc_old_next;
         sig_mem_in <= sig_mem_in_next;
         sig_aluresult <= sig_aluresult_next;
         sig_wrdata <= sig_wrdata_next;
      end if;
   end process;
   
   proc : process(stall, flush, sig_mem_op, sig_wb_op, sig_mem_in, sig_aluresult, sig_wrdata, mem_op, wbop_in, mem_in)
   begin
      if flush = '1' then
         sig_mem_op_next <= MEM_NOP;
         sig_wb_op_next <= WB_NOP;
         sig_pc_new_next <= ZERO_PC;
         sig_pc_old_next <= ZERO_PC;
         sig_mem_in_next <= MEM_IN_NOP;
         sig_aluresult_next <= ZERO_DATA;
         sig_wrdata_next <= ZERO_DATA;
      elsif stall = '1' then
         sig_mem_op_next <= sig_mem_op;
         sig_mem_op_next.mem.memread <= '0';
         sig_mem_op_next.mem.memwrite <= '0';
         sig_wb_op_next <= sig_wb_op;
         sig_pc_new_next <= sig_pc_new;
         sig_pc_old_next <= sig_pc_old;
         sig_mem_in_next <= sig_mem_in;
         sig_aluresult_next <= sig_aluresult;
         sig_wrdata_next <= sig_wrdata;
      else
         sig_mem_op_next <= mem_op;
         sig_wb_op_next <= wbop_in;
         sig_pc_new_next <= pc_new_in;
         sig_pc_old <= pc_old_in;
         sig_mem_in_next <= mem_in;
         sig_aluresult_next <= aluresult_in;
         sig_wrdata_next <= wrdata;
      end if;
   end process;
   
   output : process (sig_wb_op, sig_pc_new, sig_mem_op.branch, sig_pc_old, sig_aluresult, zero)
   begin
      wbop_out <= sig_wb_op;
      pc_new_out <= sig_pc_new;
      pcsrc <= '0';
      pc_old_out <= sig_pc_old;
      aluresult_out <= sig_aluresult;
      case sig_mem_op.branch is
         when BR_NOP =>
            pcsrc <= '0';
         when BR_BR =>
            pcsrc <= '1';
         when BR_CND =>
            pcsrc <= zero;
         when BR_CNDI =>
            pcsrc <= not zero;
         when others =>
      end case;
   end process;
   
   reg_write.write <= '0';
   reg_write.reg <= ZERO_REG;
   reg_write.data <= ZERO_DATA;
end architecture;
