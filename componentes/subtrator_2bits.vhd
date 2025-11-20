entity subtrator_2bits is
    port (
        a0, a1, b0, b1 : in bit;
        s0, s1, co: out bit
    );
end entity subtrator_2bits;

architecture behav of subtrator_2bits is
    signal ci: bit; -- carry in do subtrator, que deve ser 1
    signal c0: bit; -- c0 eh o vai um de (a0-b0)
    signal nb0: bit; -- barrando a entrada b0
    signal nb1: bit; -- barrando a entrada b1
begin
    ci <= '1';
    nb0 <= not(b0);
    nb1 <= not(b1);

    s0 <= a0 xor nb0 xor ci;
    c0 <= (a0 and nb0) or (ci and (a0 xor nb0));
    s1 <= a1 xor nb1 xor c0;
    co <= (a1 and nb1) or (c0 and (a1 xor nb1));
end architecture behav;