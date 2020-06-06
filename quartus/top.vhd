library ieee;
use ieee.std_logic_1164.all;
use work.mem_pkg.all;

entity top is
    port (
        clk_pin : in std_logic;
        res_n   : in std_logic;
        tx      : out std_logic;
        rx      : in std_logic
    );
end entity;


architecture impl of top is
    signal pll_clk  : std_logic;
    signal pll_lock : std_logic;

    signal cpu_reset_n : std_logic;

    signal mem_i_in,  mem_d_in  : std_logic_vector(mem_in_range_type);
    signal mem_i_out, mem_d_out : mem_out_type;

    component pll is
        port
        (
            inclk0   : in std_logic := '0';
            c0       : out std_logic;
            locked   : out std_logic 
        );
    end component;

    component core is
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
    end component;

    component dev is
        port (
            clk         : in std_logic;
            res_n       : in std_logic;

            cpu_reset_n : out std_logic;

            rx        : in std_logic;
            tx        : out std_logic;

            -- instruction interface
            mem_i_out : in  std_logic_vector(mem_out_range_type);
            mem_i_in  : out std_logic_vector(mem_in_range_type);

            -- data interface
            mem_d_out : in  std_logic_vector(mem_out_range_type);
            mem_d_in  : out std_logic_vector(mem_in_range_type)
        );
    end component;

begin

    pll_inst : pll 
    port map (
        inclk0  => clk_pin,
        c0      => pll_clk,
        locked  => pll_lock
    );

    core_inst : core
    port map (
        clk       => pll_clk,
        reset     => cpu_reset_n and pll_lock,

        mem_i_out => mem_i_out,
        mem_i_in  => to_mem_in_type(mem_i_in),

        mem_d_out => mem_d_out,
        mem_d_in  => to_mem_in_type(mem_d_in)
    );

    dev_inst : dev
    port map (
        clk => pll_clk,
        res_n => res_n,

        cpu_reset_n => cpu_reset_n,

        tx => tx,
        rx => rx,

        mem_i_out => to_std_logic_vector(mem_i_out),
        mem_i_in  => mem_i_in,

        mem_d_out => to_std_logic_vector(mem_d_out),
        mem_d_in  => mem_d_in
    );

end architecture;
