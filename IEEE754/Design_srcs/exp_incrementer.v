`timescale 1ns / 1ps

module exp_incrementer(
    input [7:0] E_in,
    input C,
    output reg [7:0] E_out
    );
    
    always@* begin
        if(E_in < 255)
            E_out = E_in + C;
        else
            E_out = E_in;
    end
endmodule
