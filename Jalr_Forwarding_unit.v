`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2024/12/23 05:40:50
// Design Name: 
// Module Name: Jalr_Forwarding_unit
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


module Jalr_Forwarding_unit(
	//request Jalr from InFetch
	input [4:0] jalr_rd_0, jalr_rd_1, jalr_rd_2, jalr_rd_3,
	output jalr_ready_0, jalr_ready_1, jalr_ready_2, jalr_ready_3,
	output [31:0] jalr_reg_in_0, jalr_reg_in_1, jalr_reg_in_2, jalr_reg_in_3,
	//InDecode stage
	input [4:0] jalr_ind_rd_0, jalr_ind_rd_1,
	input jalr_ind_ctl_0, jalr_ind_ctl_1,
	//Execution stage
	input [4:0] jalr_exe_rd,
	input jalr_exe_ctl,
	//Memory stage
	input [4:0] jalr_mem_rd,
	input jalr_mem_ctl_RW, jalr_mem_ctl_MtR,
	input [31:0] jalr_mem_data,
	//Reg stage
	input [31:0] jalr_Reg_Data_0, jalr_Reg_Data_1, jalr_Reg_Data_2, jalr_Reg_Data_3
	);
	//InDecode forward //////////////////////////////////////////////////////////////////////////////////////
	wire ind_same_0 = (jalr_rd_0 == jalr_ind_rd_0) & jalr_ind_ctl_0;
	wire ind_same_1 = (jalr_rd_1 == jalr_ind_rd_0) & jalr_ind_ctl_0;
	wire ind_same_2 = (jalr_rd_2 == jalr_ind_rd_1) & jalr_ind_ctl_1;
	wire ind_same_3 = (jalr_rd_3 == jalr_ind_rd_1) & jalr_ind_ctl_1;
	//Execution forward /////////////////////////////////////////////////////////////////////////////////////
	wire exe_same_0 = (jalr_rd_0 == jalr_exe_rd) & jalr_exe_ctl;
	wire exe_same_1 = (jalr_rd_1 == jalr_exe_rd) & jalr_exe_ctl;
	wire exe_same_2 = (jalr_rd_2 == jalr_exe_rd) & jalr_exe_ctl;
	wire exe_same_3 = (jalr_rd_3 == jalr_exe_rd) & jalr_exe_ctl;
	//Memory forward ////////////////////////////////////////////////////////////////////////////////////////
	wire mem_same_0 = (jalr_rd_0 == jalr_mem_rd) & jalr_mem_ctl_RW;
	wire mem_same_1 = (jalr_rd_1 == jalr_mem_rd) & jalr_mem_ctl_RW;
	wire mem_same_2 = (jalr_rd_2 == jalr_mem_rd) & jalr_mem_ctl_RW;
	wire mem_same_3 = (jalr_rd_3 == jalr_mem_rd) & jalr_mem_ctl_RW;
	wire mem_stall_0 = mem_same_0 & jalr_mem_ctl_MtR;
	wire mem_stall_1 = mem_same_1 & jalr_mem_ctl_MtR;
	wire mem_stall_2 = mem_same_2 & jalr_mem_ctl_MtR;
	wire mem_stall_3 = mem_same_3 & jalr_mem_ctl_MtR;
	//ready signals /////////////////////////////////////////////////////////////////////////////////////////
	assign jalr_ready_0 = (!ind_same_0) & (!exe_same_0) & (!mem_stall_0);
	assign jalr_ready_1 = (!ind_same_1) & (!exe_same_1) & (!mem_stall_1);
	assign jalr_ready_2 = (!ind_same_2) & (!exe_same_2) & (!mem_stall_2);
	assign jalr_ready_3 = (!ind_same_3) & (!exe_same_3) & (!mem_stall_3);
	//ready data ////////////////////////////////////////////////////////////////////////////////////////////
	assign jalr_reg_in_0 = (jalr_ready_0 & mem_same_0) ? jalr_mem_data : jalr_Reg_Data_0;
	assign jalr_reg_in_1 = (jalr_ready_1 & mem_same_1) ? jalr_mem_data : jalr_Reg_Data_1;
	assign jalr_reg_in_2 = (jalr_ready_2 & mem_same_2) ? jalr_mem_data : jalr_Reg_Data_2;
	assign jalr_reg_in_3 = (jalr_ready_3 & mem_same_3) ? jalr_mem_data : jalr_Reg_Data_3;
endmodule