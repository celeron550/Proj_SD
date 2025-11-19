library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Mux4x1 is
port(i3, i2, i1, i0, s1, s0: in bit;
	d: out bit);
end Mux4x1;

architecture behav of Mux4x1 is
begin
	d <= (i0 and (not s1) and (not s0)) or -- as equacoes tao no drive
         (i1 and (not s1) and s0) or
         (i2 and s1 and (not s0)) or
         (i3 and s1 and s0);

	
end architecture behav;