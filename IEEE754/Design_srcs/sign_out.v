`timescale 1ns / 1ps

module sign_out(
    input [23:0] MA,
    input [23:0] MB,
    input SA,
    input SB,
    input add_sub,
    output reg [23:0] MA_dash,
    output reg [23:0] MB_dash,
    output SO, //sign out
    output SB_new,
    output add_sub_new
    );

assign SB_new = SB ^ add_sub;
assign SO = SA;  //as A is max
assign add_sub_new = (SA != SB_new) ? 1 : 0;

always@* begin
    if(~(SA ^ SB_new)) begin            // Sign A and Sign B_new are equal => No change
        MA_dash = MA;
        MB_dash = MB;
    end
    
    else if(SA & (~SB_new)) begin       // SA = 1 and SB_new = 0  => Swap
        MA_dash <= MB;
        MB_dash <= MA;
    end
    
    else begin                          // SA = 0 and SB_new = 1   => No change
        MA_dash <= MA;
        MB_dash <= MB;
    end     
end

endmodule
