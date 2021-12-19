/***********************************************************************
 * Top-level module for testing the Kogge Stone Adder.  Connects the
 * testbench to one of three versions of the adder, using conditional
 * compilation.
 **********************************************************************/

module top();
  timeunit 1ns; timeprecision 1ns;
  parameter NBIT = 64;

  initial $timeformat(-9,0, "ns", 3);

  // interconnecting nets
  logic [NBIT-1:0] a, b;
  logic [NBIT-1:0] sum;
  logic test_clk;

  // clock generators
  initial begin
    test_clk = 0;
    forever #5ns test_clk = ~test_clk;
  end

  adder_test #(NBIT) test (.a(a), .b(b), .sum(sum), .test_clk(test_clk));  // testbench instance

//  `define DADDA

  `ifdef KOGGESTONE
    // add the design instance
  ks_adder #(NBIT) dut (.a(a), .b(b), .sum(sum));  // design instance
  `else
    initial $display("\n\nERROR in %m: no adder module was instantiated!\n");
  `endif

endmodule
