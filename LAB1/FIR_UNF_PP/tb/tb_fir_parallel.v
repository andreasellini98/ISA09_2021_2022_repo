//`timescale 1ns

module tb_fir ();

   wire CLK_i;
   wire RST_n_i;
   wire [9:0] DIN_i_x;
   wire [9:0] DIN_i_y;
   wire [9:0] DIN_i_z;
   wire VIN_i;
   wire [9:0] H0_i;
   wire [9:0] H1_i;
   wire [9:0] H2_i;
   wire [9:0] H3_i;
   wire [9:0] H4_i;
   wire [9:0] H5_i;
   wire [9:0] H6_i;
   wire [9:0] H7_i;
   wire [9:0] H8_i;
   wire [9:0] H9_i;
   wire [9:0] H10_i;
   
   wire [9:0] DOUT_i_x;
   wire [9:0] DOUT_i_y;
   wire [9:0] DOUT_i_z;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT_x(DIN_i_x),
		 .DOUT_y(DIN_i_y),
		 .DOUT_z(DIN_i_z),
		 .H0(H0_i),
		 .H1(H1_i),
		 .H2(H2_i),
		 .H3(H3_i),
		 .H4(H4_i),
		 .H5(H5_i),
		 .H6(H6_i),
		 .H7(H7_i),
		 .H8(H8_i),
		 .H9(H9_i),
		 .H10(H10_i),	
		 .END_SIM(END_SIM_i));

   Lab1_FIR_DUT UUT(
	     
	     .DIN_x(DIN_i_x),
         .DIN_y(DIN_i_y),
		 .DIN_z(DIN_i_z),
		 .b0(H0_i),
		 .b1(H1_i),
		 .b2(H2_i),
		 .b3(H3_i),
		 .b4(H4_i),
		 .b5(H5_i),
		 .b6(H6_i),
		 .b7(H7_i),
		 .b8(H8_i),
		 .b9(H9_i),
		 .b10(H10_i),
		 .VIN(VIN_i),
	     .RSTn(RST_n_i),
		 .CLK(CLK_i),
         .DOUT_x(DOUT_i_x),
		 .DOUT_y(DOUT_i_y),
		 .DOUT_z(DOUT_i_z),
         .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN_x(DOUT_i_x),
		.DIN_y(DOUT_i_y),
		.DIN_z(DOUT_i_z));   

endmodule

		   