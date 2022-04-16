class packet_out extends uvm_sequence_item;
    `ifdef FPMULT
	bit [31:0] data;
    `elsif DADDA
	longint data;
    `elsif LONG 
	longint data;
    `else
	integer data;
    `endif

    `uvm_object_utils_begin(packet_out)
        `uvm_field_int(data, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_out");
        super.new(name);
    endfunction: new
endclass: packet_out
