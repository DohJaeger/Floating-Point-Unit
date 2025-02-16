`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2024 01:52:41
// Design Name: 
// Module Name: bf16_multiplier
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


module bf16_multiplier(
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
reg signed [15:0] res_mant;
wire sign_1, sign_2;
wire [7:0] exp_1, exp_2;
wire [6:0] mant_1, mant_2;
wire [7:0] mant_eff_1, mant_eff_2;

// Extract sign, exponent, and mantissa
assign sign_1 = num_1[15];
assign sign_2 = num_2[15];
assign exp_1  = num_1[14:7];
assign exp_2  = num_2[14:7];
assign mant_1 = num_1[6:0];
assign mant_2 = num_2[6:0];
assign mant_eff_1 = {1'b1, mant_1};
assign mant_eff_2 = {1'b1, mant_2};

always @(*) begin

    // zero Cases
    if (exp_1 == 8'd0 || exp_2 == 8'd0) begin
        result = 16'd0;
        zero = 1'b1;
    end 
    // NaN Cases
    else if (num_1 == 16'h7fc1 || num_2 == 16'hffc1) begin
        result = 16'hffc1;
        q_nan = 1'b1;
    end 
    else if (num_1 == 16'h7f81 || num_2 == 16'hff81) begin
        result = 16'hff81;
        s_nan = 1'b1;
    end 
    // infinity Cases
    else if (exp_1 == 8'hff || exp_2 == 8'hff) begin
        result = {sign_1 ^ sign_2, 15'b111111110000000};
        if (sign_1 ^ sign_2 == 1'b0)
            positive_inf = 1'b1;
        else
            negative_inf = 1'b1;
    end 
    // multiplication
    else begin
        res_sign = sign_1 ^ sign_2;
        res_exp = exp_1 + exp_2 - 9'd127;
        res_mant = mant_eff_1 * mant_eff_2;

        // normalize result
        if (res_mant[15] == 1'b1) begin
            res_exp = res_exp + 9'd1;
            res_mant = res_mant >> 1;
        end

        result = {res_sign, res_exp[7:0], res_mant[13:7]};

        // overflow/underflw
        if (res_exp >= 9'd255)
            overflow = 1'b1;
        else if (res_exp[8] == 1'b1)
            underflow = 1'b1;
    end
end

endmodule
