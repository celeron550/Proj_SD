entity Elevador is
    port (
        clk, clr, call, door_free : in bit;
        call_floor : in BIT_VECTOR(1 downto 0);

        led_motor, led_door : out bit;
        display_floor : out BIT_VECTOR(1 downto 0)
    );
end entity Elevador;

architecture behav of Elevador is
    component controlador is 
        port(
        clk, clr, call, door_free, lt, eq, gt : in bit;
        ld_floor, ld_call, engine, door, ctrl_s1, ctrl_s0: out bit 
    );
    end component;

    component datapath is 
        port (
        clk, clr, ld_floor, ld_call : in  bit;
        ctrl_s1, ctrl_s0 : in bit; 
        call_floor_in : in  BIT_VECTOR(1 downto 0);

        lt, eq, gt : out bit;
        display_floor : out BIT_VECTOR(1 downto 0)
    );
    end component;

    signal w_ld_floor, w_ld_call, w_lt, w_eq, w_gt, w_ctrl_s1, w_ctrl_s0 : bit;
begin

    Control : controlador port map (
        clk => clk, clr => clr, call => call, door_free => door_free,
        lt => w_lt, eq => w_eq, gt => w_gt,
        ld_floor => w_ld_floor, ld_call => w_ld_call,
        ctrl_s1 => w_ctrl_s1, ctrl_s0 => w_ctrl_s0,
        engine => led_motor, door => led_door
    );

    Data : datapath port map (
        clk => clk, clr => clr,
        ld_floor => w_ld_floor, ld_call => w_ld_call,
        ctrl_s1 => w_ctrl_s1, ctrl_s0 => w_ctrl_s0,
        call_floor_in => call_floor,
        lt => w_lt, eq => w_eq, gt => w_gt,
        display_floor => display_floor
    );
end architecture behav;