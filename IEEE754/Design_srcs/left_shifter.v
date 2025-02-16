`timescale 1ns / 1ps

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
