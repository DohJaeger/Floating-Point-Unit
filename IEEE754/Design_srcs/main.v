`timescale 1ns / 1ps

module main(
    input [31:0] A_in,
    input [31:0] B_in,
    input A_S,
    output [31:0] Result
    );
    
    wire [23:0] MA_signout, MB_signout,MR_barrel_temp;
    wire SA_signout, SB_signout;
    //wire [4:0] shift_en;
    //concatenate 1 in mantissa of A and B
    prepender f0(.A_i(A_in),
                 .B_i(B_in),
                 .A_o(A_p),
                 .B_o(B_p)
                 );
    
    comparator f1(.A(A_p),
                  .B(B_p),
                  .EXP_MAX(E_max),
                  .M_MAX(M_max),
                  .M_SHIFT(M_shift),
                  .S_MAX(S_max),
                  .S_SHIFT(S_shift),
                  .EXP_DIFF(Shift_amt)
                  );
                  
    shifter f2(.In(M_shift),
                      .Shift(Shift_amt),
                      .Out(Mshift_out)
                      );
    
//    assign MA_signout = M_max;
//    assign MB_signout = Mshift_out;
//    assign SA_signout = S_max;
//    assign SB_signout = S_shift;
    
    sign_out f3(.MA(M_max),
                .MB(Mshift_out),
                .SA(S_max),
                .SB(S_shift),
                .add_sub(A_S),
                .MA_dash(MA_add),
                .MB_dash(MB_add),
                .SO(SO),
                .SB_new(SB_new),
                .add_sub_new(A_S_new)
                );
                
    ALU_24_bit f4(.MA(MA_add),
                  .MB(MB_add),
                  .SA(SA_signout),
                  .SB_new(SB_new),
                  .add_sub_new(A_S_new),
                  .SO(SO),
                  .Mout(MR),
                  .Cout(CR)
                  );
                  
    assign shift_en = {4'b0,CR};
    
    shifter f5(.In(MR),
                      .Shift(shift_en),
                      .Out(MR_barrel)
                      );
    assign MR_barrel_temp = MR_barrel;
    assign M_prefinal = (CR == 1) ? {1'b1, MR_barrel_temp[22:0]} : MR_barrel_temp;
                      
    exp_incrementer f6(.E_in(E_max),
                    .C(CR),
                    .E_out(E_CR)
                    );
                    
    leading_zero_count f7(.A(M_prefinal),
                          .z_cnt(shift_left_amt)
                          );
        
    exp_decrementer f9(.E_in(E_CR),
                       .Z_cnt(shift_left_amt),
                       .E_out(E_prefinal),
                       .Mantissa_shift(Mantissa_shift_amt)
                       );
            
    final_vector f10(.M_in(M_prefinal),
                 .E_in(E_prefinal),
                 .Mantissa_shift(Mantissa_shift_amt),
                 .SO(SO),
                 .Result(Result)
                 );
endmodule


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

module comparator(
    input [32:0] A,
    input [32:0] B,
    output [7:0] EXP_MAX, //Largest Exponent
    output [23:0] M_MAX, //Largest Mantissa
    output [23:0] M_SHIFT, //Largest to shift
    output S_MAX,
    output S_SHIFT,
    output [4:0] EXP_DIFF // Difference b/w the exponent
    );
    reg [7:0] EA, EB, Emax;
    reg [23:0] MA, MB;
    reg C;
    reg [4:0] Diff, Ediff;
    reg [32:0] MAX, SHIFT;
    
    always@* begin
        EA = A[31:24];
        EB = B[31:24];
        MA = A[23:0];
        MB = B[23:0];
        
        //C
        if(EA > EB) C = 1;
        else if(EA < EB) C = 0;        
        else if(MA > MB) C = 1;
        else C = 0;
        
        //Emax
        Emax = (C == 1) ? EA : EB;
        
        //Diff
        Diff = (C == 1) ? (EA - EB) : (EB - EA);
        
        //Shift_diff
        Ediff = (Diff < 24) ? Diff : 24;
        
        //In_Max and In_shift
        if(C == 1) begin
            MAX  = A;
            SHIFT = B;
        end
        
        else begin
            MAX = B;
            SHIFT = A;
        end
    end
    
    assign M_SHIFT = SHIFT[23:0];
    assign M_MAX = MAX[23:0];
    assign EXP_MAX = Emax;
    assign EXP_DIFF = Ediff;
    assign S_SHIFT = SHIFT[32];
    assign S_MAX = MAX[32];
endmodule

module exp_decrementer(
    input [7:0] E_in,
    input [4:0] Z_cnt,
    output [7:0] E_out,
    output reg [4:0] Mantissa_shift
    );
    
    wire [7:0] sub_amt;
    reg [7:0] A_aux, B_aux;
    assign sub_amt = {3'b0 , Z_cnt};
    
    always@* begin
        if((0 < sub_amt < 24) && (E_in == sub_amt)) begin
            Mantissa_shift = sub_amt - 1;     //fractional form  -- M != 0 & E = 0    
            A_aux = 0;
            B_aux = 0;
        end
        
        else if((sub_amt < 24) && (E_in > sub_amt)) begin
            Mantissa_shift = sub_amt;         //normal form or NaN form  --    E != 0 
            A_aux = E_in;
            B_aux = sub_amt;
        end
        
        else if((sub_amt < 24) && (E_in < sub_amt)) begin
            Mantissa_shift = E_in;            //fractional form -- E = 0  
            A_aux = 0;
            B_aux = 0;
        end
        
        else begin
            Mantissa_shift = 0;               // result is 0 or inf
            A_aux = E_in;
            B_aux = 0;
        end
    end
    
    ALU_8_bit f0(.A(A_aux),.B(B_aux),.Z(1),.Sum(E_out),.Cout(Cout));
    
endmodule

module exp_incrementer(
    input [7:0] E_in,
    input C,
    output reg [7:0] E_out
    );
    
    always@* begin
        if(E_in < 255)
            E_out = E_in + C;
        else
            E_out = E_in;
    end
endmodule

module final_vector(
    input [23:0] M_in,
    input [7:0] E_in,
    input [4:0] Mantissa_shift,
    input SO,
    output [31:0] Result
    );
    
    reg [22:0] M_out;
    reg [7:0] E_out;
    wire [23:0] M_24_bit_temp;
    
    left_shifter f0(.A(M_in),
                    .Shift_amt(Mantissa_shift),
                    .A_shifted(M_24_bit)
                    );
    assign M_24_bit_temp = M_24_bit;  
             
    always@* begin
        if(Mantissa_shift == 0 && M_in == 0 && (0 <= E_in < 255)) begin  //zero
            M_out = 0;
            E_out = 0;
        end
        
        else if(Mantissa_shift == 0 && M_in == 0 &&  E_in == 255) begin  //inf
            M_out = 0;
            E_out = 255;
        end
        
        else if(Mantissa_shift == 0 && M_in != 0 &&  E_in == 255) begin  //inf
            M_out = 0;
            E_out = 255;
        end
        
        else begin
            M_out = M_24_bit_temp[22:0];
            E_out = E_in;
        end
    end
    
    assign Result = {SO,E_out,M_out};
endmodule

module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
    );
  wire x,y,z;

  half_adder h1(.a(a),.b(b),.s(x),.c(y));
  half_adder h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule

module half_adder(
    input a,
    input b,
    output s,
    output c
    );
  
xor x1(s,a,b);
and a1(c,a,b);
endmodule

module leading_zero_count(
    input [23:0] A,
    output reg [4:0] z_cnt
    );
    
    wire [23:0] zero_vector;
    assign zero_vector = 24'b0;
    
    always@* begin
        if(A[23:0] == zero_vector[23:0])        z_cnt = 24;
        else if(A[23:1] == zero_vector[23:1])   z_cnt = 23;
        else if(A[23:2] == zero_vector[23:2])   z_cnt = 22;
        else if(A[23:3] == zero_vector[23:3])   z_cnt = 21;
        else if(A[23:4] == zero_vector[23:4])   z_cnt = 20;
        else if(A[23:5] == zero_vector[23:5])   z_cnt = 19;
        else if(A[23:6] == zero_vector[23:6])   z_cnt = 18;
        else if(A[23:7] == zero_vector[23:7])   z_cnt = 17;
        else if(A[23:8] == zero_vector[23:8])   z_cnt = 16;
        else if(A[23:9] == zero_vector[23:9])   z_cnt = 15;
        else if(A[23:10] == zero_vector[23:10]) z_cnt = 14;
        else if(A[23:11] == zero_vector[23:11]) z_cnt = 13;
        else if(A[23:12] == zero_vector[23:12]) z_cnt = 12;
        else if(A[23:13] == zero_vector[23:13]) z_cnt = 11;
        else if(A[23:14] == zero_vector[23:14]) z_cnt = 10;
        else if(A[23:15] == zero_vector[23:15]) z_cnt = 9;
        else if(A[23:16] == zero_vector[23:16]) z_cnt = 8;
        else if(A[23:17] == zero_vector[23:17]) z_cnt = 7;
        else if(A[23:18] == zero_vector[23:18]) z_cnt = 6;
        else if(A[23:19] == zero_vector[23:19]) z_cnt = 5;
        else if(A[23:20] == zero_vector[23:20]) z_cnt = 4;
        else if(A[23:21] == zero_vector[23:21]) z_cnt = 3;
        else if(A[23:22] == zero_vector[23:22]) z_cnt = 2;
        else if(A[23:23] == zero_vector[23:23]) z_cnt = 1;
        else z_cnt = 0;
    end
endmodule

module left_shifter(
    input [23:0] A,
    input [4:0] Shift_amt,
    output [23:0] A_shifted
    );
    
    wire [23:0] A_rev, A_rev_out_temp;
    assign A_rev = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],
                         A[11],A[12],A[13],A[14],A[15],A[16],A[17],A[18],A[19],A[20],
                         A[21],A[22],A[23]};
                         
    barrel_shifter left(.In(A_rev),.Shift(Shift_amt),.Out(A_rev_out));
    
    assign A_rev_out_temp = A_rev_out;
    assign A_shifted = {A_rev_out_temp[0],A_rev_out_temp[1],A_rev_out_temp[2],A_rev_out_temp[3],A_rev_out_temp[4],
                        A_rev_out_temp[5],A_rev_out_temp[6],A_rev_out_temp[7],A_rev_out_temp[8],A_rev_out_temp[9],
                        A_rev_out_temp[10],A_rev_out_temp[11],A_rev_out_temp[12],A_rev_out_temp[13],A_rev_out_temp[14],
                        A_rev_out_temp[15],A_rev_out_temp[16],A_rev_out_temp[17],A_rev_out_temp[18],A_rev_out_temp[19],
                        A_rev_out_temp[20],A_rev_out_temp[21],A_rev_out_temp[22],A_rev_out_temp[23]};
    
endmodule

module Mux(
    input In0,
    input In1,
    input S,
	 output Out
    );
	 
    wire w1,w2; 
    
    and(w1,~S,In0);
    and(w2,S,In1);
    or (Out,w1,w2);	 

endmodule

module prepender(
    input [31:0] A_i,
    input [31:0] B_i,
    output [32:0] A_o,
    output [32:0] B_o
    );

    assign A_o = {A_i[31:23],1'b1,A_i[22:0]};
    assign B_o = {B_i[31:23],1'b1,B_i[22:0]};
endmodule

module shifter(
    input [23:0] In,
    input [4:0] Shift,
    output [23:0] Out
    );
	 
	case(Shift)
		5'd0 : Out = In;
		5'd1 : Out = {1'b0,In[23:1]};
		5'd2 : Out = {2'b0,In[23:2]};
		5'd3 : Out = {3'b0,In[23:3]};
		5'd4 : Out = {4'b0,In[23:4]};
		5'd5 : Out = {5'b0,In[23:5]};
		5'd6 : Out = {6'b0,In[23:6]};
		5'd7 : Out = {7'b0,In[23:7]};
		5'd8 : Out = {8'b0,In[23:8]};
		5'd9 : Out = {9'b0,In[23:9]};
		5'd10 : Out = {10'b0,In[23:10]};
		5'd11 : Out = {11'b0,In[23:11]};
		5'd12 : Out = {12'b0,In[23:12]};
		5'd13 : Out = {13'b0,In[23:13]};
		5'd14 : Out = {14'b0,In[23:14]};
		5'd15 : Out = {15'b0,In[23:15]};
		5'd16 : Out = {16'b0,In[23:16]};
		5'd17 : Out = {17'b0,In[23:17]};
		5'd18 : Out = {18'b0,In[23:18]};
		5'd19 : Out = {19'b0,In[23:19]};
		5'd20 : Out = {20'b0,In[23:20]};
		5'd21: Out = {21'b0,In[23:21]};
		5'd22: Out = {22'b0,In[23:22]};
		5'd23: Out = {23'b0,In[23:23]};
		5'd24: Out = {24'b0};
		default : Out = In;
	endcase
endmodule

module sign_out(
    input [23:0] MA,
    input [23:0] MB,
    input SA,
    input SB,
    input add_sub,
    output reg [23:0] MA_dash,
    output reg [23:0] MB_dash,
    output SO, //sign out
    output SB_new,
    output add_sub_new
    );

assign SB_new = SB ^ add_sub;
assign SO = SA;  //as A is max
assign add_sub_new = (SA != SB_new) ? 1 : 0;

always@* begin
    if(~(SA ^ SB_new)) begin            // Sign A and Sign B_new are equal => No change
        MA_dash = MA;
        MB_dash = MB;
    end
    
    else if(SA & (~SB_new)) begin       // SA = 1 and SB_new = 0  => Swap
        MA_dash <= MB;
        MB_dash <= MA;
    end
    
    else begin                          // SA = 0 and SB_new = 1   => No change
        MA_dash <= MA;
        MB_dash <= MB;
    end     
end

endmodule