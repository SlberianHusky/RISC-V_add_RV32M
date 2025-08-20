`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2024/12/23 05:59:40
// Design Name: 
// Module Name: InDecode
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


module InDecode(
	//clock reset
	input clk, reset,
	//taken signal from memory stage
	input taken,
	//input from InFetch
	input [31:0] PC_in_0, PC_in_1,
	input [31:0] instruction_in_0, instruction_in_1,
	//information from Register module
	output [4:0] Rs1, Rs2,
	input [31:0] ReadData1_in, ReadData2_in,
	//for jalr_forward
	output [4:0] jalr_forward_Rd,
	output jalr_forward_Ctl_RegWrite,
	//pass(To Execution)
	output reg [31:0] PC_out,
	//InDecode result(To Execution)
	output reg Ctl_ALUSrc_out, Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemWrite_out, Ctl_ALUOpcode1_out, Ctl_ALUOpcode0_out,
	output reg [2:0] funct3_out,
	output reg [4:0] Rd_out, Rs1_out, Rs2_out,
	output reg [6:0] funct7_out,
	output reg [31:0] ReadData1_out, ReadData2_out, Immediate_out,
	output reg jump_pc_out, branch_out, lui_out, auipc_out,
	output reg multi_thread_set, multi_task_set, finish_function,
	//stall
	input stall,
	//flush
	input flush
	);
	reg previous_taken;
	reg previous_stall;
	wire real_taken = previous_stall ? previous_taken : taken;
	//MUX module ////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] PC_in = (real_taken) ? PC_in_1 : PC_in_0;
	wire [31:0] instruction_in = (real_taken) ? instruction_in_1 : instruction_in_0;
	//Decoding //////////////////////////////////////////////////////////////////////////////////////////////
	wire [4:0] opcode = instruction_in[6:2];
	wire [6:0] funct7 = instruction_in[31:25];
	wire [2:0] funct3 = instruction_in[14:12];
	wire [4:0] Rd = instruction_in[11:7];
	assign Rs1 = instruction_in[19:15];
	assign Rs2 = instruction_in[24:20];
	wire [31:0] I_imm = ({{20{instruction_in[31]}},instruction_in[31:20]});
	wire [31:0] S_imm = ({{20{instruction_in[31]}},instruction_in[31:25],instruction_in[11:7]});
	wire [31:0] U_imm = ({instruction_in[31:12],12'b0});
	//multithreading, multitasking detect ///////////////////////////////////////////////////////////////////
	wire multi_thread = (opcode == 5'b11100) && (~instruction_in[20]);				//ecall
	wire multi_task = (opcode == 5'b00011);											//fence
	wire finish_function_detect = (opcode == 5'b11100) && (instruction_in[20]);		//ebreak (use both)
	//control_signal module /////////////////////////////////////////////////////////////////////////////////
	wire [5:0] Ctl_out;
	assign Ctl_out[0] = (((opcode[0] | !opcode[2]) & !opcode[4]) | opcode[1] | (opcode[2] & !opcode[3])) & (instruction_in[1:0] == 2'b11);
	assign Ctl_out[1] = (opcode == 5'b00000) & (instruction_in[1:0] == 2'b11);
	assign Ctl_out[2] = opcode[0] | !opcode[3] | (opcode[2] & !opcode[4]) & (instruction_in[1:0] == 2'b11);
	assign Ctl_out[3] = (opcode == 5'b01000) & (instruction_in[1:0] == 2'b11);
	assign Ctl_out[4] = !opcode[4] & (opcode[2:0] == 3'b100) & (instruction_in[1:0] == 2'b11);
	assign Ctl_out[5] = (opcode == 5'b00100) & (instruction_in[1:0] == 2'b11);
	wire jump_pc = (opcode[4:2] == 3'b110) & opcode[0];
	wire branch = (opcode == 5'b11000);
	wire lui_detect = (opcode == 5'b01101);
	wire auipc_detect = (opcode == 5'b00101);
	//Imm module ////////////////////////////////////////////////////////////////////////////////////////////
	wire I_type = (~opcode[4]) & (~opcode[3]) & (~opcode[1]) & (~opcode[0]);
	wire [31:0] Immediate = (Ctl_out[3]) ? S_imm : (I_type ? I_imm : U_imm);
	//for Jalr_forward //////////////////////////////////////////////////////////////////////////////////////
	assign jalr_forward_Rd = Rd;
	assign jalr_forward_Ctl_RegWrite = Ctl_out[3];
	//finish_InDecode_stage /////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk, negedge reset) begin
		if((!reset) | flush) begin
			Ctl_ALUSrc_out				<= 0;
			Ctl_MemtoReg_out			<= 0;
			Ctl_RegWrite_out			<= 0;
			Ctl_MemWrite_out			<= 0;
			Ctl_ALUOpcode1_out			<= 0;
			Ctl_ALUOpcode0_out			<= 0;
			funct3_out					<= 0;
			funct7_out					<= 0;
			Rd_out						<= 0;
			Rs1_out						<= 0;
			Rs2_out						<= 0;
			PC_out						<= 0;
			ReadData1_out				<= 0;
			ReadData2_out				<= 0;
			Immediate_out				<= 0;
			jump_pc_out					<= 0;
			branch_out					<= 0;
			lui_out						<= 0;
			auipc_out					<= 0;
			multi_thread_set			<= 0;
			multi_task_set				<= 0;
			finish_function				<= 0;
			previous_taken				<= 0;
			previous_stall				<= 0;
		end else begin
			if (!previous_stall) begin
				previous_taken			<= taken;
			end
			previous_stall				<= stall;
			if (!stall) begin
				Ctl_ALUSrc_out			<= Ctl_out[0];
				Ctl_MemtoReg_out		<= Ctl_out[1];
				Ctl_RegWrite_out		<= Ctl_out[2];
				Ctl_MemWrite_out		<= Ctl_out[3];
				Ctl_ALUOpcode1_out		<= Ctl_out[4];
				Ctl_ALUOpcode0_out		<= Ctl_out[5];
				funct3_out				<= funct3;
				funct7_out				<= funct7;
				Rd_out					<= Rd;
				Rs1_out					<= Rs1;
				Rs2_out					<= Rs2;
				PC_out					<= PC_in;
				ReadData1_out			<= ReadData1_in;
				ReadData2_out			<= ReadData2_in;
				Immediate_out			<= Immediate;
				jump_pc_out				<= jump_pc;
				branch_out				<= branch;
				lui_out					<= lui_detect;
				auipc_out				<= auipc_detect;
				multi_thread_set		<= multi_thread;
				multi_task_set			<= multi_task;
				finish_function			<= finish_function_detect;
			end
		end
	end
endmodule