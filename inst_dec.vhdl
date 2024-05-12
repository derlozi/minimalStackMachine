library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity inst_dec is
    port(
            o_inst, i_data_ram, o_data_ram : out std_logic_vector(3 downto 0);
            o_data_alu, o_addr_ram : out std_logic_vector(15 downto 0);
            i_data_alu : in std_logic_vector(15 downto 0);
            i_resReady, i_eqzero, i_reset, i_clk : std_logic
    );
end inst_dec;

architecture rtl of inst_dec is
    signal r_ramCnt : unsigned (2 downto 0);
    signal r_pc : unsigned (15 downto 0);
    signal r_data_ram_i : std_logic_vector(15 downto 0);--Registers for word-wise ram reading and writing
    signal r_data_ram_o : std_logic_vector(15 downto 0);
    signal pcEn, ramCntEn, pcRes, ramCntRes : std_logic;
begin

end rtl ; -- rtl