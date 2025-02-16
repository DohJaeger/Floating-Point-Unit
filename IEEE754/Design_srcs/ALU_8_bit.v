`timescale 1ns / 1ps

module ALU_8_bit(
    input [7:0] A,
    input [7:0] B,
    input Z,
    output [7:0] Sum,
    output Cout
    );
    
    wire jj;
    wire [7:0] B_dash;
    wire [8:0] w_C;
    wire [7:0] w_G, w_P, w_SUM;
    
    assign B_dash = (Z == 1) ? (B ^ 8'hFF) : B;
    assign w_C[0] = (Z == 1) ? 1 : 0;
         
    // Create the Full Adders
    genvar i;
    generate
      for (i=0; i<8; i=i+1) 
        begin
          full_adder full_adder_inst
              ( 
                .a(A[i]),
                .b(B_dash[i]),
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
      for (j=0; j<8; j=j+1) 
        begin
          assign w_G[j]   = A[j] & B_dash[j];
          assign w_P[j]   = A[j] | B_dash[j];
          assign w_C[j+1] = w_G[j] | (w_P[j] & w_C[j]);
        end
    endgenerate
    
    assign Cout = Z == 1 ? 0 : w_C[8];
    assign Sum = w_SUM;
  endmodule
