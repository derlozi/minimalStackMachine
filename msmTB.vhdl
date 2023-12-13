library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--inc causes a value to be loaded into the stack

entity tb is

end entity;

architecture behaviour of tb is
    signal clk : std_logic;
    signal n_data : std_logic_vector(15 downto 0) := (others => '0');
    signal n_inc, n_dec, n_res : std_logic := '0';
    signal sim_runtime : std_logic := '1';
    component stack is
        generic(
                  g_stackSize : integer := 16;
                  g_spSize : integer := 4
        );
        port (    i_inc, i_dec, i_res : in std_logic;
                  o_min, o_max : out std_logic;
                  o_tos, o_btos : out std_logic_vector(15 downto 0);--top of stack, below top of stack
                  i_data : in std_logic_vector(15 downto 0);
                  clk : in std_logic);
      end component;

begin

    s : stack   generic map (g_stackSize => 16, g_spSize =>4)
                port map (i_inc => n_inc, i_dec => n_dec, i_res => n_res, clk => clk, i_data => n_data);
    process
    begin
        if(sim_runtime = '1')then
            clk <= '0';
            wait for 50 ns;
            clk <= '1';
            wait for 50 ns;
        end if;
    end process;

    process
    begin
        wait for 10 us;
        sim_runtime <= '0';
    end process;

    n_res <= '1', '0' after 100 ns, '1' after 7 us;
    n_data <= "0000000011110000", "0000111100001111" after 400 ns;
    n_inc <= '0', '1' after 100 ns, '0' after 200 ns, '1' after 400 ns, '1' after 4 us;
    n_dec <= '0', '1' after 300 ns, '0' after 400 ns, '1' after 4 us;
end behaviour;