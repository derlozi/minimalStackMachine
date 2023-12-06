ghdl.exe -a ./stack.vhdl
ghdl.exe -a ./msmTB.vhdl
ghdl.exe -e tb
ghdl.exe -r tb --wave=wave.ghw
echo done