`timescale 1ns / 1ps

module exp_decrementer(
    input [7:0] E_in,
    input [4:0] Z_cnt,
    output [7:0] E_out,
    output reg [4:0] Mantissa_shift
    );
    
    wire [7:0] sub_amt;
    reg [7:0] A_aux, B_aux;
    assign sub_amt = {3'b0 , Z_cnt};
    
    always@* begin
        if((0 < sub_amt < 24) && (E_in == sub_amt)) begin
            Mantissa_shift = sub_amt - 1;     //fractional form  -- M != 0 & E = 0    
            A_aux = 0;
            B_aux = 0;
        end
        
        else if((sub_amt < 24) && (E_in > sub_amt)) begin
            Mantissa_shift = sub_amt;         //normal form or NaN form  --    E != 0 
            A_aux = E_in;
            B_aux = sub_amt;
        end
        
        else if((sub_amt < 24) && (E_in < sub_amt)) begin
            Mantissa_shift = E_in;            //fractional form -- E = 0  
            A_aux = 0;
            B_aux = 0;
        end
        
        else begin
            Mantissa_shift = 0;               // result is 0 or inf
            A_aux = E_in;
            B_aux = 0;
        end
    end
    
    ALU_8_bit f0(.A(A_aux),.B(B_aux),.Z(1),.Sum(E_out),.Cout(Cout));
    
endmodule
