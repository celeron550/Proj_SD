library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is
    port (
        clk, clr, ld_floor, ld_call : in  bit;
        
        ctrl_s1, ctrl_s0 : in bit; -- sinais pro mux

        call_floor_in : in  BIT_VECTOR(1 downto 0);

        lt, eq, gt : out bit;

        display_floor : out BIT_VECTOR(1 downto 0)
    );
end entity datapath;

architecture rtl of datapath is
    component reg2 is
        port (
            clk : in bit;
            ld  : in bit;
            clr : in bit;
            d   : in BIT_VECTOR(1 downto 0);
            q   : out BIT_VECTOR(1 downto 0)
        );
    end component;

    component Mux4x1 is
        port (
            i3, i2, i1, i0 : in bit;
            s1, s0         : in bit;
            d              : out bit
        );
    end component;

    component comparador_2bits is
        port (
            b1, b0, a1, a0: in bit;
            l_t, e_t, g_t : out bit
        );
    end component;

    component subtrator_2bits is
        port (
            a0, a1, b0, b1 : in bit;
            s0, s1, co     : out bit
        );
    end component;

    component somador_2bits is
        port (
            a0, a1, b0, b1 : in bit;
            s0, s1, co     : out bit
        );
    end component;

    -- sinais intermediarios
    signal r_current     : BIT_VECTOR(1 downto 0);
    signal r_call_floor  : BIT_VECTOR(1 downto 0);
    signal r_next        : BIT_VECTOR(1 downto 0);
    signal r_sum         : BIT_VECTOR(1 downto 0);
    signal r_sub         : BIT_VECTOR(1 downto 0);

    
    signal comp_lt, comp_eq, comp_gt : bit;

    
    signal co_sum, co_sub : bit; -- carry dos somadores
	signal load_enable_seguro : bit;-- habilita ld do reg so se n tiver no andar chamado
begin
    
	 load_enable_seguro <= ld_floor and (not comp_eq);

    reg_current : reg2 --reg do andar atual
        port map(
            clk => clk,
            ld  => load_enable_seguro, 
            clr => clr,
            d   => r_next,
            q   => r_current
        );

    
    reg_call_floor : reg2 --reg do ultimo andar
        port map(
            clk => clk,
            ld  => ld_call,    
            clr => clr,
            d   => call_floor_in,
            q   => r_call_floor
        );

    
    comp : comparador_2bits
        port map(
            b1 => r_current(1),
            b0 => r_current(0),
            a1 => r_call_floor(1),
            a0 => r_call_floor(0),
            l_t => comp_lt,
            e_t => comp_eq,
            g_t => comp_gt
        );

    lt <= comp_lt;
    eq <= comp_eq;
    gt <= comp_gt;

    
    somador_unitario : somador_2bits
        port map(
            a0 => r_current(0),
            a1 => r_current(1),
            b0 => '1',
            b1 => '0',
            s0 => r_sum(0),
            s1 => r_sum(1),
            co => co_sum
        );

    
    subtrator_unitario : subtrator_2bits
        port map(
            a0 => r_current(0),
            a1 => r_current(1),
            b0 => '1',
            b1 => '0',
            s0 => r_sub(0),
            s1 => r_sub(1),
            co => co_sub
        );

    mux_output_0 : Mux4x1
        port map(
            i3 => r_current(0), --mantem por seguranca
            i2 => r_sum(0), -- incrementa
            i1 => r_sub(0), -- decrementa
            i0 => r_current(0), -- mantem
            s1 => ctrl_s1,
            s0 => ctrl_s0,
            d  => r_next(0)
        );

    mux_output_1 : Mux4x1 --mesma logica do de cima
        port map(
            i3 => r_current(1),
            i2 => r_sum(1),
            i1 => r_sub(1),
            i0 => r_current(1),
            s1 => ctrl_s1,
            s0 => ctrl_s0,
            d  => r_next(1)
        );

    display_floor <= r_current; --atualiza o display com andar atual

end architecture rtl;
