library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controlador is
	port(
        clk, clr, call, door_free, lt, eq, gt : in bit;
		
        ld_floor, ld_call, engine, door: out bit 
	);
end entity controlador;
	

architecture behav of controlador is

	type type_state is (
        INIT_S,         
        IDLE_S,         
        COMP_S,         
        MOVING_UP_S,    
        MOVING_DOWN_S,  
        ARRIVE_S        
    );
	 
	 signal current_state, next_state : type_state;
	 
begin

	PROCESS(clk, clr)
    BEGIN
        IF clr = '1' THEN
            current_state <= INIT_S;
        ELSIF clk'EVENT AND clk = '1' THEN 
            current_state <= next_state;
        END IF;
    END PROCESS;
	 
	 PROCESS(current_state, call, door_free, lt, eq, gt)
    BEGIN
        
        next_state  <= current_state;
        door        <= '0';
        engine      <= '0';
        ld_call     <= '0'; 
        ld_floor    <= '0';

        CASE current_state IS

            WHEN INIT_S =>
                IF call = '1' THEN
                    next_state <= COMP_S;
                    ld_call <= '1'; 
                ELSE
                    next_state <= INIT_S;
                END IF;

            WHEN IDLE_S =>
                IF call = '1' THEN
                    next_state <= COMP_S;
                    ld_call <= '1';
                ELSE
                    next_state <= IDLE_S;
                END IF;

            WHEN COMP_S =>
                IF gt = '1' THEN
                    next_state <= MOVING_UP_S;
                ELSIF lt = '1' THEN
                    next_state <= MOVING_DOWN_S;
                ELSIF eq = '1' THEN
                    next_state <= ARRIVE_S;
                ELSE
                    next_state <= COMP_S;
                END IF;

            WHEN MOVING_UP_S =>
                engine      <= '1';        
                ld_floor    <= '1';   
                IF eq = '1' THEN
                    next_state <= ARRIVE_S;    
                ELSE
                    next_state <= MOVING_UP_S;
                END IF;
            WHEN MOVING_DOWN_S =>
                engine      <= '1';       
                ld_floor    <= '1';
                IF eq = '1' THEN
                    next_state <= ARRIVE_S;    
                ELSE
                    next_state <= MOVING_DOWN_S;
                END IF;

            WHEN ARRIVE_S =>
                engine <= '0'; 
                door   <= '1';  

                IF door_free = '1' THEN
                    next_state <= IDLE_S;
                ELSE
                    next_state <= ARRIVE_S;
                END IF;

          END CASE;
    END PROCESS;

end architecture behav;