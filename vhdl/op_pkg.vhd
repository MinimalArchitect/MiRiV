library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;

package op_pkg is

    type alu_op_type is (
        ALU_NOP,
        ALU_SLT,
        ALU_SLTU,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR
        );

    type exec_op_type is
    record
        aluop      : alu_op_type;
        alusrc1    : std_logic;
        alusrc2    : std_logic;
        alusrc3    : std_logic;
        rs1        : reg_adr_type;
        rs2        : reg_adr_type;
        readdata1  : data_type;
        readdata2  : data_type;
        imm        : data_type;
    end record;

    constant EXEC_NOP : exec_op_type := (
        ALU_NOP,         -- alu_op_type
        '0',             -- alusrc1
        '0',             -- alusrc2
        '0',             -- alusrc3
        (others => '0'), -- rs1
        (others => '0'), -- rs2
        (others => '0'), -- readdata1
        (others => '0'), -- readdata2
        (others => '0')  -- imm
    );

    type memtype_type is (
        MEM_B,
        MEM_BU,
        MEM_H,
        MEM_HU,
        MEM_W
    );

    type branch_type is (
        BR_NOP,  -- no branch
        BR_BR,   -- branch
        BR_CND,  -- branch conditional
        BR_CNDI  -- branch conditional (condition inverted)
    );

    type memu_op_type is
    record
        memread  : std_logic;
        memwrite : std_logic;
        memtype  : memtype_type;
    end record;

    type mem_op_type is
    record
        branch   : branch_type;
        mem      : memu_op_type;
    end record;

    constant MEMU_NOP : memu_op_type := (
        '0',    -- memread
        '0',    -- memwrite
        MEM_W   -- memtype
    );

    constant MEM_NOP : mem_op_type := (
        BR_NOP,  -- branch
        MEMU_NOP -- mem
    );

    type wbsrc_type is (
        WBS_ALU, -- ALU result
        WBS_MEM, -- MEM result
        WBS_OPC  -- old PC + 4
    );

    type wb_op_type is
    record
        rd       : reg_adr_type;
        write    : std_logic;
        src      : wbsrc_type;
    end record;

    constant WB_NOP : wb_op_type := (
        ZERO_REG,  -- rd
        '0',       -- memtoreg
        WBS_ALU    -- regwrite
    );

    type reg_write_type is
    record
        write    : std_logic;
        reg      : reg_adr_type;
        data     : data_type;
    end record;

end package;
