`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2024 13:05:20
// Design Name: 
// Module Name: top
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

module top(
    input clk_in, rst, 
    output zero, underflow, overflow, qNaN, sNaN, positive_inf, negative_inf
);

    wire [15:0] result;
    wire [3:0] PC_addr;
    wire [49:0] data;
    
    reg [15:0] k, j;
    wire [15:0] A, B, C;

    program_counter pc1 (
        .clk_in(clk_in), 
        .rst(rst), 
        .PC_addr(PC_addr)
    );

    BF16_FMA dut (
        .A(A), 
        .B(B), 
        .C(C), 
        .result(result), 
        .zero(zero), 
        .underflow(underflow), 
        .overflow(overflow), 
        .qNaN(qNaN), 
        .sNaN(sNaN), 
        .positive_inf(positive_inf), 
        .negative_inf(negative_inf)
    );

    instr_mem inst1 (
        .PC_addr(PC_addr), 
        .data(data)
    );

    assign A = data[47:32];
    assign B = data[31:16];

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            k <= 16'd0;
            j <= 16'd0;
        end else if (data[49]) begin
            k <= result;
        end else begin
            j <= result;
        end
    end

    assign C = data[48] ? data[15:0] : k;

endmodule
