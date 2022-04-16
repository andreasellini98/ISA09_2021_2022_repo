class packet_in extends uvm_sequence_item;
    rand bit [31:0] A;
    rand bit [31:0] B;
    bit [31:0] lim_max_pos = 32'b01111111011111111111111111111111;
    bit [31:0] lim_min_pos = 32'b00000000100000000000000000000000;
    bit [31:0] lim_min_neg = 32'b10000000100000000000000000000000;
    bit [31:0] lim_max_neg = 32'b11111111011111111111111111111111;

    //shortreal A;
    //shortreal B;
   
    constraint bounds {!(A inside {[lim_min_neg:lim_min_pos]});!( B inside {[lim_min_neg:lim_min_pos]}); }
 
    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
	super.new(name);
    endfunction: new
endclass: packet_in
