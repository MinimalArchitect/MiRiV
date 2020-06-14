library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity wb is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from MEM
        op         : in  wb_op_type;
        aluresult  : in  data_type;
        memresult  : in  data_type;
        pc_old_in  : in  pc_type;

        -- to FWD and DEC
        reg_write  : out reg_write_type
    );
end wb;

architecture rtl of wb is
   signal reg_wr        : std_logic;
   signal reg_wr_next   : std_logic;
   signal reg_reg       : reg_adr_type;
   signal reg_reg_next  : reg_adr_type;
   signal reg_data      : data_type;
   signal reg_data_next : data_type;
   
begin
   sync : process (clk, reset)
   begin
      if reset = '0' then
         reg_wr <= '0';
         reg_reg <= ZERO_REG;
         reg_data <= ZERO_DATA;
      elsif rising_edge(clk) then
         reg_wr <= reg_wr_next;
         reg_reg <= reg_reg_next;
         reg_data <= reg_data_next;
      end if;
   end process;
   
   proc : process (stall, flush, aluresult, memresult, pc_old_in, op.src, op.write, op.rd, reg_wr, reg_reg, reg_data)
   begin
      if flush = '1' then
         reg_write_next <= '0';
         reg_reg_next <= ZERO_REG;
         reg_data_next <= ZERO_DATA;
      elsif stall = '1' then
         reg_wr_next <= reg_wr;
         reg_reg_next <= reg_reg;
         reg_data_next <= reg_data;
      else
         reg_wr <= op.write;
         reg_reg_next <= op.rd;
         reg_data_next <= reg_data;
         case op.src is 
            when WBS_ALU =>
               reg_data_next <= aluresult;
            when WBS_MEM =>
               reg_data_next <= memresult;
            when WBS_OPC =>
               reg_data_next <= to_data_type(pc_old_in);
            when others =>
         end case;
      end if;
   end process;
   
   output : process(reg_wr, reg_reg, reg_data)
   begin
      reg_write.write <= reg_wr;
      reg_write.reg <= reg_reg;
      reg_write.data <= reg_data;
   end process;
end architecture;
