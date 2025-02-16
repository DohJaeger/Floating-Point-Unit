`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2024 12:36:56
// Design Name: 
// Module Name: instr_mem
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


module instr_mem(
    input  [3:0] PC_addr,
    output reg [49:0] data
);

reg [49:0] reg_bank [15:0];

initial begin
    $readmemb("inputs.mem", reg_bank);
end

always @(*) begin
    data = reg_bank[PC_addr];
end

endmodule
