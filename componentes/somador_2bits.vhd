library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------ somador
entity somador_2bits is
    port (
        a0, a1, b0, b1 : in bit;
        s0, s1, co : out bit
    );
end entity somador_2bits;

architecture behav of somador_2bits is
    signal c0: bit; -- c0 eh o vai um de (a0+b0)
begin
    s0 <= a0 xor b0;
    c0 <= a0 and b0;
    s1 <= a1 xor b1 xor c0;
    co <= (a1 and b1) or (a1 and c0) or (b1 and c0);
    
    
end architecture behav;