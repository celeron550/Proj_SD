library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparador_2bits is
    port (
       b1, b0, a1, a0: in bit;
       l_t, e_t, g_t : out bit -- esse sao os que aparecem na saida(duh)
    );
end entity comparador_2bits;

architecture behav of comparador_2bits is
    signal lt0 , eq0  : bit;
begin
    -- comparacao do bit menos significativo
    lt0 <= (not a0) and b0;
    eq0 <= (a0 xnor b0);

    -- comparacao dos 2 bits 
    l_t <= (b1 and not a1) or ((a1 xnor b1) and lt0);
    e_t <= eq0 and (a1 xnor b1);
    g_t <= (a1 and not b1) or ((a1 xnor b1) and a0 and not b0);
end architecture behav;