`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/02 23:51:31
// Design Name: 
// Module Name: OS_Kernel
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


module OS_Kernel(
	//clock reset
	input clk, reset,
	output [3:0] core_activate,
	//multitask multithread
	input trd_active_0, trd_active_1, trd_active_2, trd_active_3,
	input tsk_active_0, tsk_active_1, tsk_active_2, tsk_active_3,
	input [7:0] PID_in_0, PID_in_1, PID_in_2, PID_in_3,
	input [31:0] trd_pc_in_0, trd_pc_in_1, trd_pc_in_2, trd_pc_in_3,
	input [4:0] trd_ass_num_0, trd_ass_num_1, trd_ass_num_2, trd_ass_num_3,
	input [31:0] trd_repeat_num_0, trd_repeat_num_1, trd_repeat_num_2, trd_repeat_num_3,
	input [31:0] trd_reg_inherit_0, trd_reg_inherit_1, trd_reg_inherit_2, trd_reg_inherit_3,
	input [4:0] trd_count_rd_0, trd_count_rd_1, trd_count_rd_2, trd_count_rd_3,
	input [991:0] trd_all_reg_0, trd_all_reg_1, trd_all_reg_2, trd_all_reg_3,
	input function_finish_0, function_finish_1, function_finish_2, function_finish_3,
	input thread_finish_0, thread_finish_1, thread_finish_2, thread_finish_3,
	input [31:0] thread_finish_pc_0, thread_finish_pc_1, thread_finish_pc_2, thread_finish_pc_3,
	output [31:0] core_start_pc_0, core_start_pc_1, core_start_pc_2, core_start_pc_3,
	output core_active_0, core_active_1, core_active_2, core_active_3,
	output tsk_or_trd_0, tsk_or_trd_1, tsk_or_trd_2, tsk_or_trd_3,
	output reg cs_reg_active_0, cs_reg_active_1, cs_reg_active_2, cs_reg_active_3,
	output [4:0] cs_reg_rd_0, cs_reg_rd_1, cs_reg_rd_2, cs_reg_rd_3,
	output [31:0] cs_reg_data_0, cs_reg_data_1, cs_reg_data_2, cs_reg_data_3,
	output [7:0] PID_out_0, PID_out_1, PID_out_2, PID_out_3,
	output system_error_Kernel3,
	//accelerator
	input [31:0] acc_in_A_0, acc_in_A_1, acc_in_A_2, acc_in_A_3, acc_in_B_0, acc_in_B_1, acc_in_B_2, acc_in_B_3,
	input [1:0] div_rem_ctl_0, div_rem_ctl_1, div_rem_ctl_2, div_rem_ctl_3,
	input div_rem_active_0, div_rem_active_1, div_rem_active_2, div_rem_active_3,
	output accept_request_0, accept_request_1,
	output [2:0] assign_core_num_0, assign_core_num_1,
	output [1:0] div_rem_order_0, div_rem_order_1,
	output [31:0] acc_out_A_0, acc_out_A_1, acc_out_B_0, acc_out_B_1,
	input acc_finish_0, acc_finish_1, acc_finish_2, acc_finish_3,
	//PID Queue
	input enable_create_PID,									//can create new PID
	output sign_up_PID,											//new PID for multitasking
	output [7:0] disable_PID,									//delete PID for multitasking finish_function
	output disable_PID_active,									//delete PID active
	output trd_request_valid,									//threading request active
	output [7:0] trd_request_PID,								//threading activate in this PID
	output [31:0] trd_pc_PID,									//pc of starting thread
	output [4:0] trd_ass_num_PID,								//worker number - threading
	output [31:0] trd_repeat_num_PID, trd_reg_inherit_num_PID,	//repeat number - threading //thread number - threading
	output [4:0] trd_count_rd_PID,								//reg number for thread number - threading
	output [991:0] trd_all_reg_PID,								//all reg data for inherit
	input need_trd_PID,											//remaining task for thread
	output accept_trd_PID, full_assign,							//inform PID for accept request - threading //no remain worker
	input [7:0] trd_PID,										//PID number of requested threading
	input [31:0] trd_start_pc_PID,								//pc of start threading
	input [4:0] trd_ass_info_PID,								//worker number of threading
	input [31:0] trd_reg_inherit_info_PID,						//reg number for inherit - threading
	input [4:0] trd_count_rd_info_PID,							//reg number for threading number - threading
	input [31:0] trd_operate_count_PID,							//threading number - threading
	input [991:0] trd_inherit_reg_all_PID,						//all reg data for inherit
	output finish_threading,									//inform finish threading task to PID Queue
	output [7:0] finish_trd_PID,								//PID of finish threading task
	output [31:0] finish_trd_pc,
	output [31:0] tsk_pc_register_PID,							//pc of start multitasking
	input need_tsk_PID,											//take information from PID - can assign core for multitasking
	input need_tsk_inherit,
	output accept_tsk_PID,										//multitasking activate
	input [7:0] tsk_PID,										//PID for multitasking
	input [31:0] tsk_pc_PID										//pc for multitasking
	);
	wire [31:0] tsk_new_pc_0 = trd_repeat_num_0;
	wire [31:0] tsk_new_pc_1 = trd_repeat_num_1;
	wire [31:0] tsk_new_pc_2 = trd_repeat_num_2;
	wire [31:0] tsk_new_pc_3 = trd_repeat_num_3;
	//common system prepare
	reg [3:0] core_active_state;
	reg fin_trd_temp_valid;
	reg [7:0] fin_trd_PID_temp;
	reg [31:0] fin_trd_pc_PID_temp;
	integer i;
	//accelerator prepare
	reg [2:0] waiting_acc [0:3];
	reg [2:0] operate_acc [0:3];
	wire [31:0] acc_in_A [0:3];
	wire [31:0] acc_in_B [0:3];
	wire [1:0] div_rem_ctl_acc [0:3];
	wire div_rem_active_acc [0:3];
	wire [3:0] request_acc;
	reg accept_request_acc_0, accept_request_acc_1;
	reg [2:0] core_num_acc_0, core_num_acc_1;
	reg [1:0] div_rem_order_acc_0, div_rem_order_acc_1;
	reg [31:0] acc_input_A_0, acc_input_A_1, acc_input_B_0, acc_input_B_1;
	wire acc_finish [0:3];
	wire [3:0] finish_acc_check;
	wire [1:0] waiting_acc_move_stack [0:3];
	wire [2:0] operate_acc_move_stack [0:3];
	//multithreading prepare
	wire [1:0] less_core_loc;
	reg [31:0] insert_inherit_num [0:3];
	reg [992:0] insert_all_reg_data [0:3];
	reg [31:0] insert_repeat_num [0:3];
	reg [4:0] insert_repeat_rd [0:3];
	wire [31:0] insert_reg_data_0 [0:31];
	wire [31:0] insert_reg_data_1 [0:31];
	wire [31:0] insert_reg_data_2 [0:31];
	wire [31:0] insert_reg_data_3 [0:31];
	reg [4:0] less_inherit_loc [0:3];
	//common system /////////////////////////////////////////////////////////////////////////////////
	assign core_activate = core_active_state;
	assign disable_PID_active = function_finish_0 | function_finish_1 | function_finish_2 | function_finish_3;
	assign disable_PID = function_finish_0 ? PID_in_0 : (function_finish_1 ? PID_in_1 : (function_finish_2 ? PID_in_2 : PID_in_3));
	wire single_PID_0 = core_active_state[0] & ((core_active_state[1] & ((PID_in_0 != PID_in_1) | thread_finish_1)) | !core_active_state[1]) & ((core_active_state[2] & ((PID_in_0 != PID_in_2) | thread_finish_2)) | !core_active_state[2]) & ((core_active_state[3] & ((PID_in_0 != PID_in_3) | thread_finish_3)) | !core_active_state[3]);
	wire single_PID_1 = core_active_state[1] & ((core_active_state[0] & ((PID_in_1 != PID_in_0) | thread_finish_0)) | !core_active_state[0]) & ((core_active_state[2] & ((PID_in_1 != PID_in_2) | thread_finish_2)) | !core_active_state[2]) & ((core_active_state[3] & ((PID_in_1 != PID_in_3) | thread_finish_3)) | !core_active_state[3]);
	wire single_PID_2 = core_active_state[2] & ((core_active_state[1] & ((PID_in_2 != PID_in_1) | thread_finish_1)) | !core_active_state[1]) & ((core_active_state[0] & ((PID_in_2 != PID_in_0) | thread_finish_0)) | !core_active_state[0]) & ((core_active_state[3] & ((PID_in_2 != PID_in_3) | thread_finish_3)) | !core_active_state[3]);
	wire single_PID_3 = core_active_state[3] & ((core_active_state[1] & ((PID_in_3 != PID_in_1) | thread_finish_1)) | !core_active_state[1]) & ((core_active_state[2] & ((PID_in_3 != PID_in_2) | thread_finish_2)) | !core_active_state[2]) & ((core_active_state[0] & ((PID_in_3 != PID_in_0) | thread_finish_0)) | !core_active_state[0]);
	wire finish_thread_0 = thread_finish_0 & single_PID_0;
	wire finish_thread_1 = thread_finish_1 & single_PID_1;
	wire finish_thread_2 = thread_finish_2 & single_PID_2;
	wire finish_thread_3 = thread_finish_3 & single_PID_3;
	assign finish_threading = finish_thread_0 | finish_thread_1 | finish_thread_2 | finish_thread_3 | fin_trd_temp_valid;
	assign finish_trd_PID = finish_thread_0 ? PID_in_0 : (finish_thread_1 ? PID_in_1 : (finish_thread_2 ? PID_in_2 : (finish_thread_3 ? PID_in_3 : fin_trd_PID_temp)));
	assign finish_trd_pc = finish_thread_0 ? thread_finish_pc_0 : (finish_thread_1 ? thread_finish_pc_1 : (finish_thread_2 ? thread_finish_pc_2 : (finish_thread_3 ? thread_finish_pc_3 : fin_trd_pc_PID_temp)));
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			fin_trd_temp_valid			<= 0;
			fin_trd_PID_temp			<= 0;
			fin_trd_pc_PID_temp			<= 0;
		end else begin
			if ((finish_thread_0 + finish_thread_1 + finish_thread_2 + finish_thread_3) > 1) begin
				fin_trd_temp_valid		<= 1;
				fin_trd_PID_temp		<= (finish_thread_0 & finish_thread_1) ? PID_in_1 : (((finish_thread_0 + finish_thread_1 + finish_thread_2) == 2) ? PID_in_2 : PID_in_3);
				fin_trd_pc_PID_temp		<= (finish_thread_0 & finish_thread_1) ? thread_finish_pc_1 : (((finish_thread_0 + finish_thread_1 + finish_thread_2) == 2) ? thread_finish_pc_2 : thread_finish_pc_3);
			end
			if (fin_trd_temp_valid) begin
				fin_trd_temp_valid		<= 0;
			end
		end
	end
	//accelerator ///////////////////////////////////////////////////////////////////////////////////
	assign acc_in_A[0] = acc_in_A_0;
	assign acc_in_A[1] = acc_in_A_1;
	assign acc_in_A[2] = acc_in_A_2;
	assign acc_in_A[3] = acc_in_A_3;
	assign acc_in_B[0] = acc_in_B_0;
	assign acc_in_B[1] = acc_in_B_1;
	assign acc_in_B[2] = acc_in_B_2;
	assign acc_in_B[3] = acc_in_B_3;
	assign div_rem_ctl_acc[0] = div_rem_ctl_0;
	assign div_rem_ctl_acc[1] = div_rem_ctl_1;
	assign div_rem_ctl_acc[2] = div_rem_ctl_2;
	assign div_rem_ctl_acc[3] = div_rem_ctl_3;
	assign div_rem_active_acc[0] = div_rem_active_0;
	assign div_rem_active_acc[1] = div_rem_active_1;
	assign div_rem_active_acc[2] = div_rem_active_2;
	assign div_rem_active_acc[3] = div_rem_active_3;
	assign request_acc[0] = (waiting_acc[0] != 3'b111) ? div_rem_active_acc[waiting_acc[0][1:0]] : 0;
	assign request_acc[1] = (waiting_acc[1] != 3'b111) ? div_rem_active_acc[waiting_acc[1][1:0]] : 0;
	assign request_acc[2] = (waiting_acc[2] != 3'b111) ? div_rem_active_acc[waiting_acc[2][1:0]] : 0;
	assign request_acc[3] = (waiting_acc[3] != 3'b111) ? div_rem_active_acc[waiting_acc[3][1:0]] : 0;
	assign acc_finish[0] = acc_finish_0;
	assign acc_finish[1] = acc_finish_1;
	assign acc_finish[2] = acc_finish_2;
	assign acc_finish[3] = acc_finish_3;
	assign finish_acc_check[0] = (operate_acc[0] != 3'b111) ? acc_finish[operate_acc[0][1:0]] : 0;
	assign finish_acc_check[1] = (operate_acc[1] != 3'b111) ? acc_finish[operate_acc[1][1:0]] : 0;
	assign finish_acc_check[2] = (operate_acc[2] != 3'b111) ? acc_finish[operate_acc[2][1:0]] : 0;
	assign finish_acc_check[3] = (operate_acc[3] != 3'b111) ? acc_finish[operate_acc[3][1:0]] : 0;
	wire [2:0] first_index = request_acc[0] ? 3'b000 : ((request_acc[1:0] == 2'b10) ? 3'b001 : ((request_acc[2:0] == 3'b100) ? 3'b010 : ((request_acc[3:0] == 4'b1000) ? 3'b011 : 3'b111)));
	wire [2:0] second_index = (request_acc[1:0] == 2'b11) ? 3'b001 : ((request_acc[2] & ((request_acc[1] + request_acc[0]) == 1)) ? 3'b010 : ((request_acc[3] & ((request_acc[2] + request_acc[1] + request_acc[0]) == 1)) ? 3'b011 : 3'b111));
	wire [2:0] acc_waiting_num = (waiting_acc[0] != 3'b111) + (waiting_acc[1] != 3'b111) + (waiting_acc[2] != 3'b111) + (waiting_acc[3] != 3'b111);
	wire [2:0] acc_operate_num = (operate_acc[0] != 3'b111) + (operate_acc[1] != 3'b111) + (operate_acc[2] != 3'b111) + (operate_acc[3] != 3'b111);
	wire [1:0] start_working = (first_index != 3'b111) + (second_index != 3'b111);
	wire [2:0] finish_working = operate_acc_move_stack[3] + finish_acc_check[3];
	wire [2:0] empty_waiting_slot = acc_waiting_num - start_working + finish_working;
	wire [2:0] empty_operate_slot = acc_operate_num - finish_working + start_working;
	assign waiting_acc_move_stack[0] = 0;
	assign waiting_acc_move_stack[1] = (first_index == 3'b000);
	assign waiting_acc_move_stack[2] = (first_index < 2) + (second_index < 2);
	assign waiting_acc_move_stack[3] = (first_index < 3) + (second_index < 3);
	wire [2:0] first_index_arrival = acc_operate_num - finish_working;
	assign operate_acc_move_stack[0] = 0;
	assign operate_acc_move_stack[1] = finish_acc_check[0];
	assign operate_acc_move_stack[2] = finish_acc_check[0] + finish_acc_check[1];
	assign operate_acc_move_stack[3] = operate_acc_move_stack[2] + finish_acc_check[2];
	wire [1:0] start_operate_num = (first_index != 3'b111) + (second_index != 3'b111);
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			waiting_acc[0]				<= 3'b000;
			waiting_acc[1]				<= 3'b001;
			waiting_acc[2]				<= 3'b010;
			waiting_acc[3]				<= 3'b011;
			operate_acc[0]				<= 3'b111;
			operate_acc[1]				<= 3'b111;
			operate_acc[2]				<= 3'b111;
			operate_acc[3]				<= 3'b111;
			accept_request_acc_0		<= 0;
			accept_request_acc_1		<= 0;
			core_num_acc_0				<= 0;
			core_num_acc_1				<= 0;
			div_rem_order_acc_0			<= 0;
			div_rem_order_acc_1			<= 0;
			acc_input_A_0				<= 0;
			acc_input_B_0				<= 0;
			acc_input_A_1				<= 0;
			acc_input_B_1				<= 0;
		end else begin
			if (!request_acc[1] & (waiting_acc[1] != 3'b111)) begin
				waiting_acc[1 - waiting_acc_move_stack[1]]			<= waiting_acc[1];
			end
			if ((!request_acc[2] | (request_acc[0] & request_acc[1])) & (waiting_acc[2] != 3'b111)) begin
				waiting_acc[2 - waiting_acc_move_stack[2]]			<= waiting_acc[2];
			end
			if ((!request_acc[3] | ((request_acc[0] + request_acc[1] + request_acc[2]) > 1)) & (waiting_acc[3] != 3'b111)) begin
				waiting_acc[3 - waiting_acc_move_stack[3]]			<= waiting_acc[3];
			end
			if (empty_waiting_slot == 3'b000) begin
				waiting_acc[0]										<= 3'b111;
				waiting_acc[1]										<= 3'b111;
				waiting_acc[2]										<= 3'b111;
				waiting_acc[3]										<= 3'b111;
			end
			if (empty_waiting_slot == 3'b001) begin
				waiting_acc[1]										<= 3'b111;
				waiting_acc[2]										<= 3'b111;
				waiting_acc[3]										<= 3'b111;
			end
			if (empty_waiting_slot == 3'b010) begin
				waiting_acc[2]										<= 3'b111;
				waiting_acc[3]										<= 3'b111;
			end
			if (empty_waiting_slot == 3'b011) begin
				waiting_acc[3]										<= 3'b111;
			end
			if (first_index != 3'b111) begin
				operate_acc[first_index_arrival]					<= waiting_acc[first_index[1:0]];
			end
			if (second_index != 3'b111) begin
				operate_acc[first_index_arrival + 1]				<= waiting_acc[second_index[1:0]];
			end
			if (!finish_acc_check[1] & (operate_acc[1] != 3'b111)) begin
				operate_acc[1 - operate_acc_move_stack[1]]			<= operate_acc[1];
			end
			if (!finish_acc_check[2] & (operate_acc[2] != 3'b111)) begin
				operate_acc[2 - operate_acc_move_stack[2]]			<= operate_acc[2];
			end
			if (!finish_acc_check[3] & (operate_acc[3] != 3'b111)) begin
				operate_acc[3 - operate_acc_move_stack[3]]			<= operate_acc[3];
			end
			if (empty_operate_slot == 3'b000) begin
				operate_acc[0]										<= 3'b111;
				operate_acc[1]										<= 3'b111;
				operate_acc[2]										<= 3'b111;
				operate_acc[3]										<= 3'b111;
			end
			if (empty_operate_slot == 3'b001) begin
				operate_acc[1]										<= 3'b111;
				operate_acc[2]										<= 3'b111;
				operate_acc[3]										<= 3'b111;
			end
			if (empty_operate_slot == 3'b010) begin
				operate_acc[2]										<= 3'b111;
				operate_acc[3]										<= 3'b111;
			end
			if (empty_operate_slot == 3'b011) begin
				operate_acc[3]										<= 3'b111;
			end
			if (finish_acc_check[0]) begin
				waiting_acc[acc_waiting_num - start_operate_num]	<= operate_acc[0];
			end
			if (finish_acc_check[1]) begin
				waiting_acc[acc_waiting_num - start_operate_num + operate_acc_move_stack[1]]	<= operate_acc[1];
			end
			if (finish_acc_check[2]) begin
				waiting_acc[acc_waiting_num - start_operate_num + operate_acc_move_stack[2]]	<= operate_acc[2];
			end
			if (finish_acc_check[3]) begin
				waiting_acc[acc_waiting_num - start_operate_num + operate_acc_move_stack[3]]	<= operate_acc[3];
			end
			accept_request_acc_0		<= (first_index != 3'b111);
			accept_request_acc_1		<= (second_index != 3'b111);
			core_num_acc_0				<= waiting_acc[first_index[1:0]];
			core_num_acc_1				<= waiting_acc[second_index[1:0]];
			div_rem_order_acc_0			<= div_rem_ctl_acc[waiting_acc[first_index[1:0]]];
			div_rem_order_acc_1			<= div_rem_ctl_acc[waiting_acc[second_index[1:0]]];
			acc_input_A_0				<= acc_in_A[waiting_acc[first_index[1:0]]];
			acc_input_B_0				<= acc_in_B[waiting_acc[first_index[1:0]]];
			acc_input_A_1				<= acc_in_A[waiting_acc[second_index[1:0]]];
			acc_input_B_1				<= acc_in_B[waiting_acc[second_index[1:0]]];
		end
	end
	assign accept_request_0 = accept_request_acc_0;
	assign accept_request_1 = accept_request_acc_1;
	assign assign_core_num_0 = core_num_acc_0;
	assign assign_core_num_1 = core_num_acc_1;
	assign div_rem_order_0 = div_rem_order_acc_0;
	assign div_rem_order_1 = div_rem_order_acc_1;
	assign acc_out_A_0 = acc_input_A_0;
	assign acc_out_B_0 = acc_input_B_0;
	assign acc_out_A_1 = acc_input_A_1;
	assign acc_out_B_1 = acc_input_B_1;
	//multithreading ////////////////////////////////////////////////////////////////////////////////
	//new thread sign up
	assign trd_request_valid = (trd_active_0 | trd_active_1 | trd_active_2 | trd_active_3);
	assign trd_request_PID = trd_active_0 ? PID_in_0 : (trd_active_1 ? PID_in_1 : (trd_active_2 ? PID_in_2 : PID_in_3));
	assign trd_pc_PID = trd_active_0 ? trd_pc_in_0 : (trd_active_1 ? trd_pc_in_1 : (trd_active_2 ? trd_pc_in_2 : trd_pc_in_3));
	assign trd_ass_num_PID = trd_active_0 ? trd_ass_num_0 : (trd_active_1 ? trd_ass_num_1 : (trd_active_2 ? trd_ass_num_2 : trd_ass_num_3));
	assign trd_repeat_num_PID = trd_active_0 ? trd_repeat_num_0 : (& trd_active_1 ? trd_repeat_num_1 : (trd_active_2 ? trd_repeat_num_2 : trd_repeat_num_3));
	assign trd_reg_inherit_num_PID = trd_active_0 ? trd_reg_inherit_0 : (trd_active_1 ? trd_reg_inherit_1 : (trd_active_2 ? trd_reg_inherit_2 : trd_reg_inherit_3));
	assign trd_count_rd_PID = trd_active_0 ? trd_count_rd_0 : (trd_active_1 ? trd_count_rd_1 : (trd_active_2 ? trd_count_rd_2 : trd_count_rd_3));
	assign trd_all_reg_PID = trd_active_0 ? trd_all_reg_0 : (trd_active_1 ? trd_all_reg_1 : (trd_active_2 ? trd_all_reg_2 : trd_all_reg_3));
	//get thread assignment
	wire [2:0] working_trd_count = (trd_PID == PID_in_0) + (trd_PID == PID_in_1) + (trd_PID == PID_in_2) + (trd_PID == PID_in_3);
	wire over_assign = (working_trd_count >= trd_ass_info_PID);
	assign accept_trd_PID = !over_assign & need_trd_PID & (core_active_state != 4'b1111) & !accept_tsk_PID;
	assign full_assign = over_assign & need_trd_PID;
	//effort core
	assign less_core_loc[0] = core_active_state[0] & (!core_active_state[1] | core_active_state[2]);
	assign less_core_loc[1] = core_active_state[0] & core_active_state[1];
	assign core_active_0 = (less_core_loc == 0) & (accept_trd_PID | accept_tsk_PID);
	assign core_active_1 = (less_core_loc == 1) & (accept_trd_PID | accept_tsk_PID);
	assign core_active_2 = (less_core_loc == 2) & (accept_trd_PID | accept_tsk_PID);
	assign core_active_3 = (less_core_loc == 3) & (accept_trd_PID | accept_tsk_PID);
	assign core_start_pc_0 = accept_trd_PID ? trd_start_pc_PID : tsk_pc_PID;
	assign core_start_pc_1 = accept_trd_PID ? trd_start_pc_PID : tsk_pc_PID;
	assign core_start_pc_2 = accept_trd_PID ? trd_start_pc_PID : tsk_pc_PID;
	assign core_start_pc_3 = accept_trd_PID ? trd_start_pc_PID : tsk_pc_PID;
	assign tsk_or_trd_0 = accept_tsk_PID;
	assign tsk_or_trd_1 = accept_tsk_PID;
	assign tsk_or_trd_2 = accept_tsk_PID;
	assign tsk_or_trd_3 = accept_tsk_PID;
	assign cs_reg_rd_0 = less_inherit_loc[0];
	assign cs_reg_rd_1 = less_inherit_loc[1];
	assign cs_reg_rd_2 = less_inherit_loc[2];
	assign cs_reg_rd_3 = less_inherit_loc[3];
	assign cs_reg_data_0 = (insert_repeat_rd[0] == less_inherit_loc[0]) ? insert_repeat_num[0] : insert_reg_data_0[less_inherit_loc[0]];
	assign cs_reg_data_1 = (insert_repeat_rd[1] == less_inherit_loc[1]) ? insert_repeat_num[1] : insert_reg_data_1[less_inherit_loc[1]];
	assign cs_reg_data_2 = (insert_repeat_rd[2] == less_inherit_loc[2]) ? insert_repeat_num[2] : insert_reg_data_2[less_inherit_loc[2]];
	assign cs_reg_data_3 = (insert_repeat_rd[3] == less_inherit_loc[3]) ? insert_repeat_num[3] : insert_reg_data_3[less_inherit_loc[3]];
	assign PID_out_0 = accept_trd_PID ? trd_PID : tsk_PID;
	assign PID_out_1 = accept_trd_PID ? trd_PID : tsk_PID;
	assign PID_out_2 = accept_trd_PID ? trd_PID : tsk_PID;
	assign PID_out_3 = accept_trd_PID ? trd_PID : tsk_PID;
	wire check_5_0 = (insert_inherit_num[0][15:0] == 16'h0000);
	wire [15:0] temp_check_4_0 = check_5_0 ? insert_inherit_num[0][31:16] : insert_inherit_num[0][15:0];
	wire check_4_0 = (temp_check_4_0[7:0] == 8'h00);
	wire [7:0] temp_check_3_0 = check_4_0 ? temp_check_4_0[15:8] : temp_check_4_0[7:0];
	wire check_3_0 = (temp_check_3_0[3:0] == 4'h0);
	wire [3:0] temp_check_2_0 = check_3_0 ? temp_check_3_0[7:4] : temp_check_3_0[3:0];
	wire check_2_0 = (temp_check_2_0[1:0] == 2'b00);
	wire [1:0] temp_check_1_0 = check_2_0 ? temp_check_2_0[3:2] : temp_check_2_0[1:0];
	wire check_1_0 = (temp_check_1_0[0] == 0);
	wire check_5_1 = (insert_inherit_num[1][15:0] == 16'h0000);
	wire [15:0] temp_check_4_1 = check_5_1 ? insert_inherit_num[1][31:16] : insert_inherit_num[1][15:0];
	wire check_4_1 = (temp_check_4_1[7:0] == 8'h00);
	wire [7:0] temp_check_3_1 = check_4_1 ? temp_check_4_1[15:8] : temp_check_4_1[7:0];
	wire check_3_1 = (temp_check_3_1[3:0] == 4'h0);
	wire [3:0] temp_check_2_1 = check_3_1 ? temp_check_3_1[7:4] : temp_check_3_1[3:0];
	wire check_2_1 = (temp_check_2_1[1:0] == 2'b00);
	wire [1:0] temp_check_1_1 = check_2_1 ? temp_check_2_1[3:2] : temp_check_2_1[1:0];
	wire check_1_1 = (temp_check_1_1[0] == 0);
	wire check_5_2 = (insert_inherit_num[2][15:0] == 16'h0000);
	wire [15:0] temp_check_4_2 = check_5_2 ? insert_inherit_num[2][31:16] : insert_inherit_num[2][15:0];
	wire check_4_2 = (temp_check_4_2[7:0] == 8'h00);
	wire [7:0] temp_check_3_2 = check_4_2 ? temp_check_4_2[15:8] : temp_check_4_2[7:0];
	wire check_3_2 = (temp_check_3_2[3:0] == 4'h0);
	wire [3:0] temp_check_2_2 = check_3_2 ? temp_check_3_2[7:4] : temp_check_3_2[3:0];
	wire check_2_2 = (temp_check_2_2[1:0] == 2'b00);
	wire [1:0] temp_check_1_2 = check_2_2 ? temp_check_2_2[3:2] : temp_check_2_2[1:0];
	wire check_1_2 = (temp_check_1_2[0] == 0);
	wire check_5_3 = (insert_inherit_num[3][15:0] == 16'h0000);
	wire [15:0] temp_check_4_3 = check_5_3 ? insert_inherit_num[3][31:16] : insert_inherit_num[3][15:0];
	wire check_4_3 = (temp_check_4_3[7:0] == 8'h00);
	wire [7:0] temp_check_3_3 = check_4_3 ? temp_check_4_3[15:8] : temp_check_4_3[7:0];
	wire check_3_3 = (temp_check_3_3[3:0] == 4'h0);
	wire [3:0] temp_check_2_3 = check_3_3 ? temp_check_3_3[7:4] : temp_check_3_3[3:0];
	wire check_2_3 = (temp_check_2_3[1:0] == 2'b00);
	wire [1:0] temp_check_1_3 = check_2_3 ? temp_check_2_3[3:2] : temp_check_2_3[1:0];
	wire check_1_3 = (temp_check_1_3[0] == 0);
	//multitasking //////////////////////////////////////////////////////////////////////////////////
	wire tsk_active = (tsk_active_0 | tsk_active_1 | tsk_active_2 | tsk_active_3);
	assign system_error_Kernel3 = !enable_create_PID & tsk_active;
	assign sign_up_PID = enable_create_PID & tsk_active;
	assign tsk_pc_register_PID = tsk_active_0 ? tsk_new_pc_0 : (tsk_active_1 ? tsk_new_pc_1 : (tsk_active_2 ? tsk_new_pc_2 : tsk_new_pc_3));
	assign accept_tsk_PID = need_tsk_PID & (core_active_state != 4'b1111);
	//CoreBase Function /////////////////////////////////////////////////////////////////////////////
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			core_active_state							<= 0;
			for (i=0;i<4;i=i+1) begin
				less_inherit_loc[i]						<= 0;
				insert_inherit_num[i]					<= 0;
				insert_all_reg_data[i]					<= 0;
				insert_repeat_num[i]					<= 0;
				insert_repeat_rd[i]						<= 0;
			end
			cs_reg_active_0								<= 0;
			cs_reg_active_1								<= 0;
			cs_reg_active_2								<= 0;
			cs_reg_active_3								<= 0;
		end else begin
			cs_reg_active_0								<= (insert_inherit_num[0] != 0);
			cs_reg_active_1								<= (insert_inherit_num[1] != 0);
			cs_reg_active_2								<= (insert_inherit_num[2] != 0);
			cs_reg_active_3								<= (insert_inherit_num[3] != 0);
			if (cs_reg_active_0) begin
				less_inherit_loc[0]							<= ({check_5_0,check_4_0,check_3_0,check_2_0,check_1_0});
				insert_inherit_num[0][({check_5_0,check_4_0,check_3_0,check_2_0,check_1_0})]	<= 0;
			end
			if (cs_reg_active_1) begin
				less_inherit_loc[1]							<= ({check_5_1,check_4_1,check_3_1,check_2_1,check_1_1});
				insert_inherit_num[1][({check_5_1,check_4_1,check_3_1,check_2_1,check_1_1})]	<= 0;
			end
			if (cs_reg_active_2) begin
				less_inherit_loc[2]							<= ({check_5_2,check_4_2,check_3_2,check_2_2,check_1_2});
				insert_inherit_num[2][({check_5_2,check_4_2,check_3_2,check_2_2,check_1_2})]	<= 0;
			end
			if (cs_reg_active_3) begin
				less_inherit_loc[3]							<= ({check_5_3,check_4_3,check_3_3,check_2_3,check_1_3});
				insert_inherit_num[3][({check_5_3,check_4_3,check_3_3,check_2_3,check_1_3})]	<= 0;
			end
			if (accept_trd_PID | accept_tsk_PID) begin
				core_active_state[less_core_loc]		<= 1;
				insert_repeat_num[less_core_loc]		<= trd_operate_count_PID;
				insert_repeat_rd[less_core_loc]			<= trd_count_rd_info_PID;
				less_inherit_loc[less_core_loc]			<= 1;
				insert_all_reg_data[less_core_loc]		<= trd_inherit_reg_all_PID;
				insert_inherit_num[less_core_loc]		<= need_tsk_inherit ? 32'hFFFFFFFE : trd_reg_inherit_info_PID;
			end
			if (function_finish_0 | thread_finish_0) begin
				core_active_state[0]					<= 0;
			end
			if (function_finish_1 | thread_finish_1) begin
				core_active_state[1]					<= 0;
			end
			if (function_finish_2 | thread_finish_2) begin
				core_active_state[2]					<= 0;
			end
			if (function_finish_3 | thread_finish_3) begin
				core_active_state[3]					<= 0;
			end
		end
	end
	assign insert_reg_data_0[0] = 0;
	assign insert_reg_data_0[1] = insert_all_reg_data[0][31:0];
	assign insert_reg_data_0[2] = insert_all_reg_data[0][63:32];
	assign insert_reg_data_0[3] = insert_all_reg_data[0][95:64];
	assign insert_reg_data_0[4] = insert_all_reg_data[0][127:96];
	assign insert_reg_data_0[5] = insert_all_reg_data[0][159:128];
	assign insert_reg_data_0[6] = insert_all_reg_data[0][191:160];
	assign insert_reg_data_0[7] = insert_all_reg_data[0][223:192];
	assign insert_reg_data_0[8] = insert_all_reg_data[0][255:224];
	assign insert_reg_data_0[9] = insert_all_reg_data[0][287:256];
	assign insert_reg_data_0[10] = insert_all_reg_data[0][319:288];
	assign insert_reg_data_0[11] = insert_all_reg_data[0][351:320];
	assign insert_reg_data_0[12] = insert_all_reg_data[0][383:352];
	assign insert_reg_data_0[13] = insert_all_reg_data[0][415:384];
	assign insert_reg_data_0[14] = insert_all_reg_data[0][447:416];
	assign insert_reg_data_0[15] = insert_all_reg_data[0][479:448];
	assign insert_reg_data_0[16] = insert_all_reg_data[0][511:480];
	assign insert_reg_data_0[17] = insert_all_reg_data[0][543:512];
	assign insert_reg_data_0[18] = insert_all_reg_data[0][575:544];
	assign insert_reg_data_0[19] = insert_all_reg_data[0][607:576];
	assign insert_reg_data_0[20] = insert_all_reg_data[0][639:608];
	assign insert_reg_data_0[21] = insert_all_reg_data[0][671:640];
	assign insert_reg_data_0[22] = insert_all_reg_data[0][703:672];
	assign insert_reg_data_0[23] = insert_all_reg_data[0][735:704];
	assign insert_reg_data_0[24] = insert_all_reg_data[0][767:736];
	assign insert_reg_data_0[25] = insert_all_reg_data[0][799:768];
	assign insert_reg_data_0[26] = insert_all_reg_data[0][831:800];
	assign insert_reg_data_0[27] = insert_all_reg_data[0][863:832];
	assign insert_reg_data_0[28] = insert_all_reg_data[0][895:864];
	assign insert_reg_data_0[29] = insert_all_reg_data[0][927:896];
	assign insert_reg_data_0[30] = insert_all_reg_data[0][959:928];
	assign insert_reg_data_0[31] = insert_all_reg_data[0][991:960];
	assign insert_reg_data_1[0] = 0;
	assign insert_reg_data_1[1] = insert_all_reg_data[1][31:0];
	assign insert_reg_data_1[2] = insert_all_reg_data[1][63:32];
	assign insert_reg_data_1[3] = insert_all_reg_data[1][95:64];
	assign insert_reg_data_1[4] = insert_all_reg_data[1][127:96];
	assign insert_reg_data_1[5] = insert_all_reg_data[1][159:128];
	assign insert_reg_data_1[6] = insert_all_reg_data[1][191:160];
	assign insert_reg_data_1[7] = insert_all_reg_data[1][223:192];
	assign insert_reg_data_1[8] = insert_all_reg_data[1][255:224];
	assign insert_reg_data_1[9] = insert_all_reg_data[1][287:256];
	assign insert_reg_data_1[10] = insert_all_reg_data[1][319:288];
	assign insert_reg_data_1[11] = insert_all_reg_data[1][351:320];
	assign insert_reg_data_1[12] = insert_all_reg_data[1][383:352];
	assign insert_reg_data_1[13] = insert_all_reg_data[1][415:384];
	assign insert_reg_data_1[14] = insert_all_reg_data[1][447:416];
	assign insert_reg_data_1[15] = insert_all_reg_data[1][479:448];
	assign insert_reg_data_1[16] = insert_all_reg_data[1][511:480];
	assign insert_reg_data_1[17] = insert_all_reg_data[1][543:512];
	assign insert_reg_data_1[18] = insert_all_reg_data[1][575:544];
	assign insert_reg_data_1[19] = insert_all_reg_data[1][607:576];
	assign insert_reg_data_1[20] = insert_all_reg_data[1][639:608];
	assign insert_reg_data_1[21] = insert_all_reg_data[1][671:640];
	assign insert_reg_data_1[22] = insert_all_reg_data[1][703:672];
	assign insert_reg_data_1[23] = insert_all_reg_data[1][735:704];
	assign insert_reg_data_1[24] = insert_all_reg_data[1][767:736];
	assign insert_reg_data_1[25] = insert_all_reg_data[1][799:768];
	assign insert_reg_data_1[26] = insert_all_reg_data[1][831:800];
	assign insert_reg_data_1[27] = insert_all_reg_data[1][863:832];
	assign insert_reg_data_1[28] = insert_all_reg_data[1][895:864];
	assign insert_reg_data_1[29] = insert_all_reg_data[1][927:896];
	assign insert_reg_data_1[30] = insert_all_reg_data[1][959:928];
	assign insert_reg_data_1[31] = insert_all_reg_data[1][991:960];
	assign insert_reg_data_2[0] = 0;
	assign insert_reg_data_2[1] = insert_all_reg_data[2][31:0];
	assign insert_reg_data_2[2] = insert_all_reg_data[2][63:32];
	assign insert_reg_data_2[3] = insert_all_reg_data[2][95:64];
	assign insert_reg_data_2[4] = insert_all_reg_data[2][127:96];
	assign insert_reg_data_2[5] = insert_all_reg_data[2][159:128];
	assign insert_reg_data_2[6] = insert_all_reg_data[2][191:160];
	assign insert_reg_data_2[7] = insert_all_reg_data[2][223:192];
	assign insert_reg_data_2[8] = insert_all_reg_data[2][255:224];
	assign insert_reg_data_2[9] = insert_all_reg_data[2][287:256];
	assign insert_reg_data_2[10] = insert_all_reg_data[2][319:288];
	assign insert_reg_data_2[11] = insert_all_reg_data[2][351:320];
	assign insert_reg_data_2[12] = insert_all_reg_data[2][383:352];
	assign insert_reg_data_2[13] = insert_all_reg_data[2][415:384];
	assign insert_reg_data_2[14] = insert_all_reg_data[2][447:416];
	assign insert_reg_data_2[15] = insert_all_reg_data[2][479:448];
	assign insert_reg_data_2[16] = insert_all_reg_data[2][511:480];
	assign insert_reg_data_2[17] = insert_all_reg_data[2][543:512];
	assign insert_reg_data_2[18] = insert_all_reg_data[2][575:544];
	assign insert_reg_data_2[19] = insert_all_reg_data[2][607:576];
	assign insert_reg_data_2[20] = insert_all_reg_data[2][639:608];
	assign insert_reg_data_2[21] = insert_all_reg_data[2][671:640];
	assign insert_reg_data_2[22] = insert_all_reg_data[2][703:672];
	assign insert_reg_data_2[23] = insert_all_reg_data[2][735:704];
	assign insert_reg_data_2[24] = insert_all_reg_data[2][767:736];
	assign insert_reg_data_2[25] = insert_all_reg_data[2][799:768];
	assign insert_reg_data_2[26] = insert_all_reg_data[2][831:800];
	assign insert_reg_data_2[27] = insert_all_reg_data[2][863:832];
	assign insert_reg_data_2[28] = insert_all_reg_data[2][895:864];
	assign insert_reg_data_2[29] = insert_all_reg_data[2][927:896];
	assign insert_reg_data_2[30] = insert_all_reg_data[2][959:928];
	assign insert_reg_data_2[31] = insert_all_reg_data[2][991:960];
	assign insert_reg_data_3[0] = 0;
	assign insert_reg_data_3[1] = insert_all_reg_data[3][31:0];
	assign insert_reg_data_3[2] = insert_all_reg_data[3][63:32];
	assign insert_reg_data_3[3] = insert_all_reg_data[3][95:64];
	assign insert_reg_data_3[4] = insert_all_reg_data[3][127:96];
	assign insert_reg_data_3[5] = insert_all_reg_data[3][159:128];
	assign insert_reg_data_3[6] = insert_all_reg_data[3][191:160];
	assign insert_reg_data_3[7] = insert_all_reg_data[3][223:192];
	assign insert_reg_data_3[8] = insert_all_reg_data[3][255:224];
	assign insert_reg_data_3[9] = insert_all_reg_data[3][287:256];
	assign insert_reg_data_3[10] = insert_all_reg_data[3][319:288];
	assign insert_reg_data_3[11] = insert_all_reg_data[3][351:320];
	assign insert_reg_data_3[12] = insert_all_reg_data[3][383:352];
	assign insert_reg_data_3[13] = insert_all_reg_data[3][415:384];
	assign insert_reg_data_3[14] = insert_all_reg_data[3][447:416];
	assign insert_reg_data_3[15] = insert_all_reg_data[3][479:448];
	assign insert_reg_data_3[16] = insert_all_reg_data[3][511:480];
	assign insert_reg_data_3[17] = insert_all_reg_data[3][543:512];
	assign insert_reg_data_3[18] = insert_all_reg_data[3][575:544];
	assign insert_reg_data_3[19] = insert_all_reg_data[3][607:576];
	assign insert_reg_data_3[20] = insert_all_reg_data[3][639:608];
	assign insert_reg_data_3[21] = insert_all_reg_data[3][671:640];
	assign insert_reg_data_3[22] = insert_all_reg_data[3][703:672];
	assign insert_reg_data_3[23] = insert_all_reg_data[3][735:704];
	assign insert_reg_data_3[24] = insert_all_reg_data[3][767:736];
	assign insert_reg_data_3[25] = insert_all_reg_data[3][799:768];
	assign insert_reg_data_3[26] = insert_all_reg_data[3][831:800];
	assign insert_reg_data_3[27] = insert_all_reg_data[3][863:832];
	assign insert_reg_data_3[28] = insert_all_reg_data[3][895:864];
	assign insert_reg_data_3[29] = insert_all_reg_data[3][927:896];
	assign insert_reg_data_3[30] = insert_all_reg_data[3][959:928];
	assign insert_reg_data_3[31] = insert_all_reg_data[3][991:960];
endmodule