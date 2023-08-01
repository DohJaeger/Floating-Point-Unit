`timescale 1ns / 1ps

module shifter(
    input [23:0] In,
    input [4:0] Shift,
    output [23:0] Out
    );
	 
	case(Shift)
		5'd0 : Out = In;
		5'd1 : Out = {1'b0,In[23:1]};
		5'd2 : Out = {2'b0,In[23:2]};
		5'd3 : Out = {3'b0,In[23:3]};
		5'd4 : Out = {4'b0,In[23:4]};
		5'd5 : Out = {5'b0,In[23:5]};
		5'd6 : Out = {6'b0,In[23:6]};
		5'd7 : Out = {7'b0,In[23:7]};
		5'd8 : Out = {8'b0,In[23:8]};
		5'd9 : Out = {9'b0,In[23:9]};
		5'd10 : Out = {10'b0,In[23:10]};
		5'd11 : Out = {11'b0,In[23:11]};
		5'd12 : Out = {12'b0,In[23:12]};
		5'd13 : Out = {13'b0,In[23:13]};
		5'd14 : Out = {14'b0,In[23:14]};
		5'd15 : Out = {15'b0,In[23:15]};
		5'd16 : Out = {16'b0,In[23:16]};
		5'd17 : Out = {17'b0,In[23:17]};
		5'd18 : Out = {18'b0,In[23:18]};
		5'd19 : Out = {19'b0,In[23:19]};
		5'd20 : Out = {20'b0,In[23:20]};
		5'd21: Out = {21'b0,In[23:21]};
		5'd22: Out = {22'b0,In[23:22]};
		5'd23: Out = {23'b0,In[23:23]};
		5'd24: Out = {24'b0};
		default : Out = In;
	endcase
endmodule
