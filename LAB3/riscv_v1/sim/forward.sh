rm -r work

source /software/scripts/init_msim6.2g 
vlib work

vlog -reportprogress 300 -work ./work ../netlist/riscv_netlist.v
vlog ../tb/top_backann.sv ../tb/riscv_test.sv 

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /top/dut=../netlist/riscv.sdf -do "run -all" top
