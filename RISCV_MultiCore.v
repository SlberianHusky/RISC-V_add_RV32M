`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2024/12/22 23:45:03
// Design Name: 
// Module Name: RISCV_MultiCore
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
//`define FPGA_MOD

module RISCV_MultiCore(
	input key,
	input [15:0] DIP_SW,
	output [7:0] digit,
	output [7:0] fnd,
	output [15:0] LED,
	input clk, reset
	);
	//Core clock cycle test================================================================================================================
	wire [31:0] exe_pc_0, exe_pc_1, exe_pc_2, exe_pc_3;
`ifdef FPGA_MOD
	wire clk_out;
	wire clk_inter = clk_out;
`else
	wire clk_inter = clk;
`endif
	//spectate context switch////////////////////////////////////////////////////////////////////////////////
	reg [31:0] cycle_counter;
	reg r_stop_counter;
	wire stop_counter = ((exe_pc_0 == 32'hc8) | (exe_pc_1 == 32'hc8) | (exe_pc_2 == 32'hc8) | (exe_pc_3 == 32'hc8));
	wire [31:0] clk_count;
	assign 	LED = r_stop_counter ? 16'hffff : 16'h0000;
	always @(posedge clk_inter, negedge reset) begin
		if(!reset) begin
			r_stop_counter <= 0;
		end else begin
			r_stop_counter <= stop_counter ? 1 : r_stop_counter;
		end
	end
	always @(posedge clk_inter, negedge reset) begin
		if(!reset) begin
			cycle_counter <=0;
		end else begin
			cycle_counter <= ((exe_pc_0 >= 32'h10c) | (exe_pc_1 >= 32'h10c) | (exe_pc_2 >= 32'h10c) | (exe_pc_3 >= 32'h10c)) ? cycle_counter + 1 : cycle_counter;
		end
	end
`ifdef FPGA_MOD
	wire [2:0] LED_clk;
	LED_channel LED0(
		.data(led_out),					.digit(digit),
		.LED_clk(LED_clk),				.fnd(fnd)
		);
	counter A0_counter(
		.key1(key),
		.sw(DIP_SW),
		.clk(clk),						.LED_clk(LED_clk),
		.rst(reset),						.clk_out(clk_out),
		.pc_in(ind_pc)
		);
