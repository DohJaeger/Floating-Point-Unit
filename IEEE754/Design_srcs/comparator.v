`timescale 1ns / 1ps

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
