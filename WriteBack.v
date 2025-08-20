`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/26 14:58:35
// Design Name: 
// Module Name: WriteBack
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


module WriteBack(
	input Ctl_RegWrite_in,
	input [4:0] Rd_in,
	input [31:0] MEMresult_in,
	output reg Ctl_RegWrite_out,
	output reg [4:0] Rd_out,
	output reg [31:0] WriteDatatoReg_out
	);
	always @(*) begin
		Ctl_RegWrite_out		<= Ctl_RegWrite_in;
		Rd_out					<= Rd_in;
		WriteDatatoReg_out		<= MEMresult_in;
	end
endmodule