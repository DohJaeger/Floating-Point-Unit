`timescale 1ns / 1ps

module prepender(
    input [31:0] A_i,
    input [31:0] B_i,
    output [32:0] A_o,
    output [32:0] B_o
    );

    assign A_o = {A_i[31:23],1'b1,A_i[22:0]};
    assign B_o = {B_i[31:23],1'b1,B_i[22:0]};
endmodule
