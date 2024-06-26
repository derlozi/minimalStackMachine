library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
  port (
    i_clk : in std_logic;
    o_eqzero, o_resReady, o_inc, o_dec1, o_dec2, o_resSp : out std_logic;
    i_tos, i_btos, i_dataIn : in std_logic_vector(15 downto 0); 
    i_inst : in std_logic_vector(3 downto 0);
    o_result : out std_logic_vector(15 downto 0)
  );
end alu ;

architecture arch of alu is
    signal r_res : std_logic_vector(15 downto 0);
    type stateType is (base, mul, other);
    signal currState, nextState : stateType;
begin
    
    process(i_clk)--maybe add reset?
    begin
        if(rising_edge(i_clk)) then
            currState <= nextState;
        end if;
    end process;

    nextState <= mul when i_inst = "0111" else base;
    --these need to be changed when multiplication is implemented
    o_resReady <= '1' when currState = base else '1';
    o_dec1 <= '1' when currState = base and (i_inst = "0011" or i_inst = "0101" or i_inst = "0110" or i_inst = "1000" or i_inst = "1001" or i_inst = "1011"
                    or i_inst = "1100") else '0';
    o_dec2 <= '1' when currState = base and i_inst = "0100" else '0';
    o_inc <= '1' when currState = base and (i_inst = "0001" or i_inst = "0100" or i_inst = "0101" or i_inst = "0110" or i_inst = "1000" or i_inst = "1001" 
                    or i_inst = "1011" or i_inst = "1100") else '0';
    o_resSp <= '1' when currState = base and (i_inst = "0010") else '0';
    r_res <=i_dataIn when (i_inst = "0001" or i_inst = "0010") else
            i_tos when i_inst = "0011" else
            std_logic_vector(signed(i_tos) + signed(i_btos)) when i_inst = "0100" else
            NOT(i_tos) when i_inst = "0101" else
            std_logic_vector(signed(NOT(i_tos))+1) when i_inst = "0110" else
            i_tos and i_btos when i_inst = "1000" else
            i_tos or i_btos when i_inst = "1001" else
            std_logic_vector(shift_right(signed(i_tos),1)) when i_inst = "1011" else
            std_logic_vector(shift_left(signed(i_tos),1)) when i_inst = "1100" else (others=>'0');
            
            
    --kept here as an easy-ish lookup table for signals sorted by instruction
    --process(i_clk)--result calculator process
    --    if(rising_edge(i_clk))then
    --        o_dec1 <= '0';
    --        o_dec2 <= '0';
    --        o_inc <= '0';
    --        o_res <= '0';
    --        o_resReady <= '0';
    --        case i_inst is  
    --            when "0000" =>--nop
    --                r_res <= (others => '0');
    --            when "0001" =>--push
    --                r_res <= i_dataIn;
    --                o_inc <= '1';
    --                o_resReady <= '1';
    --            when "0010" =>--clear stack
    --                r_res <= (others => '0');
    --                o_res <= '1';
    --                o_resReady <= '1';
    --            when "0011" =>--pop tos
    --                r_res <= (others => '0');
    --                o_dec1 <= '1';
    --                o_resReady <= '1';
    --            when "0100" =>--add
    --                r_res <= std_logic_vector(signed(i_tos) + signed(i_btos));
    --                o_resReady <= '1';
    --                o_dec2 <= '1';
    --                o_inc <= '1';
    --            when "0101" =>--invert
    --                r_res <= NOT(i_tos);
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "0110" =>--2s complement
    --                r_res <= std_logic_vector(signed(NOT(i_tos))+1);
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "0111" =>--multiply
    --                    --!TODO
    --            when "1000" => --and
    --                r_res <= i_tos and i_btos;
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "1001" => --or
    --                r_res <= i_tos or i_btos;
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "1010" => --div
    --                --!TODO
    --            when "1011" => --right shift 
    --                r_res <= std_logic_vector(shift_right(signed(i_tos),1));
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "1100" => --left shift
    --                r_res <= std_logic_vector(shift_left(signed(i_tos),1));
    --                o_resReady <= '1';
    --                o_inc <= '1';
    --                o_dec1 <= '1';
    --            when "1101" => --jnz
    --            when "1110" => --push to RAM
    --            when "1111" => --load from RAM
    --            when others => 
    --                r_res <= (others =>'0');
    --        end case;
    --    end if;
    --end process;

    o_eqzero <= '1' when r_res = "0000000000000000" else '0';
    o_result <= r_res;
end architecture ;