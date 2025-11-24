library ieee;
use ieee.std_logic_1164.all;

entity reg3 is
    port(
        clk, clr : in bit;
        d2, d1, d0 : in bit;
        q2, q1, q0 : out bit
    );
end reg3;

architecture behav of reg3 is
begin
    process(clk, clr)
    begin
        if (clk'event and clk = '1') then
            if clr = '1' then
                q2 <= '0';
                q1 <= '0';
                q0 <= '0';
            else
                q2 <= d2;
                q1 <= d1;
                q0 <= d0;
            end if;
        end if;
    end process;
end architecture behav;

library ieee;
use ieee.std_logic_1164.all;

entity comb_controlador is
    port(
        current2, current1, current0 : in bit;
        call, door_free, lt, eq, gt : in bit;
        next2, next1, next0 : out bit;
        ld_floor, ld_call, engine, door, ctrl_s1, ctrl_s0 : out bit
    );
end comb_controlador;

architecture behav of comb_controlador is
    -- cs indica o estado atual (current_state)
    signal cs : BIT_VECTOR(2 downto 0);
    signal st_000, st_001, st_010, st_011, st_100, st_101 : bit;
begin
    cs(0) <= current0;
    cs(1) <= current1;
    cs(2) <= current2;
    
    -- estados mapeados:
    -- 000 -> Init
    -- 001 -> Idle
    -- 010 -> Comp (a decisao eh feita aqui)
    -- 011 -> Moving_up
    -- 100 -> Moving_down
    -- 101 -> Arrive_at_floor

    st_000 <= not cs(2) and not cs(1) and not cs(0);
    st_001 <= not cs(2) and not cs(1) and cs(0);
    st_010 <= not cs(2) and cs(1) and not cs(0);
    st_011 <= not cs(2) and cs(1) and cs(0);
    st_100 <= cs(2) and not cs(1) and not cs(0);
    st_101 <= cs(2) and not cs(1) and cs(0);

    -- transicao de estado
    next2 <= (st_010 and lt) or
            (st_100 and not eq) or
            (st_101 and not door_free) or
            (st_010 and eq) or
            (st_011 and eq) or
            (st_100 and eq);

    next1 <= (st_000 and call) or
            (st_001 and call) or
            (st_010 and gt) or
            (st_011 and not eq);

    next0 <= (st_000 and not call) or
            (st_001 and not call) or
            (st_101 and door_free) or
            (st_010 and gt) or
            (st_011 and not eq) or
            (st_010 and eq) or
            (st_011 and eq) or
            (st_100 and eq) or
            (st_101 and not door_free);

    -- saidas
    -- ld_call: ativo em Init ou Idle quando call = '1'
    ld_call <= (st_000 and call) or (st_001 and call);

    -- ld_floor: ativo em Moving_up ou Moving_down
    ld_floor <= (st_011 and not eq) or (st_100 and not eq);

    -- engine: ativo em Moving_up ou Moving_down
    engine <= (st_011 and not eq) or (st_100 and not eq);
    
    -- door: ativo em Arrive_at_floor
    door <= st_101;

    -- CHAVES DO MUX (vao ser enviadas pro datapath)
    -- ctrl_s1: ativo apenas quando o estado é Moving_up (011)
    ctrl_s1 <= st_011 and not eq;

    -- ctrl_s0: ativo apenas quando o estado é Moving_down (100)
    ctrl_s0 <= st_100 and not eq;

end architecture behav;

library ieee;
use ieee.std_logic_1164.all;

entity controlador is
    port(
        clk, clr, call, door_free, lt, eq, gt : in bit;
        ld_floor, ld_call, engine, door, ctrl_s1, ctrl_s0: out bit 
    );
end controlador;

architecture behav of controlador is
    signal n2, n1, n0 : bit; -- prox estado
    signal s2, s1, s0 : bit; -- estado atual

    component reg3 is
        port(
            clk, clr : in bit;
            d2, d1, d0 : in bit;
            q2, q1, q0 : out bit
        );
    end component;

    component comb_controlador is
        port(
            current2, current1, current0 : in bit;
            call, door_free, lt, eq, gt : in bit;
            next2, next1, next0 : out bit;
            ld_floor, ld_call, engine, door, ctrl_s1, ctrl_s0 : out bit
        );
    end component;
begin
    u_reg : reg3 port map(clk => clk, clr => clr, d2 => n2, d1 => n1, d0 => n0, q2 => s2, q1 => s1, q0 => s0);
    u_comb : comb_controlador port map(
        current2 => s2, current1 => s1, current0 => s0,
        call => call, door_free => door_free, lt => lt, eq => eq, gt => gt,
        next2 => n2, next1 => n1, next0 => n0,
        ld_floor => ld_floor, ld_call => ld_call, engine => engine, door => door,
        ctrl_s1 => ctrl_s1, ctrl_s0 => ctrl_s0
        );
end architecture behav;