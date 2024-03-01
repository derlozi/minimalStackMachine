library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alustacktb is
  
end alustacktb;

architecture behaviour of alustacktb is
    signal sim_runtime : std_logic := '1';
    --general signals "from outside"
    signal n_inst : std_logic_vector(3 downto 0) := (others => '0');
    signal n_clk: std_logic;
    signal n_dataIn : std_logic_vector(15 downto 0) := (others => '0');

    component stack is
        generic(
                  g_stackSize : integer := 16;
                  g_spSize : integer := 4
        );
        port (    i_inc, i_dec1, i_dec2, i_res : in std_logic;
                  o_min, o_max : out std_logic;
                  o_tos, o_btos : out std_logic_vector(15 downto 0);--top of stack, below top of stack
                  i_data : in std_logic_vector(15 downto 0);
                  clk : in std_logic);
    end component;

    component alu is
        port (
          i_clk : in std_logic;
          o_eqzero, o_resReady, o_inc, o_dec1, o_dec2, o_res : out std_logic;
          i_tos, i_btos, i_dataIn : in std_logic_vector(15 downto 0); 
          i_inst : in std_logic_vector(3 downto 0);
          o_result : out std_logic_vector(15 downto 0)
        );
    end component ;

    --coupling signals
    signal n_inc, n_dec1, n_dec2, n_res : std_logic;
    signal n_data, n_tos, n_btos : std_logic_vector(15 downto 0);
begin

    s : stack   generic map (g_stackSize => 16, g_spSize =>4)
                port map (o_tos => n_tos, o_btos=>n_btos, i_dec1 => n_dec1, i_dec2 => n_dec2, i_inc => n_inc, i_res => n_res, clk => n_clk, i_data => n_data);
    
    a : alu port map(o_result => n_data, o_dec1=>n_dec1, o_dec2=>n_dec2, o_inc=>n_inc, i_clk=>n_clk, i_btos=>n_btos, i_tos=>n_tos, i_dataIn=> n_dataIn, i_inst=>n_inst);
    
    process
    begin
        if(sim_runtime = '1')then
            n_clk <= '0';
            wait for 50 ns;
            n_clk <= '1';
            wait for 50 ns;
        end if;
    end process;

    process
    begin
        wait for 10 us;
        sim_runtime <= '0';
    end process;

    n_res <= '1', '0' after 100 ns;
    n_inst <= x"1", x"4" after 300 ns;
    n_dataIn <= x"0001";

end behaviour; 