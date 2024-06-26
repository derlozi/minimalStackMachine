library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stack is
  generic(
            g_stackSize : integer := 16;
            g_spSize : integer := 4
  );
  port (    i_inc, i_dec1, i_dec2, i_resSp : in std_logic;
            o_min, o_max : out std_logic;
            o_tos, o_btos : out std_logic_vector(15 downto 0);--top of stack, below top of stack
            i_data : in std_logic_vector(15 downto 0);
            clk : in std_logic);
end stack;

architecture behaviour of stack is
    type t_memory is array (g_stackSize - 1 downto 0) of std_logic_vector(15 downto 0);
    signal r_stack : t_memory;
    signal r_sp : unsigned(g_spSize - 1 downto 0);
begin 
    process(clk)
    begin
        if(rising_edge(clk))then
            if(i_resSp = '1')then
                r_sp <= (others=>'0');
                r_stack(0) <= i_data;--load first value immediately after reset
            elsif(i_dec1 = '1' and i_inc = '1')then--all input combinations handled separately as there are different minimal stack pointer values depending on input combination, e.g. dec2 doesnt make sense with sp = 1, except when inc=1
                r_stack(to_integer(r_sp)) <= i_data;--not sure if i should lock down all invalid combinations, or just leave them open to programmer resposibility, would surely be faster otherwise?
            elsif(i_dec2 = '1' and r_sp > 0 and i_inc = '1')then
                r_sp <= r_sp - 1;
                r_stack(to_integer(r_sp - 1)) <= i_data;
            elsif(i_dec1 = '1' and r_sp > 0)then
                r_sp <= r_sp - 1;
            elsif(i_dec2 = '1' and r_sp > 1)then
                r_sp <= r_sp - 2;
            elsif(i_inc = '1' and r_sp < 15)then
                r_sp <= r_sp + 1;
                r_stack(to_integer(r_sp + 1)) <= i_data;
            end if;
        end if;
    end process;

    o_tos <= r_stack(to_integer(r_sp));
    o_btos <= r_stack(to_integer(r_sp) - 1) when r_sp > 0 else (others=>'0');
    o_min <= '1' when r_sp = 0 else '0';
    o_max <= '1' when r_sp = (2**g_spSize) - 1 else '0';

end behaviour;