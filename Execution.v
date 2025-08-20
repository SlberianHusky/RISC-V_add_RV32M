`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/01 22:21:20
// Design Name: 
// Module Name: Execution
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


module Execution(
	//clock reset
	input clk, reset,
	//taken signal from memory stage
	input taken,
	//input from InDecode
	input Ctl_ALUSrc_in_0, Ctl_MemtoReg_in_0, Ctl_RegWrite_in_0, Ctl_MemWrite_in_0, Ctl_ALUOpcode1_in_0, Ctl_ALUOpcode0_in_0, Ctl_ALUSrc_in_1, Ctl_MemtoReg_in_1, Ctl_RegWrite_in_1, Ctl_MemWrite_in_1, Ctl_ALUOpcode1_in_1, Ctl_ALUOpcode0_in_1,
	input [2:0] funct3_0, funct3_1,
	input [4:0] Rd_in_0, Rs1_in_0, Rs2_in_0, Rd_in_1, Rs1_in_1, Rs2_in_1,
	input [6:0] funct7_in_0, funct7_in_1,
	input [31:0] ReadData1_in_0, ReadData2_in_0, Immediate_in_0, ReadData1_in_1, ReadData2_in_1, Immediate_in_1, PC_in_0, PC_in_1,
	input jump_pc_in_0, branch_in_0, lui_in_0, auipc_in_0, jump_pc_in_1, branch_in_1, lui_in_1, auipc_in_1,
	input multi_thread_set_0, multi_task_set_0, finish_function_0, multi_thread_set_1, multi_task_set_1, finish_function_1,
	//input Forwarding
	input exe_Ctl_MemtoReg_in, exe_Ctl_RegWrite_in, mem_Ctl_RegWrite_in,
	input [4:0] exe_Rd_in, mem_Rd_in,
	input [31:0] exe_forward_data, mem_forward_data,
	//div_rem interaction
	output [31:0] acc_in_A, acc_in_B,
	output [1:0] div_rem_order,
	output div_rem_order_active,
	input div_rem_ready,
	input [31:0] div_rem_result,
	//for jalr_forward
	output [4:0] jalr_forward_Rd,
	output jalr_forward_Ctl_RegWrite,
	//pass(To Memory)
	output reg Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemWrite_out, multi_thread_set_out, multi_task_set_out, finish_function_out,
	output reg [4:0] Rd_out,
	output reg [31:0] PC_out,
	//Execution result(To Memory)
	output reg br_0, br_1, br_2, br_3, br_4, br_5, byte, half, word, unsign, Rs1_branch_need_forward, Rs2_branch_need_forward,
	output reg [4:0] thread_operate_num,
	output reg [31:0] ALUresult_out, ReadData1_out, ReadData2_out,
	//stall
	input stall,
	output stall_mem_to_exe, div_rem_wait_stall,
	//flush
	input flush
	);
	reg previous_taken;
	reg previous_stall;
	wire real_taken = previous_stall ? previous_taken : taken;
	//MUX module ////////////////////////////////////////////////////////////////////////////////////////////
	wire Ctl_ALUSrc_in = (real_taken) ? Ctl_ALUSrc_in_1 : Ctl_ALUSrc_in_0;
	wire Ctl_MemtoReg_in = (real_taken) ? Ctl_MemtoReg_in_1 : Ctl_MemtoReg_in_0;
	wire Ctl_RegWrite_in = (real_taken) ? Ctl_RegWrite_in_1 : Ctl_RegWrite_in_0;
	wire Ctl_MemWrite_in = (real_taken) ? Ctl_MemWrite_in_1 : Ctl_MemWrite_in_0;
	wire Ctl_ALUOpcode1_in = (real_taken) ? Ctl_ALUOpcode1_in_1 : Ctl_ALUOpcode1_in_0;
	wire Ctl_ALUOpcode0_in = (real_taken) ? Ctl_ALUOpcode0_in_1 : Ctl_ALUOpcode0_in_0;
	wire [2:0] funct3 = (real_taken) ? funct3_1 : funct3_0;
	wire [4:0] Rd_in = (real_taken) ? Rd_in_1 : Rd_in_0;
	wire [4:0] Rs1_in = (real_taken) ? Rs1_in_1 : Rs1_in_0;
	wire [4:0] Rs2_in = (real_taken) ? Rs2_in_1 : Rs2_in_0;
	wire [6:0] funct7 = (real_taken) ? funct7_in_1 : funct7_in_0;
	wire [31:0] ReadData1_in = (real_taken) ? ReadData1_in_1 : ReadData1_in_0;
	wire [31:0] ReadData2_in = (real_taken) ? ReadData2_in_1 : ReadData2_in_0;
	wire [31:0] Immediate_in = (real_taken) ? Immediate_in_1 : Immediate_in_0;
	wire [31:0] PC_in = (real_taken) ? PC_in_1 : PC_in_0;
	wire jump_pc_in = (real_taken) ? jump_pc_in_1 : jump_pc_in_0;
	wire branch_in = (real_taken) ? branch_in_1 : branch_in_0;
	wire lui_in = (real_taken) ? lui_in_1 : lui_in_0;
	wire auipc_in = (real_taken) ? auipc_in_1 : auipc_in_0;
	wire multi_thread_set = (real_taken) ? multi_thread_set_1 : multi_thread_set_0;
	wire multi_task_set = (real_taken) ? multi_task_set_1 : multi_task_set_0;
	wire finish_function = (real_taken) ? finish_function_1 : finish_function_0;
	//branch prepare ////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] pc_save = PC_in + 4;
	wire byte_in = (funct3 == 3'b000);
	wire half_in = (funct3 == 3'b001);
	wire word_in = (funct3 == 3'b010);
	wire branch_0 = byte_in & branch_in;
	wire branch_1 = half_in & branch_in;
	wire branch_2 = (funct3 == 3'b100) & branch_in;
	wire branch_3 = (funct3 == 3'b101) & branch_in;
	wire branch_4 = (funct3 == 3'b110) & branch_in;
	wire branch_5 = (funct3 == 3'b111) & branch_in;
	//Forwarding module /////////////////////////////////////////////////////////////////////////////////////
	reg [31:0] forwardA_temp, forwardB_temp;
	wire exe_Rs1_same_nonzero = ((exe_Rd_in == Rs1_in) && (Rs1_in != 0) && exe_Ctl_RegWrite_in);
	wire exe_Rs2_same_nonzero = ((exe_Rd_in == Rs2_in) && (Rs2_in != 0) && exe_Ctl_RegWrite_in);
	wire mem_Rs1_same_nonzero = ((mem_Rd_in == Rs1_in) && (Rs1_in != 0) && mem_Ctl_RegWrite_in);
	wire mem_Rs2_same_nonzero = ((mem_Rd_in == Rs2_in) && (Rs2_in != 0) && mem_Ctl_RegWrite_in);
	wire [31:0] forwardA_now = (exe_Rs1_same_nonzero) ? (exe_forward_data) : ((mem_Rs1_same_nonzero) ? (mem_forward_data) : (ReadData1_in));
	wire [31:0] forwardB_now = (exe_Rs2_same_nonzero) ? (exe_forward_data) : ((mem_Rs2_same_nonzero) ? (mem_forward_data) : (ReadData2_in));
	wire [31:0] forwardA = previous_stall ? forwardA_temp : forwardA_now;
	wire [31:0] forwardB = previous_stall ? forwardB_temp : forwardB_now;
	assign stall_mem_to_exe = (exe_Rs1_same_nonzero | (exe_Rs2_same_nonzero & ((!Ctl_ALUSrc_in) | (!Ctl_MemWrite_in)))) & exe_Ctl_MemtoReg_in & (!branch_in);
	wire Rs1_branch_forward = exe_Rs1_same_nonzero & branch_in;
	wire Rs2_branch_forward = exe_Rs2_same_nonzero & (Ctl_MemWrite_in | branch_in);
	always @(posedge clk, negedge  reset) begin
		if(!reset) begin
			forwardA_temp			<= 0;
			forwardB_temp			<= 0;
		end else begin
			if (!previous_stall) begin
				forwardA_temp				<= forwardA_now;
				forwardB_temp				<= forwardB_now;
			end
		end
	end
	//ALU_Control module ////////////////////////////////////////////////////////////////////////////////////
	wire [3:0] ALU_ctl;
	assign ALU_ctl[3] = (funct3[1:0] == 2'b01) && ((Ctl_ALUOpcode1_in && Ctl_ALUSrc_in) || (~Ctl_ALUSrc_in));
	assign ALU_ctl[2] = (((funct3[2:1] == 2'b01) || (funct3[2:0] == 3'b100)) && (~Ctl_ALUSrc_in + Ctl_ALUOpcode0_in)) || (~Ctl_ALUSrc_in && funct7[5] && ~funct3[0]);
	assign ALU_ctl[1] = (Ctl_ALUSrc_in && ~Ctl_ALUOpcode1_in) || (~funct3[2] && (funct3[1] || ~funct3[0])) || (funct3 == 3'b101);
	assign ALU_ctl[0] = ((~funct3[2] && funct3[0]) || (funct3[1] && ~funct3[0])) && (~Ctl_ALUSrc_in || Ctl_ALUOpcode1_in);
	//mul module ////////////////////////////////////////////////////////////////////////////////////////////
	wire exe_Rs1_same_nonzero_0 = ((exe_Rd_in == Rs1_in_0) && (Rs1_in_0 != 0) && exe_Ctl_RegWrite_in);
	wire exe_Rs2_same_nonzero_0 = ((exe_Rd_in == Rs2_in_0) && (Rs2_in_0 != 0) && exe_Ctl_RegWrite_in);
	wire mem_Rs1_same_nonzero_0 = ((mem_Rd_in == Rs1_in_0) && (Rs1_in_0 != 0) && mem_Ctl_RegWrite_in);
	wire mem_Rs2_same_nonzero_0 = ((mem_Rd_in == Rs2_in_0) && (Rs2_in_0 != 0) && mem_Ctl_RegWrite_in);
	wire exe_Rs1_same_nonzero_1 = ((exe_Rd_in == Rs1_in_1) && (Rs1_in_1 != 0) && exe_Ctl_RegWrite_in);
	wire exe_Rs2_same_nonzero_1 = ((exe_Rd_in == Rs2_in_1) && (Rs2_in_1 != 0) && exe_Ctl_RegWrite_in);
	wire mem_Rs1_same_nonzero_1 = ((mem_Rd_in == Rs1_in_1) && (Rs1_in_1 != 0) && mem_Ctl_RegWrite_in);
	wire mem_Rs2_same_nonzero_1 = ((mem_Rd_in == Rs2_in_1) && (Rs2_in_1 != 0) && mem_Ctl_RegWrite_in);
	wire [31:0] mul_in_A_0 = previous_stall ? forwardA_temp : ((exe_Rs1_same_nonzero_0) ? (exe_forward_data) : ((mem_Rs1_same_nonzero_0) ? (mem_forward_data) : ReadData1_in_0));
	wire [31:0] mul_in_A_1 = previous_stall ? forwardA_temp : ((exe_Rs1_same_nonzero_1) ? (exe_forward_data) : ((mem_Rs1_same_nonzero_1) ? (mem_forward_data) : ReadData1_in_1));
	wire [31:0] mul_in_B_0 = previous_stall ? forwardB_temp : ((exe_Rs2_same_nonzero_0) ? (exe_forward_data) : ((mem_Rs2_same_nonzero_0) ? (mem_forward_data) : ReadData2_in_0));
	wire [31:0] mul_in_B_1 = previous_stall ? forwardB_temp : ((exe_Rs2_same_nonzero_1) ? (exe_forward_data) : ((mem_Rs2_same_nonzero_1) ? (mem_forward_data) : ReadData2_in_1));
	wire sign_A_0 = (funct3_0[1:0] == 2'b11) ? 0 : mul_in_A_0[31];
	wire sign_A_1 = (funct3_1[1:0] == 2'b11) ? 0 : mul_in_A_1[31];
	wire sign_B_0 = funct3_0[1] ? 0 : mul_in_B_0[31];
	wire sign_B_1 = funct3_1[1] ? 0 : mul_in_B_1[31];
	wire [65:0] mul_mid_0 = ({sign_A_0,mul_in_A_0}) * ({sign_B_0,mul_in_B_0});
	wire [65:0] mul_mid_1 = ({sign_A_1,mul_in_A_1}) * ({sign_B_1,mul_in_B_1});
	wire high = (funct3[1:0] != 2'b00);
	wire [63:0] mul_mid = real_taken ? mul_mid_1[63:0] : mul_mid_0[63:0];
	wire [31:0] mul_result = high ? mul_mid[63:32] : mul_mid[31:0];
	//mul_div_rem determine /////////////////////////////////////////////////////////////////////////////////
	wire mul_div = !Ctl_ALUSrc_in & funct7[0] & !branch_in;
	wire mul = mul_div && (~funct3[2]);
	assign div_rem_order_active = mul_div && (funct3[2]);
	assign div_rem_wait_stall = div_rem_order_active && (~div_rem_ready);
	//prepare ALU_input /////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] ALU_input_A = lui_in ? 0 : ((auipc_in) ? PC_in : forwardA);
	wire [31:0] ALU_input_B = Ctl_ALUSrc_in ? Immediate_in : forwardB;
	wire in_unsign = ((ALU_ctl[2:0] == 3'b111) && funct3[0]) || ((ALU_ctl[3:1] == 3'b101) && ~funct7[6]);
	wire ALU_sign_A = in_unsign ? 0 : ALU_input_A[31];
	wire ALU_sign_B = in_unsign ? 0 : ALU_input_B[31];
	wire [32:0] ALU_input_1 = ({ALU_sign_A,ALU_input_A});
	wire [32:0] ALU_input_2 = ({ALU_sign_B,ALU_input_B});
	reg [32:0] alu_ans;
	//ALU module ////////////////////////////////////////////////////////////////////////////////////////////
	always @(*) begin
		case (ALU_ctl)
			4'b0010 : alu_ans = ALU_input_1 + ALU_input_2;
			4'b0110 : alu_ans = ALU_input_1 - ALU_input_2;
			4'b0111 : alu_ans = (ALU_input_1 < ALU_input_2);
			4'b1001 : alu_ans = ALU_input_1 << ALU_input_2[4:0];
			4'b1010 : alu_ans = ALU_input_1 >>> ALU_input_2[4:0];
			4'b0100 : alu_ans = ALU_input_1 ^ ALU_input_2;
			4'b0001 : alu_ans = ALU_input_1 | ALU_input_2;
			4'b0000 : alu_ans = ALU_input_1 & ALU_input_2;
			default : alu_ans = 33'b0;
		endcase
	end
	//for Jalr_forward //////////////////////////////////////////////////////////////////////////////////////
	assign jalr_forward_Rd = Rd_in;
	assign jalr_forward_Ctl_RegWrite = Ctl_RegWrite_in;
	//div_rem request ///////////////////////////////////////////////////////////////////////////////////////
	assign acc_in_A = ALU_input_A;
	assign acc_in_B = ALU_input_B;
	assign div_rem_order = funct3[1:0];
	//finish_Execution_stage ////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk, negedge reset) begin
		if(!reset) begin
			multi_thread_set_out			<= 0;
			multi_task_set_out				<= 0;
			finish_function_out				<= 0;
			Ctl_MemtoReg_out				<= 0;
			Ctl_RegWrite_out				<= 0;
			Ctl_MemWrite_out				<= 0;
			Rd_out							<= 0;
			PC_out							<= 0;
			br_0							<= 0;
			br_1							<= 0;
			br_2							<= 0;
			br_3							<= 0;
			br_4							<= 0;
			br_5							<= 0;
			byte							<= 0;
			half							<= 0;
			word							<= 0;
			unsign							<= 0;
			Rs1_branch_need_forward			<= 0;
			Rs2_branch_need_forward			<= 0;
			thread_operate_num				<= 0;
			ALUresult_out					<= 0;
			ReadData1_out					<= 0;
			ReadData2_out					<= 0;
			previous_taken					<= 0;
			previous_stall					<= 0;
		end else begin
			if (!previous_stall) begin
				previous_taken				<= taken;
			end
			previous_stall					<= stall | stall_mem_to_exe | div_rem_wait_stall;
			if (!stall) begin
				multi_thread_set_out		<= flush ? 0 : multi_thread_set;
				multi_task_set_out			<= flush ? 0 : multi_task_set;
				finish_function_out			<= flush ? 0 : finish_function;
				Ctl_MemtoReg_out			<= flush ? 0 : Ctl_MemtoReg_in;
				Ctl_RegWrite_out			<= flush ? 0 : Ctl_RegWrite_in;
				Ctl_MemWrite_out			<= flush ? 0 : Ctl_MemWrite_in;
				Rd_out						<= Rd_in;
				PC_out						<= PC_in;
				br_0						<= flush ? 0 : branch_0;
				br_1						<= flush ? 0 : branch_1;
				br_2						<= flush ? 0 : branch_2;
				br_3						<= flush ? 0 : branch_3;
				br_4						<= flush ? 0 : branch_4;
				br_5						<= flush ? 0 : branch_5;
				byte						<= flush ? 0 : byte_in;
				half						<= flush ? 0 : half_in;
				word						<= flush ? 0 : word_in;
				unsign						<= flush ? 0 : funct3[2];
				Rs1_branch_need_forward		<= flush ? 0 : Rs1_branch_forward;
				Rs2_branch_need_forward		<= flush ? 0 : Rs2_branch_forward;
				thread_operate_num			<= Immediate_in[31:27];
				ALUresult_out				<= mul ? mul_result : (jump_pc_in ? pc_save : (div_rem_order_active ? div_rem_result : alu_ans[31:0]));
				ReadData1_out				<= forwardA;
				ReadData2_out				<= forwardB;
			end
		end
	end
endmodule