library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity inst_dec is
    port(
            o_inst,  o_data_ram : out std_logic_vector(3 downto 0);
            o_data_alu, o_addr_ram : out std_logic_vector(15 downto 0);
            o_ram_wr_en : out std_logic;
            i_data_ram : in std_logic_vector(3 downto 0);
            i_data_alu : in std_logic_vector(15 downto 0);
            i_resReady, i_eqzero, i_reset, i_clk : std_logic
    );
end inst_dec;

architecture rtl of inst_dec is
    signal r_ramCnt : integer;
    signal r_pc : unsigned (15 downto 0);
    signal r_data_ram_i, r_data_ram_o : std_logic_vector(15 downto 0);--Registers for word-wise ram reading and writing
    signal pc_en, ramCnt_en, pc_res, ramCnt_res, pc_load: std_logic;

    type stateType is (base, mulDiv, jZ, pushRAM, loadRAM);
    signal currState, nextState : stateType;
begin
    --not quite sure why i introduced this signal, but for now lets keep it constant
    pc_en <= '1';
    --reset signals
    pc_res <= i_reset;
    ramCnt_res <= i_reset;

    program_counter : process( i_clk )
    begin
        if(rising_edge(i_clk)) then
            if(pc_res = '1') then
                r_pc <= (others=>'0');
            else
                if(pc_load = '1')then
                    r_pc <= unsigned(r_data_ram_i);
                elsif(pc_en = '1') then
                    r_pc <= r_pc + 1;
                end if;
                
            end if;
        end if;
    end process; -- program_counter

    ramCnt : process( i_clk)
    begin
        if(rising_edge(i_clk))then
            if(ramCnt_res = '1') then
                r_ramCnt <= 0;
            else
                if(ramCnt_en = '1') then
                    --assert r_ramCnt > 0;
                    r_ramCnt <= r_ramCnt + 1;
                    if(r_ramCnt = 4)then
                        r_ramCnt <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process ; -- ramCnt
    
    --fsm combinatorics
    pc_load <= '1' when currState = jz and r_ramCnt = 4 else '0';
    nextState <=    jz when (currState = base and i_data_ram = x"D" and i_eqzero = '1') else
                    jz when currState = jz and r_ramCnt /= 4 else
                    mulDiv when currState = base and (i_data_ram = x"7" or i_data_ram = x"A") else
                    mulDiv when currState = mulDiv and i_resReady = '0' else
                    base when currState = mulDiv and i_resReady = '1' else
                    pushRam when currState = base and i_data_ram = x"E" else
                    pushRam when currState = pushRam and r_ramCnt /=4 else
                    base when currState = pushRam and r_ramCnt = 4 else
                    loadRam when currState = base and i_data_ram = x"F" else
                    loadRam when currState = loadRam and r_ramCnt /=4 else
                    base when currState = loadRam and r_ramCnt = 4 else
                    base;
    o_inst <=       x"0" when currState = mulDiv else --this lets a lot of instructions to the alu that are not needed there
                    x"0" when currState = pushRam else--Maybe be more restrictive if necessary
                    x"0" when currState = loadRam and r_ramCnt /=4 else
                    x"1" when currState = loadRam and r_ramCnt = 4 else
                    i_data_ram;
    o_addr_ram <=   r_data_ram_i when (r_ramCnt = 4 and currState = pushRam) else std_logic_vector(r_pc); 
    o_ram_wr_en <=  '1' when currState = pushRam and r_ramCnt = 4 else '0';
    o_data_ram <=   r_data_ram_o(4*(r_ramCnt+1)-1 downto 4*r_ramCnt) when r_ramCnt < 4 and r_ramCnt >= 0 else (others=>'0');
    o_data_alu <=   r_data_ram_i;
    ramCnt_en <=    '1' when (currState = pushRam or currState = loadRam or currState = jz) else '0';

    --wordwise loading
    ram_load : process( i_clk )
    begin
        if(rising_edge(i_clk))then
            if((currState = loadRam or currState = jz) and r_ramCnt /= 4)then
                r_data_ram_i(4*(r_ramCnt+1)-1 downto 4*r_ramCnt) <= i_data_ram;
            end if;
        end if;
    end process ; -- ram_load

    --registering alu data
    ram_push : process( i_clk )
    begin
        if(rising_edge(i_clk))then
            if(currState = pushRam and r_ramCnt = 0)then
                r_data_ram_o <= i_data_alu;
            end if;
        end if;
    end process ; -- ram_push

    fsm_transitions : process( i_clk )
    begin
        if(rising_edge(i_clk))then
            if(i_reset = '1')then
                currState <= base;
            else
                currState <= nextState;
            end if;
        
        end if;    
    end process ; -- fsm_transitions
end rtl ; -- rtl