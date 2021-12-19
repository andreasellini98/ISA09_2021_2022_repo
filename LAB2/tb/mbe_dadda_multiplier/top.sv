/***********************************************************************
 * Top-level module for testing the MBE-DaddaTree Multiplier.  Connects the
 * testbench to one of three versions of the adder, using conditional
 * compilation.
 **********************************************************************/

module top();
  timeunit 1ns; timeprecision 1ns;
  parameter NBIT = 32;

  initial $timeformat(-9,0, "ns", 3);

  // interconnecting nets
  logic [NBIT-1:0] a, b;
  logic [2*NBIT-1:0] prod;
  logic test_clk;

  // clock generators
  initial begin
    test_clk = 0;
    forever #5ns test_clk = ~test_clk;
  end

  mult_test #(NBIT) test (.a(a), .b(b), .prod(prod), .test_clk(test_clk));  // testbench instance

//  `define DADDA

  `ifdef DADDA
    // add the design instance
  dadda #(NBIT) dut (.a(a), .b(b), .prod(prod));  // design instance
  `else
    initial $display("\n\nERROR in %m: no adder module was instantiated!\n");
  `endif

endmodule
