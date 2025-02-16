`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024 23:40:21
// Design Name: 
// Module Name: bf16_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bf16_adder(
    input  [15:0] num_1,
    input  [15:0] num_2,
    output reg [15:0] result,
    output reg zero,
    output reg underflow,
    output reg overflow,
    output reg q_nan,
    output reg s_nan,
    output reg positive_inf,
    output reg negative_inf
);

reg res_sign;
reg signed [8:0] res_exp;
reg signed [8:0] res_mant;
reg [3:0] shift_amt;
wire sign_1, sign_2;
wire [7:0] exp_1, exp_2;
wire [6:0] mant_1, mant_2;
wire [7:0] mant_eff_1, mant_eff_2;

assign sign_1 = num_1[15];
assign sign_2 = num_2[15];
assign exp_1 = num_1[14:7];
assign exp_2 = num_2[14:7];
assign mant_1 = num_1[6:0]; 
assign mant_2 = num_2[6:0];
assign mant_eff_1 = {1'b1, mant_1};
assign mant_eff_2 = {1'b1, mant_2};

always @(*) begin
    zero = 1'b0;
    underflow = 1'b0;
    overflow = 1'b0;
    q_nan = 1'b0;
    s_nan = 1'b0;
    positive_inf = 1'b0;
    negative_inf = 1'b0;
    
    if (exp_1 == 8'd0)
        result = num_2;
    if (exp_2 == 8'd0)
        result = num_1;
    if (exp_1 == 8'd0 && exp_2 == 8'd0) begin
        result = 16'd0;
        zero = 1'b1;
    end
    if ((exp_1 == 8'hff && sign_1 == 1'b0) || (exp_2 == 8'hff && sign_2 == 1'b0)) begin
        result = 16'h7f80;
        positive_inf = 1'b1;
    end else if ((exp_1 == 8'hff && sign_1 == 1'b1) || (exp_2 == 8'hff && sign_2 == 1'b1)) begin
        result = 16'hff80;
        negative_inf = 1'b1;
    end
    if (num_1 == 16'h7fc1 || num_2 == 16'hffc1) begin
        result = 16'hffc1;
        q_nan = 1'b1;
    end else if (num_1 == 16'h7f81 || num_2 == 16'hff81) begin
        result = 16'hff81;
        s_nan = 1'b1;
    end

    if (sign_1 == sign_2 && exp_1 != 8'd0 && exp_2 != 8'd0 && exp_1 != 8'd255 && exp_2 != 8'd255) begin
        if (exp_1 >= exp_2) begin
            res_sign = sign_1;
            res_exp = exp_1;
            res_mant = mant_eff_1 + (mant_eff_2 >> (exp_1 - exp_2));
        end else begin
            res_sign = sign_2;
            res_exp = exp_2;
            res_mant = mant_eff_2 + (mant_eff_1 >> (exp_2 - exp_1));
        end
        if (res_mant[8]) begin
            res_exp = res_exp + 9'd1;
            res_mant = res_mant >> 1;
        end
    end else if (sign_1 != sign_2 && exp_1 != 8'd0 && exp_2 != 8'd0 && exp_1 != 8'd255 && exp_2 != 8'd255) begin
        if (exp_1 > exp_2) begin
            res_sign = sign_1;
            res_exp = exp_1;
            res_mant = mant_eff_1 - (mant_eff_2 >> (exp_1 - exp_2));
        end else if (exp_1 < exp_2) begin
            res_sign = sign_2;
            res_exp = exp_2;
            res_mant = mant_eff_2 - (mant_eff_1 >> (exp_2 - exp_1));
        end else begin
            if (mant_eff_1 >= mant_eff_2) begin
                res_sign = sign_1;
                res_exp = exp_1;
                res_mant = mant_eff_1 - mant_eff_2;
            end else begin
                res_sign = sign_2;
                res_exp = exp_1;
                res_mant = mant_eff_2 - mant_eff_1;
            end
        end

        casez (res_mant)
            9'b01zzzzzzz : shift_amt = 4'd0;
            9'b001zzzzzz : shift_amt = 4'd1;
            9'b0001zzzzz : shift_amt = 4'd2;
            9'b00001zzzz : shift_amt = 4'd3;
            9'b000001zzz : shift_amt = 4'd4;
            9'b0000001zz : shift_amt = 4'd5;
            9'b00000001z : shift_amt = 4'd6;
            9'b000000001 : shift_amt = 4'd7;
            9'b000000000 : shift_amt = 4'd8;
        endcase
        
        res_mant = res_mant << shift_amt;
        res_exp = res_exp - shift_amt;
    end

    if (exp_1 != 8'd0 && exp_2 != 8'd0 && exp_1 != 8'd255 && exp_2 != 8'd255)
        result = {res_sign, res_exp[7:0], res_mant[6:0]};
    if (res_exp >= 9'd255)
        overflow = 1'b1;
    else if (res_exp[8])
        underflow = 1'b1;
end

endmodule