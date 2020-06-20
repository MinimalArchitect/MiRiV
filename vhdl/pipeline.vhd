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
   signal stall : std_logic;
   signal flush : std_logic;
   
   signal mem_busy_fetch : std_logic;
   signal pcsrc : std_logic;
   signal pc_in : pc_type;
   signal pc_out : pc_type;
   signal instr : instr_type;
   signal mem_out : mem_out_type;
   signal mem_in : mem_in_type;
   
   signal reg_write : reg_write_type;
   signal pc : pc_type;
   signal exec_op : exec_op_type;
   signal mem_op : mem_op_type;
   signal wb_op : wb_op_type;
   signal exc_dec : std_logic;
   
   signal pc_old : pc_type;
   signal pc_new : pc_type;
   signal aluresult : data_type;
   signal wrdata : data_type;
   signal zero : std_logic;
   signal memop_in : mem_op_type;
   signal memop_out : mem_op_type;
   signal reg_write_mem : reg_write_type;
   
   signal mem_busy_mem : std_logic;
   signal wbop : wb_op_type;
   signal pc_old_wb : pc_type;
   signal aluresult_wb : data_type;
   signal memresult : data_type;
   signal exc_load : std_logic;
   signal exc_store : std_logic;
begin
   sync : process(clk, reset)
   begin
      if reset = '0' then
         stall <= '0';
      elsif rising_edge(clk) then
         stall <= '0';
         
         if mem_busy_fetch = '1' or mem_busy_mem = '1' then
            stall <= '1';
         end if;
      end if;
   end process;
   
   flush <= '0';
   
   fetch_inst : entity work.fetch
   port map(
      clk => clk,
      reset => reset,
      stall => stall,
      flush => flush,
      mem_busy => mem_busy_fetch,
      pcsrc => pcsrc,
      pc_in => pc_in,
      pc_out => pc_out,
      instr => instr,
      mem_out => mem_d_out,
      mem_in => mem_d_in
   );
   
   decode_inst : entity work.decode
   port map(
      clk => clk,
      reset => reset,
      stall => stall,
      flush => flush,
      pc_in => pc_out,
      instr => instr,
      reg_write => reg_write,
      pc_out => pc,
      exec_op => exec_op,
      mem_op => mem_op,
      wb_op => wb_op,
      exc_dec => exc_dec
   );
   
   exec_inst : entity work.exec
   port map(
      clk => clk,
      reset => reset,
      stall => stall,
      flush => flush,
      op => exec_op,
      pc_in => pc,
      pc_old_out => pc_old,
      pc_new_out => pc_new,
      aluresult => aluresult,
      wrdata => wrdata,
      zero => zero,
      memop_in => memop_in,
      memop_out => memop_out,
      wbop_in => wbop_in,
      wbop_out => wbop_out,
      
      exec_op => open,
      reg_write_mem => reg_write_mem,
      reg_write_wr => open
   );
   
   mem_inst : entity work.mem
   port map(
      clk => clk,
      reset => reset,
      stall => stall,
      flush => flush,
      mem_busy => mem_busy_mem,
      mem_op => memop_out,
      wbop_in => wbop_out,
      pc_new_in => pc_new,
      pc_old_in => pc_old,
      aluresult_in => aluresult,
      wrdata => wrdata,
      zero => zero,
      reg_write => reg_write_mem,
      pc_new_out => pc_in,
      pcsrc => pcsrc,
      wbop_out => wbop,
      pc_old_out => pc_old_wb,
      aluresult_out => aluresult_wb,
      memresult => memresult,
      mem_out => mem_i_out,
      mem_in => mem_i_in,
      exc_load => exc_load,
      exc_store => exc_store
   );
   
   wb_inst : entity work.wb
   port map(
      clk => clk,
      reset => reset,
      stall => stall,
      flush => flush,
      op => wbop,
      aluresult => aluresult_wb,
      memresult => memresult,
      pc_old_in => pc_old_wb,
      reg_write => reg_write
   );
end architecture;
