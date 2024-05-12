ghdl.exe -a ./stack.vhdl
ghdl.exe -a ./alu.vhdl
ghdl.exe -a ./alustacktb.vhdl
ghdl.exe -a ./ram_ea.vhdl
ghdl.exe -a ./inst_dec.vhdl
ghdl.exe -e alustacktb
ghdl.exe -r alustacktb --wave=wave.ghw --stop-time=10us
echo done