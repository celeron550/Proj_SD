library ieee;

use ieee.std_logic_1164.all;

entity reg2 is
    port(   
        clk, ld, clr: IN bit;
        d : IN BIT_VECTOR(1 DOWNTO 0);
        q : OUT BIT_VECTOR(1 DOWNTO 0)
    );
end reg2;

architecture behav of reg2 is
begin
    process(clk)
begin
    if (clk'event and clk = '1') then
        if (clr = '1') then
            q <= "00";
        elsif (ld = '1') then
            q <= d;
        end if;
    end if;
end process;
end architecture behav;