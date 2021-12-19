vlib work
vcom ks_adder.vhd
vlog +define+KOGGESTONE top.sv adder_test.sv
#vopt +acc top -o top_opt
vsim -c -do "run -all" top