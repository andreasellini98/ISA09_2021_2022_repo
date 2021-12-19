vlib work
vcom Half_Adder.vhd
vcom Full_Adder.vhd
vcom MBE.vhd
vcom ks_adder.vhd
vcom dadda.vhd
vlog +define+DADDA top.sv mult_test.sv
#vopt +acc top -o top_opt
vsim -c -do "run -all" top