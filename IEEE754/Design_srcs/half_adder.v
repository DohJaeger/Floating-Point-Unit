`timescale 1ns / 1ps
       
module half_adder(
    input a,
    input b,
    output s,
    output c
    );
  
xor x1(s,a,b);
and a1(c,a,b);
endmodule
