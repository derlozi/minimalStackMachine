ghdl.exe -a ./stack.vhdl
ghdl.exe -a ./alu.vhdl
ghdl.exe -a ./msmTB.vhdl
ghdl.exe -e tb
ghdl.exe -r tb --wave=wave.ghw --stop-time=10us
echo done