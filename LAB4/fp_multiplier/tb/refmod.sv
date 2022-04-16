class refmod extends uvm_component;
    `uvm_component_utils(refmod)
    
    packet_in tr_in;
    packet_out tr_out;
    uvm_get_port #(packet_in) in;
    uvm_put_port #(packet_out) out;
    bit [31:0] result;
    
    function new(string name = "refmod", uvm_component parent);
        super.new(name, parent);
        in = new("in", this);
        out = new("out", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr_out = packet_out::type_id::create("tr_out", this);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            in.get(tr_in);

	    // Check if there is a denormal result
            result = $shortrealtobits($bitstoshortreal(tr_in.A) * $bitstoshortreal(tr_in.B));
            if ($bitstoshortreal(result) < $bitstoshortreal(32'b00000000100000000000000000000000) && $bitstoshortreal(result) > $bitstoshortreal(32'b10000000100000000000000000000000)) begin 
	    	if (int'(result) > 0) begin
			tr_out.data = 32'b00000000000000000000000000000000;
		end else begin
			tr_out.data = 32'b10000000000000000000000000000000;
		end
            end else begin
	    	tr_out.data = result;
	    end

	    $display("refmod: input A = %e, input B = %e, output OUT = %e", $bitstoshortreal(tr_in.A), $bitstoshortreal(tr_in.B),$bitstoshortreal(tr_out.data));
			$display("refmod: input A = %b, input B = %b, output OUT = %b",tr_in.A, tr_in.B, tr_out.data);
            out.put(tr_out);
        end
    endtask: run_phase
endclass: refmod
