library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fulltb is
  
end fulltb;

architecture sim of fulltb is

    signal sim_runtime : std_logic := '1';

    component stack is
        generic(
                  g_stackSize : integer := 16;
                  g_spSize : integer := 4
        );
        port (    i_inc, i_dec1, i_dec2, i_resSp : in std_logic;
                  o_min, o_max : out std_logic;
                  o_tos, o_btos : out std_logic_vector(15 downto 0);--top of stack, below top of stack
                  i_data : in std_logic_vector(15 downto 0);
                  clk : in std_logic);
    end component;

    component alu is
        port (
          i_clk : in std_logic;
          o_eqzero, o_resReady, o_inc, o_dec1, o_dec2, o_resSp : out std_logic;
          i_tos, i_btos, i_dataIn : in std_logic_vector(15 downto 0); 
          i_inst : in std_logic_vector(3 downto 0);
          o_result : out std_logic_vector(15 downto 0)
        );
    end component ;

    component inst_dec is
        port(
                o_inst,  o_data_ram : out std_logic_vector(3 downto 0);
                o_data_alu, o_addr_ram : out std_logic_vector(15 downto 0);
                o_ram_wr_en : out std_logic;
                i_data_ram : in std_logic_vector(3 downto 0);
                i_data_alu : in std_logic_vector(15 downto 0);
                i_resReady, i_eqzero, i_reset, i_clk : std_logic
        );
    end component;

    component single_ram is
        generic(
            DATA_BITWIDTH  : natural;
            ADDR_BITWIDTH  : natural
        );
        port(
            -- Port A
            clock_i       : in  std_logic;
            write_i       : in  std_logic;
            addr_i        : in  std_logic_vector(ADDR_BITWIDTH - 1 downto 0);
            data_i        : in  std_logic_vector(DATA_BITWIDTH - 1 downto 0);
            data_o        : out std_logic_vector(DATA_BITWIDTH - 1 downto 0)
        );
    end component;

    --coupling signals stack <=> alu
    signal n_inc, n_dec1, n_dec2, n_resSp : std_logic;
    signal n_tos, n_btos : std_logic_vector(15 downto 0);
    --coupling signals alu <=> instruction decoder
    signal n_inst : std_logic_vector(3 downto 0);
    signal n_resReady, n_eqzero : std_logic;
    signal n_data_alu_i, n_data_alu_o : std_logic_vector(15 downto 0);
    --coupling signals instruction decoder <=> RAM
    signal n_ram_wr_en : std_logic;
    signal n_addr_ram : std_logic_vector(15 downto 0);
    signal n_data_ram_i, n_data_ram_o : std_logic_vector(3 downto 0);

    signal n_clk, n_reset : std_logic;
begin

    i : inst_dec port map (o_inst => n_inst, o_data_ram => n_data_ram_i, o_data_alu => n_data_alu_i, o_addr_ram => n_addr_ram, o_ram_wr_en => n_ram_wr_en, i_data_alu => n_data_alu_o, i_data_ram => n_data_ram_o, i_resReady => n_resReady, i_eqzero => n_eqzero, i_reset => n_reset, i_clk => n_clk);
    

    s : stack   generic map (g_stackSize => 16, g_spSize =>4)
                port map (o_tos => n_tos, o_btos=>n_btos, i_dec1 => n_dec1, i_dec2 => n_dec2, i_inc => n_inc, i_resSp => n_resSp, clk => n_clk, i_data => n_data_alu_o);
    
    a : alu port map(o_result => n_data_alu_o, o_dec1=>n_dec1, o_dec2=>n_dec2, o_inc=>n_inc, i_clk=>n_clk, i_btos=>n_btos, i_tos=>n_tos, i_dataIn=> n_data_alu_i, i_inst=>n_inst, o_resSp=>n_resSp, o_eqzero =>n_eqzero);
      
    r : single_ram  generic map (DATA_BITWIDTH => 4, ADDR_BITWIDTH => 16)
                    port map(clock_i => n_clk, write_i => n_ram_wr_en, addr_i => n_addr_ram, data_i => n_data_ram_i, data_o => n_data_ram_o);
    

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

    n_reset <= '1', '0' after 100 ns;
        
end sim ; -- sim