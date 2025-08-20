`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2024/12/22 23:45:41
// Design Name: 
// Module Name: RISCVpipeline
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

// ALUSrc, MemtoReg, RegWrite, MemWrite, ALUOpcode1, ALUOpcode0 sequence
module RISCVpipeline(
	//clock reset
	input clk, reset,
	//multitask, multithread interaction
	input [31:0] core_control_pc,							//core start with this pc
	input core_control_active,								//core start available
	input tasking_or_threading,
	input context_switch_active,							//context switch active
	input [4:0] context_switch_count,						//reg inherit number
	input [31:0] switching_data,							//reg inherit data
	input [7:0] PID_info_in,								//when 'core_control_active', save PID number
	output [7:0] PID_info_out,								//spectate PID number for 'kernel' module
	output multithreading_active, multitasking_active,		//system call
	output [31:0] thread_pc_out,							//system call - pc location
	output [4:0] thread_core_assign_count,					//system call - worker number
	output [31:0] thread_repeat_function_count,				//system call - repeat number
	output [31:0] context_switch_inherit,					//system call - reg number for inherit
	output [4:0] thread_count_num,							//system call - appoint reg number for thread number
	output [991:0] context_switch_reg,						//system call - all data in reg
	output function_finish, thread_finish,
	output [31:0] thread_finish_pc,
	//spectate cycle
	output [31:0] exe_pc_for_count,
	//accelerator interaction
	output [31:0] num1, num2,
	output [1:0] div_rem,
	output div_rem_request,
	input [31:0] result_div_rem,
	input accelerator_ready,
	//L2 Cache interaction
	output read_request, write_request, address_start_end_same,
	output [28:0] address_to_L2,
	output refresh_data_loc,
	output [31:0] refresh_data_to_L2,
	input L2_operate_ready,
	input [63:0] data_from_L2,
	input rewrite_active,
	input [28:0] rewrite_address,
	output trd_mod
	);
	//CoreBase Function prepare
	wire inf_stall, inf_flush;
	wire ind_stall, ind_flush;
	wire exe_stall, exe_flush;
	wire mem_flush;
	//Communication Function prepare
	reg [7:0] PID_info;
	reg tsk_or_trd;
	wire multi_setting_mod;
	//Fetch prepare
	wire [4:0] jalr_rd_0, jalr_rd_1, jalr_rd_2, jalr_rd_3;
	wire jalr_ready_0, jalr_ready_1, jalr_ready_2, jalr_ready_3;
	wire [31:0] jalr_reg_in_0, jalr_reg_in_1, jalr_reg_in_2, jalr_reg_in_3;
	wire [31:0] NT_pc_0, NT_pc_1, NT_pc_2, NT_pc_3, T_pc_0, T_pc_1, T_pc_2, T_pc_3;
	wire [31:0] NT_pc_0_control = (core_control_active) ? core_control_pc : NT_pc_0;
	wire [31:0] inf_ins_0, inf_ins_1, inf_ins_2, inf_ins_3, inf_pc_0, inf_pc_1, inf_pc_2, inf_pc_3;
	//InDecode prepare
	wire [4:0] ind_rs1_read_0, ind_rs1_read_1, ind_rs2_read_0, ind_rs2_read_1;
	wire [4:0] ind_jalr_Rd_0, ind_jalr_Rd_1;
	wire ind_jalr_RW_0, ind_jalr_RW_1;
	wire ind_ctl_0_0, ind_ctl_1_0, ind_ctl_2_0, ind_ctl_3_0, ind_ctl_4_0, ind_ctl_5_0, ind_ctl_0_1, ind_ctl_1_1, ind_ctl_2_1, ind_ctl_3_1, ind_ctl_4_1, ind_ctl_5_1;
	wire [2:0] ind_funct3_0, ind_funct3_1;
	wire [6:0] ind_funct7_0, ind_funct7_1;
	wire [4:0] ind_rd_0, ind_rd_1, ind_rs1_0, ind_rs1_1, ind_rs2_0, ind_rs2_1;
	wire [31:0] ind_pc_0, ind_pc_1;
	wire [31:0] ind_data1_0, ind_data1_1, ind_data2_0, ind_data2_1, ind_imm_0, ind_imm_1;
	wire ind_jump_pc_0, ind_jump_pc_1, ind_branch_0, ind_branch_1, ind_lui_0, ind_lui_1, ind_auipc_0, ind_auipc_1, ind_multrd_0, ind_multrd_1, ind_multsk_0, ind_multsk_1, ind_mulfin_0, ind_mulfin_1;
	wire [31:0] ind_ReadData1_0, ind_ReadData2_0, ind_ReadData1_1, ind_ReadData2_1;
	wire [31:0] jalr_Reg_Data_0, jalr_Reg_Data_1, jalr_Reg_Data_2, jalr_Reg_Data_3;
	//Execution prepare
	wire [4:0] exe_jalr_Rd;
	wire exe_jalr_RW;
	wire exe_ctl_1, exe_ctl_2, exe_ctl_3, exe_multrd, exe_multsk, exe_mulfin;
	wire [4:0] exe_rd;
	wire [31:0] exe_pc;
	wire br_0, br_1, br_2, br_3, br_4, br_5, byte, half, word, exe_unsign, Rs1_branch_need_forward, Rs2_branch_need_forward;
	wire [31:0] exe_result, exe_data1, exe_data2;
	wire exe_stall_forward, exe_stall_div_rem;
	//Memory prepare
	wire [4:0] mem_jalr_Rd;
	wire mem_jalr_RW, mem_jalr_MtR;
	wire taken;
	wire mem_finish_function;
	wire mem_ctl_2;
	wire [4:0] mem_rd;
	wire [31:0] mem_result;
	wire L2_data_wait_stall;
	//WriteBack prepare
	wire wb_ctl_2;
	wire [4:0] wb_rd;
	wire [31:0] wb_data;
	//spectate cycle
	assign exe_pc_for_count = exe_pc;
	//CoreBase Function /////////////////////////////////////////////////////////////////////////////
	Stall_Flush_determine stall_flush_determine(
		.finish_function(function_finish),
		.finish_thread(thread_finish),
		.exe_stall_forward(exe_stall_forward),
		.exe_stall_div_rem(exe_stall_div_rem),
		.L2_data_wait_stall(L2_data_wait_stall),
		.core_control_active(core_control_active),
		.context_switch_active(context_switch_active),
													.inf_stall(inf_stall),
													.inf_flush(inf_flush),
													.ind_stall(ind_stall),
													.ind_flush(ind_flush),
													.exe_stall(exe_stall),
													.exe_flush(exe_flush),
													.mem_flush(mem_flush)
	);
	//Communication Function ////////////////////////////////////////////////////////////////////////
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			PID_info					<= 0;
			tsk_or_trd					<= 0;
		end else begin
			if (core_control_active) begin
				PID_info				<= PID_info_in;
				tsk_or_trd				<= tasking_or_threading;
			end
			if (tsk_or_trd & multithreading_active) begin
				tsk_or_trd				<= 0;
			end
		end
	end
	assign PID_info_out = PID_info;
	assign multi_setting_mod = exe_multrd | exe_multsk;
	assign thread_pc_out = exe_pc;
	assign thread_core_assign_count = exe_rd;
	assign thread_repeat_function_count = exe_data1;
	assign context_switch_inherit = exe_data2;
	assign function_finish = tsk_or_trd & mem_finish_function;
	assign thread_finish = !tsk_or_trd & mem_finish_function;
	assign trd_mod = !tsk_or_trd;
	//Fetch/////////////////////////////////////////////////////////////////////////////////////
	InFetch A1_Core0_InFetch(
		.clk(clk), .reset(reset),
		.taken(taken),
													.jalr_rd(jalr_rd_0),
		.jalr_ready(jalr_ready_0),
		.jalr_reg_in(jalr_reg_in_0),
													.NT_pc_out(NT_pc_0),
													.T_pc_out(T_pc_0),
		.NT_pc_in(NT_pc_0_control),
		.T_pc_in(NT_pc_2),
													.instruction_out(inf_ins_0),
													.PC_out(inf_pc_0),
		.stall(inf_stall),
		.flush(inf_flush)
	);
	InFetch A1_Core1_InFetch(
		.clk(clk), .reset(reset),
		.taken(taken),
													.jalr_rd(jalr_rd_1),
		.jalr_ready(jalr_ready_1),
		.jalr_reg_in(jalr_reg_in_1),
													.NT_pc_out(NT_pc_1),
													.T_pc_out(T_pc_1),
		.NT_pc_in(T_pc_0),
		.T_pc_in(T_pc_2),
													.instruction_out(inf_ins_1),
													.PC_out(inf_pc_1),
		.stall(inf_stall),
		.flush(inf_flush)
	);
	InFetch A1_Core2_InFetch(
		.clk(clk), .reset(reset),
		.taken(taken),
													.jalr_rd(jalr_rd_2),
		.jalr_ready(jalr_ready_2),
		.jalr_reg_in(jalr_reg_in_2),
													.NT_pc_out(NT_pc_2),
													.T_pc_out(T_pc_2),
		.NT_pc_in(NT_pc_1),
		.T_pc_in(NT_pc_3),
													.instruction_out(inf_ins_2),
													.PC_out(inf_pc_2),
		.stall(inf_stall),
		.flush(inf_flush)
	);
	InFetch A1_Core3_InFetch(
		.clk(clk), .reset(reset),
		.taken(taken),
													.jalr_rd(jalr_rd_3),
		.jalr_ready(jalr_ready_3),
		.jalr_reg_in(jalr_reg_in_3),
													.NT_pc_out(NT_pc_3),
													.T_pc_out(T_pc_3),
		.NT_pc_in(T_pc_1),
		.T_pc_in(T_pc_3),
													.instruction_out(inf_ins_3),
													.PC_out(inf_pc_3),
		.stall(inf_stall),
		.flush(inf_flush)
	);
	Jalr_Forwarding_unit A1_Jalr_Forwarding(
		.jalr_rd_0(jalr_rd_0),
		.jalr_rd_1(jalr_rd_1),
		.jalr_rd_2(jalr_rd_2),
		.jalr_rd_3(jalr_rd_3),
		.jalr_ind_rd_0(ind_jalr_Rd_0),
		.jalr_ind_rd_1(ind_jalr_Rd_1),
		.jalr_ind_ctl_0(ind_jalr_RW_0),
		.jalr_ind_ctl_1(ind_jalr_RW_1),
		.jalr_exe_rd(exe_jalr_Rd),
		.jalr_exe_ctl(exe_jalr_RW),
		.jalr_mem_rd(mem_jalr_Rd),
		.jalr_mem_ctl_RW(mem_jalr_RW),
		.jalr_mem_ctl_MtR(mem_jalr_MtR),
		.jalr_mem_data(exe_result),
		.jalr_Reg_Data_0(jalr_Reg_Data_0),
		.jalr_Reg_Data_1(jalr_Reg_Data_1),
		.jalr_Reg_Data_2(jalr_Reg_Data_2),
		.jalr_Reg_Data_3(jalr_Reg_Data_3),
													.jalr_ready_0(jalr_ready_0),
													.jalr_ready_1(jalr_ready_1),
													.jalr_ready_2(jalr_ready_2),
													.jalr_ready_3(jalr_ready_3),
													.jalr_reg_in_0(jalr_reg_in_0),
													.jalr_reg_in_1(jalr_reg_in_1),
													.jalr_reg_in_2(jalr_reg_in_2),
													.jalr_reg_in_3(jalr_reg_in_3)
	);
	//InDecode//////////////////////////////////////////////////////////////////////////////////
	InDecode A2_Core0_InDecode(
		.clk(clk), .reset(reset),
		.taken(taken),
		.PC_in_0(inf_pc_0),
		.PC_in_1(inf_pc_2),
		.instruction_in_0(inf_ins_0),
		.instruction_in_1(inf_ins_2),
													.Rs1(ind_rs1_read_0),
													.Rs2(ind_rs2_read_0),
		.ReadData1_in(ind_ReadData1_0),
		.ReadData2_in(ind_ReadData2_0),
													.jalr_forward_Rd(ind_jalr_Rd_0),
													.jalr_forward_Ctl_RegWrite(ind_jalr_RW_0),
													.Ctl_ALUSrc_out(ind_ctl_0_0),
													.Ctl_MemtoReg_out(ind_ctl_1_0),
													.Ctl_RegWrite_out(ind_ctl_2_0),
													.Ctl_MemWrite_out(ind_ctl_3_0),
													.Ctl_ALUOpcode1_out(ind_ctl_4_0),
													.Ctl_ALUOpcode0_out(ind_ctl_5_0),
													.funct3_out(ind_funct3_0),
													.funct7_out(ind_funct7_0),
													.Rd_out(ind_rd_0),
													.Rs1_out(ind_rs1_0),
													.Rs2_out(ind_rs2_0),
													.PC_out(ind_pc_0),
													.ReadData1_out(ind_data1_0),
													.ReadData2_out(ind_data2_0),
													.Immediate_out(ind_imm_0),
													.jump_pc_out(ind_jump_pc_0),
													.branch_out(ind_branch_0),
													.lui_out(ind_lui_0),
													.auipc_out(ind_auipc_0),
													.multi_thread_set(ind_multrd_0),
													.multi_task_set(ind_multsk_0),
													.finish_function(ind_mulfin_0),
		.stall(ind_stall),
		.flush(ind_flush)
	);
	InDecode A2_Core1_InDecode(
		.clk(clk), .reset(reset),
		.taken(taken),
		.PC_in_0(inf_pc_1),
		.PC_in_1(inf_pc_3),
		.instruction_in_0(inf_ins_1),
		.instruction_in_1(inf_ins_3),
													.Rs1(ind_rs1_read_1),
													.Rs2(ind_rs2_read_1),
		.ReadData1_in(ind_ReadData1_1),
		.ReadData2_in(ind_ReadData2_1),
													.jalr_forward_Rd(ind_jalr_Rd_1),
													.jalr_forward_Ctl_RegWrite(ind_jalr_RW_1),
													.Ctl_ALUSrc_out(ind_ctl_0_1),
													.Ctl_MemtoReg_out(ind_ctl_1_1),
													.Ctl_RegWrite_out(ind_ctl_2_1),
													.Ctl_MemWrite_out(ind_ctl_3_1),
													.Ctl_ALUOpcode1_out(ind_ctl_4_1),
													.Ctl_ALUOpcode0_out(ind_ctl_5_1),
													.funct3_out(ind_funct3_1),
													.funct7_out(ind_funct7_1),
													.Rd_out(ind_rd_1),
													.Rs1_out(ind_rs1_1),
													.Rs2_out(ind_rs2_1),
													.PC_out(ind_pc_1),
													.ReadData1_out(ind_data1_1),
													.ReadData2_out(ind_data2_1),
													.Immediate_out(ind_imm_1),
													.jump_pc_out(ind_jump_pc_1),
													.branch_out(ind_branch_1),
													.lui_out(ind_lui_1),
													.auipc_out(ind_auipc_1),
													.multi_thread_set(ind_multrd_1),
													.multi_task_set(ind_multsk_1),
													.finish_function(ind_mulfin_1),
		.stall(ind_stall),
		.flush(ind_flush)
	);
	Register_unit A2_InDecode_Register(
		.clk(clk), .reset(reset),
		.Ctl_RegWrite_in(wb_ctl_2),
		.WriteReg(wb_rd),
		.WriteData(wb_data),
		.ind_rs1_0(ind_rs1_read_0),					.ind_ReadData1_0(ind_ReadData1_0),
		.ind_rs2_0(ind_rs2_read_0),					.ind_ReadData2_0(ind_ReadData2_0),
		.ind_rs1_1(ind_rs1_read_1),					.ind_ReadData1_1(ind_ReadData1_1),
		.ind_rs2_1(ind_rs2_read_1),					.ind_ReadData2_1(ind_ReadData2_1),
		.jalr_rs_0(jalr_rd_0),						.jalr_ReadData_0(jalr_Reg_Data_0),
		.jalr_rs_1(jalr_rd_1),						.jalr_ReadData_1(jalr_Reg_Data_1),
		.jalr_rs_2(jalr_rd_2),						.jalr_ReadData_2(jalr_Reg_Data_2),
		.jalr_rs_3(jalr_rd_3),						.jalr_ReadData_3(jalr_Reg_Data_3),
		.context_switch_active(context_switch_active),
		.context_switch_count(context_switch_count),
		.switching_data(switching_data),
													.all_reg_data(context_switch_reg)
	);
	//Execution/////////////////////////////////////////////////////////////////////////////////
	Execution A3_Execution(
		.clk(clk), .reset(reset),
		.taken(taken),
		.Ctl_ALUSrc_in_0(ind_ctl_0_0 & !multi_setting_mod),
		.Ctl_ALUSrc_in_1(ind_ctl_0_1 & !multi_setting_mod),
		.Ctl_MemtoReg_in_0(ind_ctl_1_0 & !multi_setting_mod),
		.Ctl_MemtoReg_in_1(ind_ctl_1_1 & !multi_setting_mod),
		.Ctl_RegWrite_in_0(ind_ctl_2_0 & !multi_setting_mod),
		.Ctl_RegWrite_in_1(ind_ctl_2_1 & !multi_setting_mod),
		.Ctl_MemWrite_in_0(ind_ctl_3_0 & !multi_setting_mod),
		.Ctl_MemWrite_in_1(ind_ctl_3_1 & !multi_setting_mod),
		.Ctl_ALUOpcode1_in_0(ind_ctl_4_0 & !multi_setting_mod),
		.Ctl_ALUOpcode1_in_1(ind_ctl_4_1 & !multi_setting_mod),
		.Ctl_ALUOpcode0_in_0(ind_ctl_5_0 & !multi_setting_mod),
		.Ctl_ALUOpcode0_in_1(ind_ctl_5_1 & !multi_setting_mod),
		.funct3_0(ind_funct3_0),
		.funct3_1(ind_funct3_1),
		.Rd_in_0(ind_rd_0),
		.Rd_in_1(ind_rd_1),
		.Rs1_in_0(ind_rs1_0),
		.Rs1_in_1(ind_rs1_1),
		.Rs2_in_0(ind_rs2_0),
		.Rs2_in_1(ind_rs2_1),
		.funct7_in_0(ind_funct7_0),
		.funct7_in_1(ind_funct7_1),
		.ReadData1_in_0(ind_data1_0),
		.ReadData1_in_1(ind_data1_1),
		.ReadData2_in_0(ind_data2_0),
		.ReadData2_in_1(ind_data2_1),
		.Immediate_in_0(ind_imm_0),
		.Immediate_in_1(ind_imm_1),
		.PC_in_0(ind_pc_0),
		.PC_in_1(ind_pc_1),
		.jump_pc_in_0(ind_jump_pc_0),
		.jump_pc_in_1(ind_jump_pc_1),
		.branch_in_0(ind_branch_0),
		.branch_in_1(ind_branch_1),
		.lui_in_0(ind_lui_0),
		.lui_in_1(ind_lui_1),
		.auipc_in_0(ind_auipc_0),
		.auipc_in_1(ind_auipc_1),
		.multi_thread_set_0(ind_multrd_0),
		.multi_thread_set_1(ind_multrd_1),
		.multi_task_set_0(ind_multsk_0),
		.multi_task_set_1(ind_multsk_1),
		.finish_function_0(ind_mulfin_0),
		.finish_function_1(ind_mulfin_1),
		.exe_Ctl_MemtoReg_in(exe_ctl_1),
		.exe_Ctl_RegWrite_in(exe_ctl_2),
		.mem_Ctl_RegWrite_in(mem_ctl_2),
		.exe_Rd_in(exe_rd),
		.mem_Rd_in(mem_rd),
		.exe_forward_data(exe_result),
		.mem_forward_data(mem_result),
													.acc_in_A(num1),
													.acc_in_B(num2),
													.div_rem_order(div_rem),
													.div_rem_order_active(div_rem_request),
		.div_rem_ready(accelerator_ready),
		.div_rem_result(result_div_rem),
													.jalr_forward_Rd(exe_jalr_Rd),
													.jalr_forward_Ctl_RegWrite(exe_jalr_RW),
													.Ctl_MemtoReg_out(exe_ctl_1),
													.Ctl_RegWrite_out(exe_ctl_2),
													.Ctl_MemWrite_out(exe_ctl_3),
													.multi_thread_set_out(exe_multrd),
													.multi_task_set_out(exe_multsk),
													.finish_function_out(exe_mulfin),
													.Rd_out(exe_rd),
													.PC_out(exe_pc),
													.br_0(br_0),
													.br_1(br_1),
													.br_2(br_2),
													.br_3(br_3),
													.br_4(br_4),
													.br_5(br_5),
													.byte(byte),
													.half(half),
													.word(word),
													.unsign(exe_unsign),
													.Rs1_branch_need_forward(Rs1_branch_need_forward),
													.Rs2_branch_need_forward(Rs2_branch_need_forward),
													.thread_operate_num(thread_count_num),
													.ALUresult_out(exe_result),
													.ReadData1_out(exe_data1),
													.ReadData2_out(exe_data2),
		.stall(exe_stall),
													.stall_mem_to_exe(exe_stall_forward),
													.div_rem_wait_stall(exe_stall_div_rem),
		.flush(exe_flush)
	);
	//Memory////////////////////////////////////////////////////////////////////////////////////
	Memory A4_Memory(
		.clk(clk), .reset(reset),
		.mem_forward_data(mem_result),				.taken(taken),
		.br_0(br_0),
		.br_1(br_1),
		.br_2(br_2),
		.br_3(br_3),
		.br_4(br_4),
		.br_5(br_5),
		.byte(byte),
		.half(half),
		.word(word),
		.unsign(exe_unsign),
		.Rs1_branch_forward(Rs1_branch_need_forward),
		.Rs2_branch_forward(Rs2_branch_need_forward),
		.Ctl_MemtoReg_in(exe_ctl_1),
		.Ctl_RegWrite_in(exe_ctl_2),
		.Ctl_MemWrite_in(exe_ctl_3),
		.multi_thread_set_in(exe_multrd),
		.multi_task_set_in(exe_multsk),
		.finish_function_in(exe_mulfin),
		.Rd_in(exe_rd),
		.ALUresult_in(exe_result),
		.ReadData1(exe_data1),
		.ReadData2(exe_data2),
		.PC_in(exe_pc),
													.jalr_forward_Rd(mem_jalr_Rd),
													.jalr_forward_Ctl_RegWrite(mem_jalr_RW),
													.jalr_forward_Ctl_MemtoReg(mem_jalr_MtR),
													.read_request_active(read_request),
													.write_request_active(write_request),
													.address_start_end_same(address_start_end_same),
													.address_to_L2(address_to_L2),
													.refresh_data_loc(refresh_data_loc),
													.refresh_data_to_L2(refresh_data_to_L2),
		.L2_operate_ready(L2_operate_ready),
		.data_from_L2(data_from_L2),
		.rewrite_active(rewrite_active),
		.rewrite_address(rewrite_address),
													.thread_finish_pc(thread_finish_pc),
													.multi_thread_set_out(multithreading_active),
													.multi_task_set_out(multitasking_active),
													.finish_function_out(mem_finish_function),
													.Ctl_RegWrite_out(mem_ctl_2),
													.Rd_out(mem_rd),
													.MEMresult_out(mem_result),
													.wait_L2_data_stall(L2_data_wait_stall),
		.flush(mem_flush)
	);
	//WriteBack/////////////////////////////////////////////////////////////////////////////////
	WriteBack A5_WriteBack(
		.Ctl_RegWrite_in(mem_ctl_2),
		.Rd_in(mem_rd),
		.MEMresult_in(mem_result),
													.Ctl_RegWrite_out(wb_ctl_2),
													.Rd_out(wb_rd),
													.WriteDatatoReg_out(wb_data)
	);
endmodule