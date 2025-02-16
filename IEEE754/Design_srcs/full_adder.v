`timescale 1ns / 1ps

module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
    );
  wire x,y,z;

  half_adder h1(.a(a),.b(b),.s(x),.c(y));
  half_adder h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule
