`timescale 1ns / 1ps

module final_vector(
    input [23:0] M_in,
    input [7:0] E_in,
    input [4:0] Mantissa_shift,
    input SO,
    output [31:0] Result
    );
    
    reg [22:0] M_out;
    reg [7:0] E_out;
    wire [23:0] M_24_bit_temp;
    
    left_shifter f0(.A(M_in),
                    .Shift_amt(Mantissa_shift),
                    .A_shifted(M_24_bit)
                    );
    assign M_24_bit_temp = M_24_bit;  
             
    always@* begin
        if(Mantissa_shift == 0 && M_in == 0 && (0 <= E_in < 255)) begin  //zero
            M_out = 0;
            E_out = 0;
        end
        
        else if(Mantissa_shift == 0 && M_in == 0 &&  E_in == 255) begin  //inf
            M_out = 0;
            E_out = 255;
        end
        
        else if(Mantissa_shift == 0 && M_in != 0 &&  E_in == 255) begin  //inf
            M_out = 0;
            E_out = 255;
        end
        
        else begin
            M_out = M_24_bit_temp[22:0];
            E_out = E_in;
        end
    end
    
    assign Result = {SO,E_out,M_out};
endmodule
