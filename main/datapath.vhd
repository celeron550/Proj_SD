library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataPath is
    port (
        call, clk, clr, ld_floor : in bit;
        call_floor : in BIT_VECTOR(1 downto 0);
        moving_up, moving_down, stacionary : out bit;
        display_floor : out BIT_VECTOR(1 downto 0)  
    );
    end;

architecture behav of DataPath is
    component reg2 is
        port (
            clk, ld, clr : in bit;
            d : in BIT_VECTOR(1 downto 0);
            q : out BIT_VECTOR (1 downto 0)
        );
    end component;
    
    component Mux4x1 is
        port (
            i3, i2, i1, i0, s1, s0: in bit;
            d : out bit
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
            s0, s1, co: out bit
        );
    end component;
    
    component somador_2bits is
        port (
            a0, a1, b0, b1 : in bit;
            s0, s1, co : out bit
        );
    end component;

    signal r_current, r_call_floor, r_next, r_sum, r_sub : BIT_VECTOR(1 downto 0);
    signal comp_lt, comp_eq, comp_gt : bit;

    -- carry out do somador e subtrator que nao utilizamos:
    signal co_sum, co_sub : bit;

begin
    -- registrador do current_floor
    reg_current : component reg2 port map (
        clk => clk, ld => ld_floor, clr => clr,
        d => r_next, q => r_current
    );
    -- registrador do call_floor
    reg_call_floor : component reg2 port map (
        clk => clk, ld => call, clr => clr,
        d => call_floor, q => r_call_floor
    ); 

    comp : component comparador_2bits port map (
        b1 => r_current(1), b0 => r_current(0),
        a1 => r_call_floor(1), a0 => r_call_floor(0),
        l_t => comp_lt, e_t => comp_eq, g_t => comp_gt
    );

    -- soma com 1
    somador_unitario : component somador_2bits port map (
        a0 => r_current(0), a1 => r_current(1),
        b0 => '1', b1 => '0',
        s0 => r_sum(0), s1 => r_sum(1), 
        co => co_sum
    );

    -- subtrai com 1
    subtrator_unitario : component subtrator_2bits port map (
        a0 => r_current(0), a1 => r_current(1),
        b0 => '1', b1 => '0',
        s0 => r_sub(0), s1 => r_sub(1),
        co => co_sub
    );

    -- 2 Mux 4x1 pois os valores são de 2 bits:
    -- bit 0
    mux_output_0 : component Mux4x1 port map (
        i3 => '0', i2 => r_sum(0), i1 => r_sub(0), i0 => r_current(0),
        s1 => comp_gt, s0 => comp_lt,
        d => r_next(0)  
    );
    -- bit 1
    mux_output_1 : component Mux4x1 port map (
        i3 => '0', i2 => r_sum(1), i1 => r_sub(1), i0 => r_current(1),
        s1 => comp_gt, s0 => comp_lt,
        d => r_next(1)
    );
    
    -- saídas para a FSM:
    -- passa para a saída o andar atual
    display_floor <= r_current;
    -- se call_floor > current_floor: moving up
    moving_up <= comp_gt;
    -- se call_floor == current_floor: stacionary
    stacionary <= comp_eq;
    -- se call_floor < current_floor: moving down
    moving_down <= comp_lt;

end architecture behav;