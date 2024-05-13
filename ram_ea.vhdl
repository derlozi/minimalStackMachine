 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_ram is
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
end single_ram;
 
architecture rtl of single_ram is

-- Shared memory
type Tmem is array ((2**ADDR_BITWIDTH) - 1 downto 0) of std_logic_vector(DATA_BITWIDTH - 1 downto 0);
shared variable mem : Tmem;
	
begin
	process(clock_i)
	begin
		if rising_edge(clock_i) then
			if(write_i = '1') then
				mem(to_integer(unsigned(addr_i))) := data_i;
			end if;
			data_o <= mem(to_integer(unsigned(addr_i)));
		end if;
	end process;
end architecture rtl;