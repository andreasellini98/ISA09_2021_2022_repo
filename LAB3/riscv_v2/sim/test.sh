rm -r work

source /software/scripts/init_msim6.2g 
vlib work

vcom ../src/ALU.vhd 
vcom ../src/aluctrl.vhd 
vcom ../src/branchcomp.vhd 
vcom ../src/bypass.vhd 
vcom ../src/controlunit.vhd 
vcom ../src/forwardingbranch.vhd 
vcom ../src/forwardingunit.vhd 
vcom ../src/hazardunit.vhd 
vcom ../src/immgen.vhd 
vcom ../src/REG32PC.vhd 
vcom ../src/RF.vhd 
vcom ../src/riscv.vhd 
vlog ../tb/top.sv ../tb/riscv_test.sv 
vopt +acc top -o top_opt 
vsim -c -do "run -all" top 
