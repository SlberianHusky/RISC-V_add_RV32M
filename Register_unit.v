`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/01 21:18:28
// Design Name: 
// Module Name: Register_unit
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


module Register_unit(
	//clock reset
	input clk, reset,
	//for WB
	input Ctl_RegWrite_in,
	input [4:0] WriteReg,
	input [31:0] WriteData,
	//for InDecode
	input [4:0] ind_rs1_0, ind_rs2_0, ind_rs1_1, ind_rs2_1,
	output [31:0] ind_ReadData1_0, ind_ReadData2_0, ind_ReadData1_1, ind_ReadData2_1,
	//for Jalr_Forward
	input [4:0] jalr_rs_0, jalr_rs_1, jalr_rs_2, jalr_rs_3,
	output [31:0] jalr_ReadData_0, jalr_ReadData_1, jalr_ReadData_2, jalr_ReadData_3,
	//for kernel
	input context_switch_active,
	input [4:0] context_switch_count,
	input [31:0] switching_data,
	output [991:0] all_reg_data
	);
	reg [31:0] Reg [0:31];
	integer i;
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			for(i=0;i<32;i=i+1) begin
				Reg[i] <= 32'b0;
			end
		end else if(context_switch_active) begin
			Reg[context_switch_count] <= switching_data;
		end else if (Ctl_RegWrite_in & (WriteReg!=0)) begin
			Reg[WriteReg] <= WriteData;
		end
	end
	assign ind_ReadData1_0 = (Ctl_RegWrite_in && WriteReg==ind_rs1_0 && (ind_rs1_0 != 0)) ? WriteData : Reg[ind_rs1_0];
	assign ind_ReadData2_0 = (Ctl_RegWrite_in && WriteReg==ind_rs2_0 && (ind_rs2_0 != 0)) ? WriteData : Reg[ind_rs2_0];
	assign ind_ReadData1_1 = (Ctl_RegWrite_in && WriteReg==ind_rs1_1 && (ind_rs1_1 != 0)) ? WriteData : Reg[ind_rs1_1];
	assign ind_ReadData2_1 = (Ctl_RegWrite_in && WriteReg==ind_rs2_1 && (ind_rs2_1 != 0)) ? WriteData : Reg[ind_rs2_1];
	assign jalr_ReadData_0 = (Ctl_RegWrite_in && WriteReg==jalr_rs_0 && (jalr_rs_0 != 0)) ? WriteData : Reg[jalr_rs_0];
	assign jalr_ReadData_1 = (Ctl_RegWrite_in && WriteReg==jalr_rs_1 && (jalr_rs_1 != 0)) ? WriteData : Reg[jalr_rs_1];
	assign jalr_ReadData_2 = (Ctl_RegWrite_in && WriteReg==jalr_rs_2 && (jalr_rs_2 != 0)) ? WriteData : Reg[jalr_rs_2];
	assign jalr_ReadData_3 = (Ctl_RegWrite_in && WriteReg==jalr_rs_3 && (jalr_rs_3 != 0)) ? WriteData : Reg[jalr_rs_3];
	assign all_reg_data = ({Reg[31],Reg[30],Reg[29],Reg[28],Reg[27],Reg[26],Reg[25],Reg[24],Reg[23],Reg[22],Reg[21],Reg[20],Reg[19],Reg[18],Reg[17],Reg[16],Reg[15],Reg[14],Reg[13],Reg[12],Reg[11],Reg[10],Reg[9],Reg[8],Reg[7],Reg[6],Reg[5],Reg[4],Reg[3],Reg[2],Reg[1]});
endmodule