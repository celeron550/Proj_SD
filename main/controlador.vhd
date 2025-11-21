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
        if clr = '1' then
            q2 <= '0'; q1 <= '0'; q0 <= '0';
        elsif rising_edge(clk) then
            q2 <= d2; q1 <= d1; q0 <= d0;
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
        ld_floor, ld_call, engine, door : out bit
    );
end comb_controlador;

architecture behav of comb_controlador is
    signal cs : std_logic_vector(2 downto 0);
begin
    cs <= current2 & current1 & current0;

    -- transicao de estado
    next2 <= ((cs = "010") and lt) or
             ((cs = "100") and not eq) or
             ((cs = "101") and not door_free);

    next1 <= ((cs = "000") and call) or
             ((cs = "001") and call) or
             ((cs = "010") and gt) or
             ((cs = "011") and not eq) or
             ((cs = "101") and not door_free);

    next0 <= ((cs = "000") and not call) or
             ((cs = "001") and not call) or
             ((cs = "010") and eq) or
             ((cs = "011") and eq) or
             ((cs = "100") and eq) or
             ((cs = "101") and door_free);

    -- saidas
    -- ld_call: ativo em INIT_S ou IDLE_S quando call = '1'
    ld_call <= ( (not cs(2) and not cs(1) and not cs(0)) and call ) or
           ( (not cs(2) and not cs(1) and cs(0)) and call );

    -- ld_floor: ativo em MOVING_UP_S ou MOVING_DOWN_S
    ld_floor <= (not cs(2) and cs(1) and cs(0)) or (cs(2) and not cs(1) and not cs(0));

    -- engine: ativo em MOVING_UP_S ou MOVING_DOWN_S
    engine <= (not cs(2) and cs(1) and cs(0)) or (cs(2) and not cs(1) and not cs(0));

    -- door: ativo em ARRIVE_S
    door <= (cs(2) and not cs(1) and cs(0));
end architecture behav;

library ieee;
use ieee.std_logic_1164.all;

entity controlador is
    port(
        clk, clr, call, door_free, lt, eq, gt : in bit;
        ld_floor, ld_call, engine, door: out bit 
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
            ld_floor, ld_call, engine, door : out bit
        );
    end component;
begin
    u_reg : reg3 port map(clk => clk, clr => clr, d2 => n2, d1 => n1, d0 => n0, q2 => s2, q1 => s1, q0 => s0);
    u_comb : comb_controlador port map(
        current2 => s2, current1 => s1, current0 => s0,
        call => call, door_free => door_free, lt => lt, eq => eq, gt => gt,
        next2 => n2, next1 => n1, next0 => n0,
        ld_floor => ld_floor, ld_call => ld_call, engine => engine, door => door
    );
end architecture behav;