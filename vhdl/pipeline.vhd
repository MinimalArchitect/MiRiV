library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity pipeline is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;

        -- instruction interface
        mem_i_out    : out mem_out_type;
        mem_i_in     : in  mem_in_type;

        -- data interface
        mem_d_out    : out mem_out_type;
        mem_d_in     : in  mem_in_type
    );
end pipeline;

architecture impl of pipeline is
   signal sig_stall : std_logic;
   signal sig_flush : std_logic;
   
   signal sig_mem_busy_fetch : std_logic;
   signal sig_pcsrc : std_logic;
   signal sig_pc_in : pc_type;
   signal sig_pc_out : pc_type;
   signal sig_instr : instr_type;
   signal sig_mem_out : mem_out_type;
   signal sig_mem_in : mem_in_type;
   
   signal sig_reg_write : reg_write_type;
   signal sig_pc : pc_type;
   signal sig_exec_op : exec_op_type;
   signal sig_mem_op : mem_op_type;
   signal sig_wb_op : wb_op_type;
   signal sig_exc_dec : std_logic;
   
   signal sig_pc_old : pc_type;
   signal sig_pc_new : pc_type;
   signal sig_aluresult : data_type;
   signal sig_wrdata : data_type;
   signal sig_zero : std_logic;
   signal sig_memop_in : mem_op_type;
   signal sig_memop_out : mem_op_type;
   signal sig_reg_write_mem : reg_write_type;
   
   signal sig_mem_busy_mem : std_logic;
   signal sig_wbop : wb_op_type;
   signal sig_pc_old_wb : pc_type;
   signal sig_aluresult_wb : data_type;
   signal sig_memresult : data_type;
   signal sig_exc_load : std_logic;
   signal sig_exc_store : std_logic;
begin
   sync : process(clk, reset)
   begin
      if reset = '0' then
         sig_stall <= '0';
      elsif rising_edge(clk) then
         sig_stall <= '0';
         
         if sig_mem_busy_fetch = '1' or sig_mem_busy_mem = '1' then
            sig_stall <= '1';
         end if;
      end if;
   end process;
   
   sig_flush <= '0';
   
   fetch_inst : entity work.fetch
   port map(
      clk => clk,
      reset => reset,
      stall => sig_stall,
      flush => sig_flush,
      mem_busy => sig_mem_busy_fetch,
      pcsrc => sig_pcsrc,
      pc_in => sig_pc_in,
      pc_out => sig_pc_out,
      instr => sig_instr,
      mem_out => mem_d_out,
      mem_in => mem_d_in
   );
   
   decode_inst : entity work.decode
   port map(
      clk => clk,
      reset => reset,
      stall => sig_stall,
      flush => sig_flush,
      pc_in => sig_pc_out,
      instr => sig_instr,
      reg_write => sig_reg_write,
      pc_out => sig_pc,
      exec_op => sig_exec_op,
      mem_op => sig_mem_op,
      wb_op => sig_wb_op,
      exc_dec => sig_exc_dec
   );
   
   exec_inst : entity work.exec
   port map(
      clk => clk,
      reset => reset,
      stall => sig_stall,
      flush => sig_flush,
      op => sig_exec_op,
      pc_in => sig_pc,
      pc_old_out => sig_pc_old,
      pc_new_out => sig_pc_new,
      aluresult => sig_aluresult,
      wrdata => sig_wrdata,
      zero => sig_zero,
      memop_in => sig_memop_in,
      memop_out => sig_memop_out,
      wbop_in => sig_wbop_in,
      wbop_out => sig_wbop_out,
      
      exec_op => open,
      reg_write_mem => sig_reg_write_mem,
      reg_write_wr => open
   );
   
   mem_inst : entity work.mem
   port map(
      clk => clk,
      reset => reset,
      stall => sig_stall,
      flush => sig_flush,
      mem_busy => sig_mem_busy_mem,
      mem_op => sig_memop_out,
      wbop_in => sig_wbop_out,
      pc_new_in => sig_pc_new,
      pc_old_in => sig_pc_old,
      aluresult_in => sig_aluresult,
      wrdata => sig_wrdata,
      zero => sig_zero,
      reg_write => sig_reg_write_mem,
      pc_new_out => sig_pc_in,
      pcsrc => sig_pcsrc,
      wbop_out => sig_wbop,
      pc_old_out => sig_pc_old_wb,
      aluresult_out => sig_aluresult_wb,
      memresult => sig_memresult,
      mem_out => mem_i_out,
      mem_in => mem_i_in,
      exc_load => sig_exc_load,
      exc_store => sig_exc_store
   );
   
   wb_inst : entity work.wb
   port map(
      clk => clk,
      reset => reset,
      stall => sig_stall,
      flush => sig_flush,
      op => sig_wbop,
      aluresult => sig_aluresult_wb,
      memresult => sig_memresult,
      pc_old_in => sig_pc_old_wb,
      reg_write => sig_reg_write
   );
end architecture;
