`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2024 10:52:41
// Design Name: 
// Module Name: bf16_fma
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

module bf16_fma(
    input  [15:0] num_a,
    input  [15:0] num_b,
    input  [15:0] num_c,
    output [15:0] result,
    output zero,
    output underflow,
    output overflow,
    output q_nan,
    output s_nan,
    output positive_inf,
    output negative_inf
);

wire [15:0] intermediate_result;
wire underflow_1, overflow_1, underflow_2, overflow_2;

bf16_multiplier mult_1(
    .num_1(num_a),
    .num_2(num_b),
    .result(intermediate_result),
    .zero(),
    .underflow(underflow_1),
    .overflow(overflow_1),
    .q_nan(),
    .s_nan(),
    .positive_inf(),
    .negative_inf()
);

bf16_adder add_1(
    .num_1(intermediate_result),
    .num_2(num_c),
    .result(result),
    .zero(zero),
    .underflow(underflow_2),
    .overflow(overflow_2),
    .q_nan(q_nan),
    .s_nan(s_nan),
    .positive_inf(positive_inf),
    .negative_inf(negative_inf)
);

assign overflow = overflow_1 | overflow_2;
assign underflow = underflow_1 | underflow_2;

endmodule