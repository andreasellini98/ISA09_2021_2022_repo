interface dut_if(input clk, rst);
    
    `ifdef LONG 
	logic [63:0] A, B;
	logic [63:0] data;
    `elsif DADDA
	logic [31:0] A, B;
	logic [63:0] data;
    `else
	logic [31:0] A, B;
	logic [31:0] data;
    `endif

    logic valid, ready;
    
    modport port_in (input clk, rst, A, B, valid, output ready);
    modport port_out (input clk, rst, output valid, data, ready);
endinterface

