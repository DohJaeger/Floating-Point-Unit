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
                  
    barrel_shifter f2(.In(M_shift),
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
    
    barrel_shifter f5(.In(MR),
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
