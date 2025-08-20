`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/02 23:53:48
// Design Name: 
// Module Name: PID_Queue
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


module PID_Queue(
	//clock reset
	input clk, reset,
	//create or delete PID
	output enable_create_PID,
	input sign_up_PID,
	input [7:0] disable_PID,
	input disable_PID_active,
	//multithreading register
	input trd_request_valid,
	input [7:0] trd_request_PID,
	input [31:0] trd_pc_PID,
	input [4:0] trd_ass_num_PID,
	input [31:0] trd_repeat_num_PID, trd_reg_inherit_num_PID,
	input [4:0] trd_count_rd_PID,
	input [991:0] trd_all_reg_PID,
	//request multithreading
	output need_trd_PID,
	input accept_trd_PID, full_assign,
	output [7:0] trd_PID,										//PID number for threading
	output [31:0] trd_start_pc_PID,								//pc for threading
	output [4:0] trd_ass_info_PID,								//worker number for threading
	output [31:0] trd_reg_inherit_info_PID,						//inherit reg number for threading
	output [4:0] trd_count_rd_info_PID,							//reg number for threading number
	output [31:0] trd_operate_count_PID,						//threading number
	output [991:0] trd_inherit_reg_all_PID,						//all reg data for inherit
	input finish_threading,										//inform PID (finish threading)
	input [7:0] finish_trd_PID,									//return PID (finish threading) for disable
	input [31:0] finish_trd_pc,
	//multitasking register
	input [31:0] tsk_pc_register_PID,
	//request multitasking
	output need_tsk_PID,
	output need_tsk_inherit,
	input accept_tsk_PID,
	output [7:0] tsk_PID,
	output [31:0] tsk_pc_PID,
	//L2 Cache interact
	output new_PID_L2,
	output [7:0] PID_register_L2,
	output disable_PID_L2,
	output [7:0] PID_discard_L2,
	output un_lock_active_L2,
	output [7:0] un_lock_PID_L2
	);
	//basic system prepare
	reg [1:0] PID_memory_valid;
	reg [7:0] PID_less;
	reg [1:0] PID_not_operate;
	reg [31:0] trd_operate_count [0:1];
	reg [31:0] trd_pc_loc [0:1];
	reg [1:0] need_inherit_tsk;
	(* ram_style = "block" *) reg [1105:0] PID_queue [0:1];
	//basic system //////////////////////////////////////////////////////////////////////////////////////////
	assign enable_create_PID = (PID_memory_valid != 2'b11);
	wire less_loc = PID_memory_valid[0];
	wire del_loc = (PID_queue[0][1105:1098] != disable_PID);
	wire trd_loc = (PID_queue[0][1105:1098] != trd_request_PID);
	wire fin_trd_loc = (PID_queue[0][1105:1098] != finish_trd_PID);
	wire [1:0] need_trd_list = ({(PID_queue[1][1060:1029] != 0),(PID_queue[0][1060:1029] != 0)});
	reg trd_lotate_count;
	reg tsk_lotate_count;
	assign need_trd_PID = (need_trd_list != 0);
	assign need_tsk_PID = (PID_not_operate != 0);
	integer i;
	always @(posedge clk, negedge  reset) begin
		if(!reset) begin
			PID_memory_valid									<= 2'b01;
			PID_less											<= 2;
			PID_not_operate										<= 2'b01;
			PID_queue[0][1097 : 0]								<= 0;
			PID_queue[0][1105 : 1098]							<= 1;
			PID_queue[1]										<= 0;
			for (i=0;i<2;i=i+1) begin
				trd_operate_count[i]							<= 32'h00000001;
				trd_pc_loc[i]									<= 0;
				need_inherit_tsk[i]								<= 0;
			end
			trd_lotate_count									<= 0;
			tsk_lotate_count									<= 0;
		end else begin
			if (sign_up_PID) begin
				PID_queue[less_loc][1105:1066]					<= ({PID_less,tsk_pc_register_PID});
				PID_memory_valid[less_loc]						<= 1;
				PID_less										<= PID_less + 1;
				PID_not_operate[less_loc]						<= 1;
			end
			if (disable_PID_active) begin
				PID_queue[del_loc]								<= 0;
				PID_memory_valid[del_loc]						<= 0;
				PID_not_operate[del_loc]						<= 0;
				trd_operate_count[del_loc]						<= 32'h00000001;
				need_inherit_tsk[del_loc]						<= 0;
			end
			if (trd_request_valid) begin
				PID_queue[trd_loc][1065:0]						<= ({trd_ass_num_PID,trd_repeat_num_PID,trd_reg_inherit_num_PID,trd_count_rd_PID,trd_all_reg_PID});
				trd_operate_count[trd_loc]						<= 32'h00000001;
				trd_pc_loc[trd_loc]								<= trd_pc_PID;
			end
			if (finish_threading) begin
				PID_not_operate[fin_trd_loc]					<= !need_trd_list[fin_trd_loc];
				if (!need_trd_list[fin_trd_loc]) begin
					PID_queue[fin_trd_loc][1097 : 1066]			<= finish_trd_pc;
					need_inherit_tsk[fin_trd_loc]				<= 1;
				end
			end
			if (need_trd_PID) begin
				if (accept_trd_PID | full_assign) begin
					trd_lotate_count							<= !need_trd_list[0] | (need_trd_list[1] & !trd_lotate_count);
				end
				if (accept_trd_PID) begin
					PID_queue[trd_lotate_count][1060 : 1029]	<= PID_queue[trd_lotate_count][1060 : 1029] - 1;
					trd_operate_count[trd_lotate_count]			<= trd_operate_count[trd_lotate_count] + 1;
				end
			end
			if (need_tsk_PID) begin
				if (accept_tsk_PID) begin
					tsk_lotate_count							<= !PID_not_operate[0] | (PID_not_operate[1] & !tsk_lotate_count);
					PID_not_operate[tsk_lotate_count]			<= 0;
				end
			end
		end
	end
	//multithreading system /////////////////////////////////////////////////////////////////////////////////
	wire temp_inherit_count = need_tsk_PID ? tsk_lotate_count : trd_lotate_count;
	assign trd_PID = PID_queue[trd_lotate_count][1105 : 1098];
	assign trd_start_pc_PID = trd_pc_loc[trd_lotate_count];
	assign trd_ass_info_PID = PID_queue[trd_lotate_count][1065 : 1061];
	assign trd_reg_inherit_info_PID = PID_queue[trd_lotate_count][1028 : 997];
	assign trd_count_rd_info_PID = PID_queue[trd_lotate_count][996 : 992];
	assign trd_operate_count_PID = trd_operate_count[trd_lotate_count];
	assign trd_inherit_reg_all_PID = PID_queue[temp_inherit_count][991 : 0];
	//multitasking system ///////////////////////////////////////////////////////////////////////////////////
	assign need_tsk_inherit = need_inherit_tsk[tsk_lotate_count];
	assign tsk_PID = PID_queue[tsk_lotate_count][1105 : 1098];
	assign tsk_pc_PID = PID_queue[tsk_lotate_count][1097 : 1066];
	assign tsk_inherit_reg_all_PID = PID_queue[tsk_lotate_count][991 : 0];
	//L2 Cache interact /////////////////////////////////////////////////////////////////////////////////////
	assign new_PID_L2 = sign_up_PID;
	assign PID_register_L2 = PID_less;
	assign disable_PID_L2 = disable_PID_active;
	assign PID_discard_L2 = disable_PID;
	assign un_lock_active_L2 = finish_threading & !need_trd_list[fin_trd_loc];
	assign un_lock_PID_L2 = finish_trd_PID;
endmodule