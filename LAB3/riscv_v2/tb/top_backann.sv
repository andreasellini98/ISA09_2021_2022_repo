/***********************************************************************
 * Top-level module for testing the RISC-V Lite processor. Connects the
 * testbench to the device under test.
 **********************************************************************/

module top();
  timeunit 1ns; timeprecision 1ns;
  parameter NBIT = 32;
  parameter Ndata = 7;
  parameter Ninstr = 19;

  initial $timeformat(-9,0, "ns", 3);

  // interconnecting nets
  logic [NBIT-1:0] address_dm, address_instr;
  logic [NBIT-1:0] instruction;
  logic [NBIT-1:0] data_to_mem, data_from_mem;
  logic test_clk, test_rstn;
  logic read_mem, write_mem;

  // clock and reset generators
  initial begin
	// .vcd file generation
	$dumpfile("../vcd/riscv.vcd");
		$dumpvars(0,dut);
    test_clk = 0;
    test_rstn = 0;
    
    #15ns test_rstn = 1;
    forever #6.2ns test_clk = ~test_clk;
  end

  riscv_test #(Ndata, Ninstr) test (.clk(test_clk), .instruction(instruction),  .address_dm(address_dm), .address_instr(address_instr), .data_to_mem(data_to_mem), .data_from_mem(data_from_mem), .read_mem(read_mem), .write_mem(write_mem));  // testbench instance

  // add the design instance
  riscv dut (.clk(test_clk), .rstn(test_rstn), .instruction(instruction),  .address_dm(address_dm), .address_instr(address_instr), .data_to_mem(data_to_mem), .data_from_mem(data_from_mem), .read_mem(read_mem), .write_mem(write_mem));  // design instance

endmodule