`endif
	//Core clock cycle test================================================================================================================
	//core <-> OS_Kernel interact
	wire [3:0] core_activate_state;
	wire [31:0] core_start_pc_0, core_start_pc_1, core_start_pc_2, core_start_pc_3;
	wire core_activate_0, core_activate_1, core_activate_2, core_activate_3;
	wire tsk_or_trd_0, tsk_or_trd_1, tsk_or_trd_2, tsk_or_trd_3;
	wire context_switch_mv_data_0, context_switch_mv_data_1, context_switch_mv_data_2, context_switch_mv_data_3;
	wire [4:0] context_switch_count_0, context_switch_count_1, context_switch_count_2, context_switch_count_3;
	wire [31:0] switching_data_0, switching_data_1, switching_data_2, switching_data_3;
	wire [7:0] PID_in_0, PID_in_1, PID_in_2, PID_in_3;
	wire [7:0] PID_out_0, PID_out_1, PID_out_2, PID_out_3;
	wire multithread_active_0, multithread_active_1, multithread_active_2, multithread_active_3;
	wire multitask_active_0, multitask_active_1, multitask_active_2, multitask_active_3;
	wire [31:0] trd_start_pc_0, trd_start_pc_1, trd_start_pc_2, trd_start_pc_3;
	wire [4:0] core_assign_num_0, core_assign_num_1, core_assign_num_2, core_assign_num_3;
	wire [31:0] repeat_function_num_0, repeat_function_num_1, repeat_function_num_2, repeat_function_num_3;
	wire [31:0] register_inherit_0, register_inherit_1, register_inherit_2, register_inherit_3;
	wire [4:0] thread_function_num_0, thread_function_num_1, thread_function_num_2, thread_function_num_3;
	wire [991:0] context_switch_all_reg_0, context_switch_all_reg_1, context_switch_all_reg_2, context_switch_all_reg_3;
	wire function_finish_0, function_finish_1, function_finish_2, function_finish_3;
	wire thread_finish_0, thread_finish_1, thread_finish_2, thread_finish_3;
	wire [31:0] thread_finish_pc_0, thread_finish_pc_1, thread_finish_pc_2, thread_finish_pc_3;
	wire [31:0] acc_A_0, acc_A_1, acc_A_2, acc_A_3, acc_B_0, acc_B_1, acc_B_2, acc_B_3;
	wire [1:0] div_rem_ctl_0, div_rem_ctl_1, div_rem_ctl_2, div_rem_ctl_3;
	wire div_rem_request_0, div_rem_request_1, div_rem_request_2, div_rem_request_3;
	//core <-> L2 Cache interact
	wire read_request_0, read_request_1, read_request_2, read_request_3;
	wire write_request_0, write_request_1, write_request_2, write_request_3;
	wire start_end_same_0, start_end_same_1, start_end_same_2, start_end_same_3;
	wire [28:0] address_0, address_1, address_2, address_3;
	wire refresh_loc_0, refresh_loc_1, refresh_loc_2, refresh_loc_3;
	wire [31:0] refresh_data_0, refresh_data_1, refresh_data_2, refresh_data_3;
	wire L2_ready_0, L2_ready_1, L2_ready_2, L2_ready_3;
	wire [63:0] read_data_0, read_data_1, read_data_2, read_data_3;
	wire rewrite_active_0, rewrite_active_1, rewrite_active_2, rewrite_active_3;
	wire [28:0] rewrite_address_0, rewrite_address_1, rewrite_address_2, rewrite_address_3;
	wire trd_mod_0, trd_mod_1, trd_mod_2, trd_mod_3;
	//core <-> accelerator interact
	wire [31:0] div_rem_result_0, div_rem_result_1, div_rem_result_2, div_rem_result_3;
	wire div_rem_ready_0, div_rem_ready_1, div_rem_ready_2, div_rem_ready_3;
	//OS_Kernel <-> accelerator interact
	wire accept_request_0, accept_request_1;
	wire [2:0] assign_core_num_0, assign_core_num_1;
	wire [1:0] div_rem_order_0, div_rem_order_1;
	wire [31:0] acc_in_A_0, acc_in_A_1, acc_in_B_0, acc_in_B_1;
	//OS_Kernel <-> PID_Queue interact
	wire enable_create_PID, sign_up_PID, disable_PID_active, trd_request_valid, need_trd_PID, accept_trd_PID, full_assign, finish_threading, need_tsk_PID, need_tsk_inherit, accept_tsk_PID;
	wire [4:0] trd_ass_num_PID, trd_count_rd_PID, trd_ass_info_PID, trd_count_rd_info_PID;
	wire [7:0] disable_PID, trd_request_PID, trd_PID, finish_trd_PID, tsk_PID;
	wire [31:0] trd_pc_PID, trd_repeat_num_PID, trd_reg_inherit_num_PID, trd_start_pc_PID, trd_reg_inherit_info_PID, trd_operate_count_PID, finish_trd_pc, tsk_pc_register_PID, tsk_pc_PID;
	wire [991:0] trd_all_reg_PID, trd_inherit_reg_all_PID;
	//L2 Cache <-> PID_Queue interact
	wire new_PID, disable_PID_L2, un_lock_active;
	wire [7:0] PID_register, PID_discard, un_lock_PID;
	//arrange core==========/////////////////////////////////////////////////////////////////////////////////using reset signal for control core active
	RISCVpipeline Main_Core0(
		.clk(clk), .reset(reset & (core_activate_state[0] | core_activate_0)),
		.core_control_pc(core_start_pc_0),
		.core_control_active(core_activate_0),
		.tasking_or_threading(tsk_or_trd_0),
		.context_switch_active(context_switch_mv_data_0),
		.context_switch_count(context_switch_count_0),
		.switching_data(switching_data_0),
		.PID_info_in(PID_in_0),
													.PID_info_out(PID_out_0),
													.multithreading_active(multithread_active_0),
													.multitasking_active(multitask_active_0),
													.thread_pc_out(trd_start_pc_0),
													.thread_core_assign_count(core_assign_num_0),
													.thread_repeat_function_count(repeat_function_num_0),
													.context_switch_inherit(register_inherit_0),
													.thread_count_num(thread_function_num_0),
													.context_switch_reg(context_switch_all_reg_0),
													.function_finish(function_finish_0),
													.thread_finish(thread_finish_0),
													.thread_finish_pc(thread_finish_pc_0),
													.exe_pc_for_count(exe_pc_0),			//for spectate clock cycle
													.num1(acc_A_0),
													.num2(acc_B_0),
													.div_rem(div_rem_ctl_0),
													.div_rem_request(div_rem_request_0),
		.result_div_rem(div_rem_result_0),
		.accelerator_ready(div_rem_ready_0),
													.read_request(read_request_0),
													.write_request(write_request_0),
													.address_start_end_same(start_end_same_0),
													.address_to_L2(address_0),
													.refresh_data_loc(refresh_loc_0),
													.refresh_data_to_L2(refresh_data_0),
		.L2_operate_ready(L2_ready_0),
		.data_from_L2(read_data_0),
		.rewrite_active(rewrite_active_0),
		.rewrite_address(rewrite_address_0),
													.trd_mod(trd_mod_0)
	);
	RISCVpipeline Main_Core1(
		.clk(clk), .reset(reset & (core_activate_state[1] | core_activate_1)),
		.core_control_pc(core_start_pc_1),
		.core_control_active(core_activate_1),
		.tasking_or_threading(tsk_or_trd_1),
		.context_switch_active(context_switch_mv_data_1),
		.context_switch_count(context_switch_count_1),
		.switching_data(switching_data_1),
		.PID_info_in(PID_in_1),
													.PID_info_out(PID_out_1),
													.multithreading_active(multithread_active_1),
													.multitasking_active(multitask_active_1),
													.thread_pc_out(trd_start_pc_1),
													.thread_core_assign_count(core_assign_num_1),
													.thread_repeat_function_count(repeat_function_num_1),
													.context_switch_inherit(register_inherit_1),
													.thread_count_num(thread_function_num_1),
													.context_switch_reg(context_switch_all_reg_1),
													.function_finish(function_finish_1),
													.thread_finish(thread_finish_1),
													.thread_finish_pc(thread_finish_pc_1),
													.exe_pc_for_count(exe_pc_1),			//for spectate clock cycle
													.num1(acc_A_1),
													.num2(acc_B_1),
													.div_rem(div_rem_ctl_1),
													.div_rem_request(div_rem_request_1),
		.result_div_rem(div_rem_result_1),
		.accelerator_ready(div_rem_ready_1),
													.read_request(read_request_1),
													.write_request(write_request_1),
													.address_start_end_same(start_end_same_1),
													.address_to_L2(address_1),
													.refresh_data_loc(refresh_loc_1),
													.refresh_data_to_L2(refresh_data_1),
		.L2_operate_ready(L2_ready_1),
		.data_from_L2(read_data_1),
		.rewrite_active(rewrite_active_1),
		.rewrite_address(rewrite_address_1),
													.trd_mod(trd_mod_1)
	);
	RISCVpipeline Main_Core2(
		.clk(clk), .reset(reset & (core_activate_state[2] | core_activate_2)),
		.core_control_pc(core_start_pc_2),
		.core_control_active(core_activate_2),
		.tasking_or_threading(tsk_or_trd_2),
		.context_switch_active(context_switch_mv_data_2),
		.context_switch_count(context_switch_count_2),
		.switching_data(switching_data_2),
		.PID_info_in(PID_in_2),
													.PID_info_out(PID_out_2),
													.multithreading_active(multithread_active_2),
													.multitasking_active(multitask_active_2),
													.thread_pc_out(trd_start_pc_2),
													.thread_core_assign_count(core_assign_num_2),
													.thread_repeat_function_count(repeat_function_num_2),
													.context_switch_inherit(register_inherit_2),
													.thread_count_num(thread_function_num_2),
													.context_switch_reg(context_switch_all_reg_2),
													.function_finish(function_finish_2),
													.thread_finish(thread_finish_2),
													.thread_finish_pc(thread_finish_pc_2),
													.exe_pc_for_count(exe_pc_2),			//for spectate clock cycle
													.num1(acc_A_2),
													.num2(acc_B_2),
													.div_rem(div_rem_ctl_2),
													.div_rem_request(div_rem_request_2),
		.result_div_rem(div_rem_result_2),
		.accelerator_ready(div_rem_ready_2),
													.read_request(read_request_2),
													.write_request(write_request_2),
													.address_start_end_same(start_end_same_2),
													.address_to_L2(address_2),
													.refresh_data_loc(refresh_loc_2),
													.refresh_data_to_L2(refresh_data_2),
		.L2_operate_ready(L2_ready_2),
		.data_from_L2(read_data_2),
		.rewrite_active(rewrite_active_2),
		.rewrite_address(rewrite_address_2),
													.trd_mod(trd_mod_2)
	);
	RISCVpipeline Main_Core3(
		.clk(clk), .reset(reset & (core_activate_state[3] | core_activate_3)),
		.core_control_pc(core_start_pc_3),
		.core_control_active(core_activate_3),
		.tasking_or_threading(tsk_or_trd_3),
		.context_switch_active(context_switch_mv_data_3),
		.context_switch_count(context_switch_count_3),
		.switching_data(switching_data_3),
		.PID_info_in(PID_in_3),
													.PID_info_out(PID_out_3),
													.multithreading_active(multithread_active_3),
													.multitasking_active(multitask_active_3),
													.thread_pc_out(trd_start_pc_3),
													.thread_core_assign_count(core_assign_num_3),
													.thread_repeat_function_count(repeat_function_num_3),
													.context_switch_inherit(register_inherit_3),
													.thread_count_num(thread_function_num_3),
													.context_switch_reg(context_switch_all_reg_3),
													.function_finish(function_finish_3),
													.thread_finish(thread_finish_3),
													.thread_finish_pc(thread_finish_pc_3),
													.exe_pc_for_count(exe_pc_3),			//for spectate clock cycle
													.num1(acc_A_3),
													.num2(acc_B_3),
													.div_rem(div_rem_ctl_3),
													.div_rem_request(div_rem_request_3),
		.result_div_rem(div_rem_result_3),
		.accelerator_ready(div_rem_ready_3),
													.read_request(read_request_3),
													.write_request(write_request_3),
													.address_start_end_same(start_end_same_3),
													.address_to_L2(address_3),
													.refresh_data_loc(refresh_loc_3),
													.refresh_data_to_L2(refresh_data_3),
		.L2_operate_ready(L2_ready_3),
		.data_from_L2(read_data_3),
		.rewrite_active(rewrite_active_3),
		.rewrite_address(rewrite_address_3),
													.trd_mod(trd_mod_3)
	);
	//OS_Kernel module=====///////////////////////////////////////////////////////////////////////////////////////
	OS_Kernel OS_Kernel(
		.clk(clk), .reset(reset),
													.core_activate(core_activate_state),
		.trd_active_0(multithread_active_0),
		.trd_active_1(multithread_active_1),
		.trd_active_2(multithread_active_2),
		.trd_active_3(multithread_active_3),
		.tsk_active_0(multitask_active_0),
		.tsk_active_1(multitask_active_1),
		.tsk_active_2(multitask_active_2),
		.tsk_active_3(multitask_active_3),
		.PID_in_0(PID_out_0),
		.PID_in_1(PID_out_1),
		.PID_in_2(PID_out_2),
		.PID_in_3(PID_out_3),
		.trd_pc_in_0(trd_start_pc_0),
		.trd_pc_in_1(trd_start_pc_1),
		.trd_pc_in_2(trd_start_pc_2),
		.trd_pc_in_3(trd_start_pc_3),
		.trd_ass_num_0(core_assign_num_0),
		.trd_ass_num_1(core_assign_num_1),
		.trd_ass_num_2(core_assign_num_2),
		.trd_ass_num_3(core_assign_num_3),
		.trd_repeat_num_0(repeat_function_num_0),
		.trd_repeat_num_1(repeat_function_num_1),
		.trd_repeat_num_2(repeat_function_num_2),
		.trd_repeat_num_3(repeat_function_num_3),
		.trd_reg_inherit_0(register_inherit_0),
		.trd_reg_inherit_1(register_inherit_1),
		.trd_reg_inherit_2(register_inherit_2),
		.trd_reg_inherit_3(register_inherit_3),
		.trd_count_rd_0(thread_function_num_0),
		.trd_count_rd_1(thread_function_num_1),
		.trd_count_rd_2(thread_function_num_2),
		.trd_count_rd_3(thread_function_num_3),
		.trd_all_reg_0(context_switch_all_reg_0),
		.trd_all_reg_1(context_switch_all_reg_1),
		.trd_all_reg_2(context_switch_all_reg_2),
		.trd_all_reg_3(context_switch_all_reg_3),
		.function_finish_0(function_finish_0),
		.function_finish_1(function_finish_1),
		.function_finish_2(function_finish_2),
		.function_finish_3(function_finish_3),
		.thread_finish_0(thread_finish_0),
		.thread_finish_1(thread_finish_1),
		.thread_finish_2(thread_finish_2),
		.thread_finish_3(thread_finish_3),
		.thread_finish_pc_0(thread_finish_pc_0),
		.thread_finish_pc_1(thread_finish_pc_1),
		.thread_finish_pc_2(thread_finish_pc_2),
		.thread_finish_pc_3(thread_finish_pc_3),
													.core_start_pc_0(core_start_pc_0),
													.core_start_pc_1(core_start_pc_1),
													.core_start_pc_2(core_start_pc_2),
													.core_start_pc_3(core_start_pc_3),
													.core_active_0(core_activate_0),
													.core_active_1(core_activate_1),
													.core_active_2(core_activate_2),
													.core_active_3(core_activate_3),
													.tsk_or_trd_0(tsk_or_trd_0),
													.tsk_or_trd_1(tsk_or_trd_1),
													.tsk_or_trd_2(tsk_or_trd_2),
													.tsk_or_trd_3(tsk_or_trd_3),
													.cs_reg_active_0(context_switch_mv_data_0),
													.cs_reg_active_1(context_switch_mv_data_1),
													.cs_reg_active_2(context_switch_mv_data_2),
													.cs_reg_active_3(context_switch_mv_data_3),
													.cs_reg_rd_0(context_switch_count_0),
													.cs_reg_rd_1(context_switch_count_1),
													.cs_reg_rd_2(context_switch_count_2),
													.cs_reg_rd_3(context_switch_count_3),
													.cs_reg_data_0(switching_data_0),
													.cs_reg_data_1(switching_data_1),
													.cs_reg_data_2(switching_data_2),
													.cs_reg_data_3(switching_data_3),
													.PID_out_0(PID_in_0),
													.PID_out_1(PID_in_1),
													.PID_out_2(PID_in_2),
													.PID_out_3(PID_in_3),
													.system_error_Kernel3(),
		.acc_in_A_0(acc_A_0),
		.acc_in_A_1(acc_A_1),
		.acc_in_A_2(acc_A_2),
		.acc_in_A_3(acc_A_3),
		.acc_in_B_0(acc_B_0),
		.acc_in_B_1(acc_B_1),
		.acc_in_B_2(acc_B_2),
		.acc_in_B_3(acc_B_3),
		.div_rem_ctl_0(div_rem_ctl_0),
		.div_rem_ctl_1(div_rem_ctl_1),
		.div_rem_ctl_2(div_rem_ctl_2),
		.div_rem_ctl_3(div_rem_ctl_3),
		.div_rem_active_0(div_rem_request_0),
		.div_rem_active_1(div_rem_request_1),
		.div_rem_active_2(div_rem_request_2),
		.div_rem_active_3(div_rem_request_3),
													.accept_request_0(accept_request_0),
													.accept_request_1(accept_request_1),
													.assign_core_num_0(assign_core_num_0),
													.assign_core_num_1(assign_core_num_1),
													.div_rem_order_0(div_rem_order_0),
													.div_rem_order_1(div_rem_order_1),
													.acc_out_A_0(acc_in_A_0),
													.acc_out_A_1(acc_in_A_1),
													.acc_out_B_0(acc_in_B_0),
													.acc_out_B_1(acc_in_B_1),
		.acc_finish_0(div_rem_ready_0),
		.acc_finish_1(div_rem_ready_1),
		.acc_finish_2(div_rem_ready_2),
		.acc_finish_3(div_rem_ready_3),
		.enable_create_PID(enable_create_PID),
													.sign_up_PID(sign_up_PID),
													.disable_PID(disable_PID),
													.disable_PID_active(disable_PID_active),
													.trd_request_valid(trd_request_valid),
													.trd_request_PID(trd_request_PID),
													.trd_pc_PID(trd_pc_PID),
													.trd_ass_num_PID(trd_ass_num_PID),
													.trd_repeat_num_PID(trd_repeat_num_PID),
													.trd_reg_inherit_num_PID(trd_reg_inherit_num_PID),
													.trd_count_rd_PID(trd_count_rd_PID),
													.trd_all_reg_PID(trd_all_reg_PID),
		.need_trd_PID(need_trd_PID),
													.accept_trd_PID(accept_trd_PID),
													.full_assign(full_assign),
		.trd_PID(trd_PID),
		.trd_start_pc_PID(trd_start_pc_PID),
		.trd_ass_info_PID(trd_ass_info_PID),
		.trd_reg_inherit_info_PID(trd_reg_inherit_info_PID),
		.trd_count_rd_info_PID(trd_count_rd_info_PID),
		.trd_operate_count_PID(trd_operate_count_PID),
		.trd_inherit_reg_all_PID(trd_inherit_reg_all_PID),
													.finish_threading(finish_threading),
													.finish_trd_PID(finish_trd_PID),
													.finish_trd_pc(finish_trd_pc),
													.tsk_pc_register_PID(tsk_pc_register_PID),
		.need_tsk_PID(need_tsk_PID),
		.need_tsk_inherit(need_tsk_inherit),
													.accept_tsk_PID(accept_tsk_PID),
		.tsk_PID(tsk_PID),
		.tsk_pc_PID(tsk_pc_PID)
	);
	//accelerator module=====/////////////////////////////////////////////////////////////////////////////////////
	wire ready_temp0_0, ready_temp0_1, ready_temp0_2, ready_temp0_3, ready_temp1_0, ready_temp1_1, ready_temp1_2, ready_temp1_3;
	wire [31:0] ans_temp0_0, ans_temp0_1, ans_temp0_2, ans_temp0_3, ans_temp1_0, ans_temp1_1, ans_temp1_2, ans_temp1_3;
	assign div_rem_ready_0 = ready_temp0_0 | ready_temp1_0;
	assign div_rem_ready_1 = ready_temp0_1 | ready_temp1_1;
	assign div_rem_ready_2 = ready_temp0_2 | ready_temp1_2;
	assign div_rem_ready_3 = ready_temp0_3 | ready_temp1_3;
	assign div_rem_result_0 = ready_temp0_0 ? ans_temp0_0 : ans_temp1_0;
	assign div_rem_result_1 = ready_temp0_1 ? ans_temp0_1 : ans_temp1_1;
	assign div_rem_result_2 = ready_temp0_2 ? ans_temp0_2 : ans_temp1_2;
	assign div_rem_result_3 = ready_temp0_3 ? ans_temp0_3 : ans_temp1_3;
	Divide_Remain_Unit MDU_Core0(
		.clk(clk), .reset(reset),
		.request(accept_request_0),
		.core_num(assign_core_num_0),
		.order(div_rem_order_0),
		.rs1(acc_in_A_0),
		.rs2(acc_in_B_0),
													.ready_0(ready_temp0_0),
													.ready_1(ready_temp0_1),
													.ready_2(ready_temp0_2),
													.ready_3(ready_temp0_3),
													.ans_0(ans_temp0_0),
													.ans_1(ans_temp0_1),
													.ans_2(ans_temp0_2),
													.ans_3(ans_temp0_3)
	);
	Divide_Remain_Unit MDU_Core1(
		.clk(clk), .reset(reset),
		.request(accept_request_1),
		.core_num(assign_core_num_1),
		.order(div_rem_order_1),
		.rs1(acc_in_A_1),
		.rs2(acc_in_B_1),
													.ready_0(ready_temp1_0),
													.ready_1(ready_temp1_1),
													.ready_2(ready_temp1_2),
													.ready_3(ready_temp1_3),
													.ans_0(ans_temp1_0),
													.ans_1(ans_temp1_1),
													.ans_2(ans_temp1_2),
													.ans_3(ans_temp1_3)
	);
	//L2 Cache module=====//////////////////////////////////////////////////////////////////////////////////////
	L2_Cache L2_Cache(
		.clk(clk), .reset(reset),
		.read_request_0(read_request_0),
		.read_request_1(read_request_1),
		.read_request_2(read_request_2),
		.read_request_3(read_request_3),
		.write_request_0(write_request_0),
		.write_request_1(write_request_1),
		.write_request_2(write_request_2),
		.write_request_3(write_request_3),
		.start_end_same_0(start_end_same_0),
		.start_end_same_1(start_end_same_1),
		.start_end_same_2(start_end_same_2),
		.start_end_same_3(start_end_same_3),
		.address_0(address_0),
		.address_1(address_1),
		.address_2(address_2),
		.address_3(address_3),
		.refresh_loc_0(refresh_loc_0),
		.refresh_loc_1(refresh_loc_1),
		.refresh_loc_2(refresh_loc_2),
		.refresh_loc_3(refresh_loc_3),
		.refresh_data_0(refresh_data_0),
		.refresh_data_1(refresh_data_1),
		.refresh_data_2(refresh_data_2),
		.refresh_data_3(refresh_data_3),
													.L2_ready_0(L2_ready_0),
													.L2_ready_1(L2_ready_1),
													.L2_ready_2(L2_ready_2),
													.L2_ready_3(L2_ready_3),
													.read_data_0(read_data_0),
													.read_data_1(read_data_1),
													.read_data_2(read_data_2),
													.read_data_3(read_data_3),
													.rewrite_active_0(rewrite_active_0),
													.rewrite_active_1(rewrite_active_1),
													.rewrite_active_2(rewrite_active_2),
													.rewrite_active_3(rewrite_active_3),
													.rewrite_address_0(rewrite_address_0),
													.rewrite_address_1(rewrite_address_1),
													.rewrite_address_2(rewrite_address_2),
													.rewrite_address_3(rewrite_address_3),
		.trd_mod_0(trd_mod_0),
		.trd_mod_1(trd_mod_1),
		.trd_mod_2(trd_mod_2),
		.trd_mod_3(trd_mod_3),
		.trd_PID_0(PID_out_0),
		.trd_PID_1(PID_out_1),
		.trd_PID_2(PID_out_2),
		.trd_PID_3(PID_out_3),
		.new_PID(new_PID),
		.PID_register(PID_register),
		.disable_PID(disable_PID_L2),
		.PID_discard(PID_discard),
		.un_lock_active(un_lock_active),
		.un_lock_PID(un_lock_PID),
													.not_pure_function()
	);
	//PID_Queue module=====///////////////////////////////////////////////////////////////////////////////////////
	PID_Queue Processor_ID_Queue(
		.clk(clk), .reset(reset),
													.enable_create_PID(enable_create_PID),
		.sign_up_PID(sign_up_PID),
		.disable_PID(disable_PID),
		.disable_PID_active(disable_PID_active),
		.trd_request_valid(trd_request_valid),
		.trd_request_PID(trd_request_PID),
		.trd_pc_PID(trd_pc_PID),
		.trd_ass_num_PID(trd_ass_num_PID),
		.trd_repeat_num_PID(trd_repeat_num_PID),
		.trd_reg_inherit_num_PID(trd_reg_inherit_num_PID),
		.trd_count_rd_PID(trd_count_rd_PID),
		.trd_all_reg_PID(trd_all_reg_PID),
													.need_trd_PID(need_trd_PID),
		.accept_trd_PID(accept_trd_PID),
		.full_assign(full_assign),
													.trd_PID(trd_PID),
													.trd_start_pc_PID(trd_start_pc_PID),
													.trd_ass_info_PID(trd_ass_info_PID),
													.trd_reg_inherit_info_PID(trd_reg_inherit_info_PID),
													.trd_count_rd_info_PID(trd_count_rd_info_PID),
													.trd_operate_count_PID(trd_operate_count_PID),
													.trd_inherit_reg_all_PID(trd_inherit_reg_all_PID),
		.finish_threading(finish_threading),
		.finish_trd_PID(finish_trd_PID),
		.finish_trd_pc(finish_trd_pc),
		.tsk_pc_register_PID(tsk_pc_register_PID),
													.need_tsk_PID(need_tsk_PID),
													.need_tsk_inherit(need_tsk_inherit),
		.accept_tsk_PID(accept_tsk_PID),
													.tsk_PID(tsk_PID),
													.tsk_pc_PID(tsk_pc_PID),
													.new_PID_L2(new_PID),
													.PID_register_L2(PID_register),
													.disable_PID_L2(disable_PID_L2),
													.PID_discard_L2(PID_discard),
													.un_lock_active_L2(un_lock_active),
													.un_lock_PID_L2(un_lock_PID)
	);
endmodule
