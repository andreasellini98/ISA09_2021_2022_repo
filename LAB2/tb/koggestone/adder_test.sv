/***********************************************************************
 * Test bench for the Kogge-Stone Adder model.
 **********************************************************************/


module adder_test
 #(parameter N = 64) 
 (output logic  [N-1:0] a, b, 
  input  logic  [N-1:0] sum,
  input  logic test_clk);

  timeunit 1ns; timeprecision 1ns;

  int error_count = 0;  // number of errors detected

  initial                 // input stimulus
    begin
	  $display("\nInitializing inputs...");
      a = 0;
      b = 0;             
	  repeat (2) @(posedge test_clk) ;     // hold in reset for 2 clock cycles

	  $display("\nStart applying inputs...");
      repeat (5) begin
        @(posedge test_clk);
	      begin
		    @(negedge test_clk) check_results();  // call output verification task
		    randomize_inputs();
          end
      end

	  @(posedge test_clk);
	  $display("\nADDER TESTS COMPLETED WITH %0d ERRORS!\n", error_count);
	  $stop();
    end


  function void randomize_inputs();
    // Generate random inputs
    //a     = $urandom_range(2**N-1);       // between 0 and 2^N-1
    //b     = $urandom_range(2**N-1);       // between 0 and 2^N-1
	a 		= {$urandom_range(2**(N/2-1)),$urandom()};
	b 		= {$urandom_range(2**(N/2-1)),$urandom()};
  endfunction: randomize_inputs

  task check_results;
    logic [N-1:0] expected;    // local variable
    logic [N-1:0] result;      // local variable
       
    result = sum;
    expected = a + b;
    
    $write("At %t:  a=%d  b=%d : sum=%d (%b)", $realtime, a, b, sum, sum);
    if (result === expected)
      $display(" - OK");
    else begin
      $display(" - ERROR: expected %d (%b)", expected, expected);
      error_count++;
    end
  endtask

endmodule




