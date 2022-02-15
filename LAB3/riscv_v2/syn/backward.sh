rm -r work
mkdir work

source /software/scripts/init_synopsys_64.18

vcd2saif -64 -input ../vcd/riscv.vcd -output ../saif/riscv.saif

design_vision -no_gui -f backward.scr



