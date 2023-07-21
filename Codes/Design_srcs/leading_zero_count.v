`timescale 1ns / 1ps

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
