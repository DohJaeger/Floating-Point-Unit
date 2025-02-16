`timescale 1ns / 1ps
 
module ALU_24_bit
  (
   input [23:0] MA,
   input [23:0] MB,
   input SA,
   input SB_new,
   input add_sub_new,
   input SO,
   output [23:0]  Mout,
   output Cout
   );
  
  wire [23:0] MB_dash;
  wire [24:0] w_C;
  wire [23:0] w_G, w_P, w_SUM;
  
  assign w_C[0] = (add_sub_new == 1) ? 1 : 0;
  assign MB_dash = (add_sub_new == 1) ? (MB ^ 24'hFFFFFF) : MB;
  
 
  // Create the Full Adders
  genvar i;
  generate
    for (i=0; i<24; i=i+1) 
      begin
        full_adder full_adder_inst
            ( 
              .a(MA[i]),
              .b(MB_dash[i]),
              .cin(w_C[i]),
              .sum(w_SUM[i]),
              .cout()
              );
      end
  endgenerate
 
  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar j;
  generate
    for (j=0; j<24; j=j+1) 
      begin
        assign w_G[j]   = MA[j] & MB_dash[j];
        assign w_P[j]   = MA[j] | MB_dash[j];
        assign w_C[j+1] = w_G[j] | (w_P[j] & w_C[j]);
      end
  endgenerate
  
  assign Mout = (add_sub_new & SO) ? ((w_SUM ^ 24'hFFFFFF) + 1) : w_SUM;  //Mantissa out
  assign Cout = (SB_new != SA) ? 0 : w_C[24];  // Carry out
 
endmodule