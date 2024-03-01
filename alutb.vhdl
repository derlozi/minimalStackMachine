library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--testbench solely for checking calculations of alu
--there will be a separate one for testing interactions with stack / control logic

entity tb is

end entity;

architecture behaviour of tb is

    component alu is
        port (
          i_clk : in std_logic;
          o_eqzero, o_resReady, o_inc, o_dec1, o_dec2, o_res : out std_logic;
          i_tos, i_btos, i_dataIn : in std_logic_vector(15 downto 0); 
          i_inst : in std_logic_vector(3 downto 0);
          o_result : out std_logic_vector(15 downto 0)
        );
      end component ;

      signal n_clk : std_logic := '0';
      signal n_tos, n_btos, n_dataIn : std_logic_vector(15 downto 0) := (others =>'0') ;
      signal n_inst : std_logic_vector(3 downto 0) := (others=> '0');
begin

    a : alu port map(i_clk=>n_clk, i_btos=>n_btos, i_tos=>n_tos, i_dataIn=> n_dataIn, i_inst=>n_inst);
    clkgen : process
    begin
        n_clk <='0';
        wait for 50 ns;
        n_clk <= '1';
        wait for 50 ns;
    end process ; -- clkgen

    n_tos <= std_logic_vector(to_signed(22, 16));
    n_btos <= std_logic_vector(to_signed(20, 16));
    n_dataIn <= std_logic_vector(to_signed(42, 16));

    instgen : process
    begin
        wait for 200 ns;
        n_inst <= std_logic_vector(unsigned(n_inst) + 1);
    end process ; -- instgen

end behaviour ; -- behaviour