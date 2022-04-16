class packet_in extends uvm_sequence_item;
    `ifdef FPMULT
    	rand bit [31:0] A;
    	rand bit [31:0] B;
	bit [31:0] lim_max_pos = 32'b01111111100000000000000000000000;
	bit [31:0] lim_min_pos = 32'b00000000100000000000000000000000;
	bit [31:0] lim_min_neg = 32'b10000000100000000000000000000000;
	bit [31:0] lim_max_neg = 32'b11111111100000000000000000000000;
	// Constraint to avoid NaN and denormal numbers at the input
	constraint bounds {(A inside {[lim_max_neg:lim_min_neg]}) || (A inside {[lim_min_pos:lim_max_pos]}); (B inside {[lim_max_neg:lim_min_neg]}) || (B inside {[lim_min_pos:lim_max_pos]}); }
    `elsif LONG 
	rand longint A;
	rand longint B;
    `else
	rand integer A;
	rand integer B;
    `endif
    
    `ifdef ADDER
	//constraint bounds {!(A inside {[lim_min_neg:lim_min_pos]});!( B inside {[lim_min_neg:lim_min_pos]}); }
	constraint bounds { A inside {[100:1000]}; B <= 10*A; B > 0; }
    `elsif DADDA
	constraint bounds { A >= 0; B >= 0; }
    `endif	
 
    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
	super.new(name);
    endfunction: new
endclass: packet_in
