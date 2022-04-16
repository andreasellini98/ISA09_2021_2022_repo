module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,DELAY,SEND} state);
    
    // 32-bit floating point multiplier test (latency 6 clock cycles)
    `ifdef FPMULT
	FPmul fp_multiplier_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.FP_Z(out_inter.data),.clk(in_inter.clk));
	`ifdef LATENCY
		int lat = `LATENCY;	
	`else
		int lat = 6; // Default value
	`endif
	logic [31:0] A_delayed;
	logic [31:0] B_delayed;
	bit save = 1;
    `endif
	
    // Dadda 64-bit multiplier
    `ifdef DADDA
	dadda mult_comb_under_test(.A(in_inter.A),.B(in_inter.B),.prod(out_inter.data));
    `endif
    
    // Simple adder
    `ifdef ADDER
	adder adder_under_test(.A(in_inter.A),.B(in_inter.B),.OUT(out_inter.data));
    `endif

    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            //out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    `ifdef FPMULT
                        state <= DELAY;
                    `else
                        state <= WAIT;
                    `endif
                end
                
                `ifdef FPMULT
                    DELAY: begin
                            lat = lat - 1;
			    in_inter.ready <= 0;
			    
			    if (save) begin
				A_delayed <= in_inter.A;
				B_delayed <= in_inter.B;
			        save = 0;
			    end
			    
                            if(lat > 0) begin
                                state <= DELAY;
			    end else begin
				`ifdef LATENCY
					lat = `LATENCY;
				`else
					lat = 6;
				`endif
                                state <= WAIT;
                            end
                    end
                `endif
                
                
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
                        `ifdef FPMULT
				$display("FP_Mult: input A = %e, input B = %e, output OUT = %e", $bitstoshortreal(A_delayed),$bitstoshortreal(B_delayed),$bitstoshortreal(out_inter.data));
                        	$display("FP_Mult: input A = %b, input B = %b, output OUT = %b",A_delayed,B_delayed,out_inter.data);
                        `elsif DADDA
				$display("Dadda: input A = %d, input B = %d, output OUT = %d",in_inter.A,in_inter.B,out_inter.data);
                        	$display("Dadda: input A = %b, input B = %b, output OUT = %b",in_inter.A,in_inter.B,out_inter.data);
			`else
				$display("adder: input A = %d, input B = %d, output OUT = %d",in_inter.A,in_inter.B,out_inter.data);
                        	$display("adder: input A = %b, input B = %b, output OUT = %b",in_inter.A,in_inter.B,out_inter.data);
			`endif
			out_inter.valid <= 1;
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        `ifdef FPMULT 
			   state <= DELAY;
			   save = 1;
                        `else
			   state <= WAIT;
			`endif
                    end
                end
        endcase
    end
endmodule: DUT
