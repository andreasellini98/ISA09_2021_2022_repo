/***********************************************************************
 * Test bench for the RISCV.
 * Program under test: y = min(abs(x))
 * Find the minimum among Ndata samples and write it in the first free
 * location.
 **********************************************************************/


module riscv_test
 #(parameter Ndata = 7, parameter Ninstr = 22) 
 (input logic  [31:0] address_dm, address_instr, 
  input logic  [31:0] data_to_mem,
  output  logic  [31:0] data_from_mem,
  output  logic  [31:0] instruction,
  input logic read_mem, write_mem,
  input logic clk);
  
  timeunit 1ns; timeprecision 1ns;

  int i = 0;
  int file, log; // Files
  int cpu_count = 0;
  
  reg [31:0] InstrMem [0:Ninstr-1]; // Intruction Memory
  reg [31:0] DataMem [0:1023];		// Data Memory

  initial
    begin
	  
	  $readmemh("../sim/instr.txt",InstrMem); // Write Intruction Memory
	  $readmemh("../sim/data.txt",DataMem);   // Write Data Memory
	  
	  file=$fopen("../sim/data.txt","r");	   // Open files
	  log=$fopen("../sim/log.txt","w");
	  
	  $fwrite(log,"Initializing memory...\n"); // LOG file
	  
	  $fwrite(log,"\n-----------------------------------");
	  $fwrite(log,"\nInstruction memory:");
	  for(i=0; i<Ninstr; i=i+1) begin
		$fwrite(log,"\n%x //0x%x", InstrMem[i], 'h00400000 + 4*i);
	  end
	  
	  $fwrite(log,"\n-----------------------------------");
	  $fwrite(log,"\nData memory:");
	  for(i=0; i<Ndata; i=i+1) begin
		$fwrite(log,"\n%x //0x%x - (%1d)", DataMem[i], 'h10010000 + 4*i, signed'(DataMem[i]));
	  end
		
      $fwrite(log,"\n-----------------------------------");
	  $fwrite(log, "\nStart...");
	
	  forever @(posedge clk) cpu_count ++;
	 
    end


	always_comb begin
		instruction = InstrMem[(int'(address_instr) - 'h00400000)/4];
		if (int'(write_mem) === 1) begin
			DataMem[(int'(address_dm) - 'h10010000)/4] = data_to_mem;
			check_results();
			$display("\nEnd...");
			$display("Please check 'log.txt'\n");
			$finish();
			end
		else if (int'(read_mem) === 1)
			data_from_mem = DataMem[(int'(address_dm) - 'h10010000)/4];
	  end


  task check_results;
    int expected, expected_loc, tmp;    		  // local variable
    logic [31:0] result;      // local variable
	logic [31:0] memloc;	  // local variable
		
	expected = int'((1<<30) - 1); // Max value
	expected_loc = 'h10010000;    // Initial data address
	
	result = data_to_mem;  // RISCV result (Data)
	memloc = address_dm;   // RISCV result (Memory location)
	
	for (i=0; i<Ndata; i=i+1) begin  
        $fscanf(file,"%x",tmp);
		if (tmp < 0)
			tmp = - tmp;
		if (tmp < expected)
			expected = tmp;
		expected_loc = expected_loc + 4;
    end
  
	$fwrite(log, "\nEvaluating: y = min(abs(x))");
	$fwrite(log,"\nAt %t:\nexpected = %1d (0x%x) written in 0x%x\nresult   = %1d (0x%x) written in 0x%x", $realtime, expected, expected, expected_loc, result, result, memloc);
	
    if (result === expected && memloc === expected_loc ) begin
		$fwrite(log, " - OK");
		$fwrite(log, "\nNumber of CPU clock cycles: %1d", cpu_count);
		end
	else begin
		$fwrite(log, "\n- ERROR: expected %d (%b)", expected, expected);
    end
	
	$fclose(file);
	$fclose(log);
  endtask

endmodule




