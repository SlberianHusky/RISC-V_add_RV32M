`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/18 07:56:34
// Design Name: 
// Module Name: Divide_Remain_Unit
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


module Divide_Remain_Unit(
	input clk, reset,
	input request,
	input [2:0] core_num,
	input [1:0] order,
	input [31:0] rs1, rs2,
	output ready_0, ready_1, ready_2, ready_3,
	output [31:0] ans_0, ans_1, ans_2, ans_3
	);
	//START
	reg request_0, unnecessary_step, rem_or_div_0, sign_state_0;
	reg [2:0] core_num_0;
	reg [4:0] shift_stack_0, shift_save_0;
	reg [31:0] dividend_0, divisor_0, remain_save;
	//Step
	wire [31:0] dividend_1, dividend_2, dividend_3, dividend_4, dividend_5, dividend_6, dividend_7, dividend_8;
	wire [31:0] divisor_1, divisor_2, divisor_3, divisor_4, divisor_5, divisor_6, divisor_7, divisor_8;
	wire [31:0] proc_data_1, proc_data_2, proc_data_3, proc_data_4, proc_data_5, proc_data_6, proc_data_7, proc_data_8;
	wire [4:0] shift_stack_1, shift_stack_2, shift_stack_3, shift_stack_4, shift_stack_5, shift_stack_6, shift_stack_7, shift_stack_8;
	wire [4:0] shift_save_1, shift_save_2, shift_save_3, shift_save_4, shift_save_5, shift_save_6, shift_save_7, shift_save_8;
	wire [2:0] core_num_1, core_num_2, core_num_3, core_num_4, core_num_5, core_num_6, core_num_7, core_num_8;
	wire request_1, request_2, request_3, request_4, request_5, request_6, request_7, request_8;
	wire sign_state_1, sign_state_2, sign_state_3, sign_state_4, sign_state_5, sign_state_6, sign_state_7, sign_state_8;
	wire rem_or_div_1, rem_or_div_2, rem_or_div_3, rem_or_div_4, rem_or_div_5, rem_or_div_6, rem_or_div_7, rem_or_div_8;
	wire ready_step1, ready_step2, ready_step3, ready_step4, ready_step5, ready_step6, ready_step7, ready_step8;
	//End
	reg ready [0:3];
	reg [31:0] ans [0:3];
	//START stage/////////////////////////////////////////////////////////////////////////////////////
	wire sign_state_A = (~order[0]) && rs1[31];
	wire sign_state_B = (~order[0]) && rs2[31];
	wire [31:0] in_acc_A = (sign_state_A) ? (-rs1) : rs1;
	wire [31:0] in_acc_B = (sign_state_B) ? (-rs2) : rs2;
	wire sign_state_determine = (order[1]) ? sign_state_A : (sign_state_A^sign_state_B);
	
	wire check_16_A = (in_acc_A[31:16] == 16'h0000);
	wire [15:0] in_acc_A_check_8 = (check_16_A) ? in_acc_A[15:0] : in_acc_A[31:16];
	wire check_8_A = (in_acc_A_check_8[15:8] == 8'h00);
	wire [7:0] in_acc_A_check_4 = (check_8_A) ? in_acc_A_check_8[7:0] : in_acc_A_check_8[15:8];
	wire check_4_A = (in_acc_A_check_4[7:4] == 4'h0);
	wire [3:0] in_acc_A_check_2 = (check_4_A) ? in_acc_A_check_4[3:0] : in_acc_A_check_4[7:4];
	wire check_2_A = (in_acc_A_check_2[3:2] == 2'b00);
	wire [1:0] in_acc_A_check_1 = (check_2_A) ? in_acc_A_check_2[1:0] : in_acc_A_check_2[3:2];
	wire check_1_A = (in_acc_A_check_1[1] == 0);
	wire [4:0] shift_stack_count_A = ({check_16_A,check_8_A,check_4_A,check_2_A,check_1_A});
	
	wire check_16_B = (in_acc_B[31:16] == 16'h0000);
	wire [15:0] in_acc_B_check_8 = (check_16_B) ? in_acc_B[15:0] : in_acc_B[31:16];
	wire check_8_B = (in_acc_B_check_8[15:8] == 8'h00);
	wire [7:0] in_acc_B_check_4 = (check_8_B) ? in_acc_B_check_8[7:0] : in_acc_B_check_8[15:8];
	wire check_4_B = (in_acc_B_check_4[7:4] == 4'h0);
	wire [3:0] in_acc_B_check_2 = (check_4_B) ? in_acc_B_check_4[3:0] : in_acc_B_check_4[7:4];
	wire check_2_B = (in_acc_B_check_2[3:2] == 2'b00);
	wire [1:0] in_acc_B_check_1 = (check_2_B) ? in_acc_B_check_2[1:0] : in_acc_B_check_2[3:2];
	wire check_1_B = (in_acc_B_check_1[1] == 0);
	wire [4:0] shift_stack_count_B = ({check_16_B,check_8_B,check_4_B,check_2_B,check_1_B});
	
	wire step_require = !(shift_stack_count_A > shift_stack_count_B);
	wire [31:0] in_acc_A_shift = (in_acc_A << shift_stack_count_A);
	wire [31:0] in_acc_B_shift = (in_acc_B << shift_stack_count_B);
	wire [4:0] shift_stack_count = shift_stack_count_B - shift_stack_count_A;
	
	always@(posedge clk, negedge reset) begin
		if(!reset | ~request) begin
			request_0			<= 0;
			unnecessary_step	<= 0;
			rem_or_div_0		<= 0;
			sign_state_0		<= 0;
			core_num_0			<= 0;
			shift_stack_0		<= 0;
			shift_save_0		<= 0;
			dividend_0			<= 0;
			divisor_0			<= 0;
			remain_save			<= 0;
		end else if(request) begin
			request_0			<= request;
			unnecessary_step	<= ~step_require;
			rem_or_div_0		<= order[1];
			sign_state_0		<= sign_state_determine;
			core_num_0			<= core_num;
			shift_stack_0		<= shift_stack_count;
			shift_save_0		<= shift_stack_count_A;
			dividend_0			<= in_acc_A_shift;
			divisor_0			<= in_acc_B_shift;
			remain_save			<= in_acc_A;
		end else begin
			request_0			<= 0;
		end
	end
	//Step stage//////////////////////////////////////////////////////////////////////////////////////
	div_rem_step Step1(
		.clk(clk), .reset(reset),
		.request_in(request_0 & ~unnecessary_step),
		.sign_state_in(sign_state_0),
		.rem_or_div_in(rem_or_div_0),
		.core_num_in(core_num_0),
		.shift_stack_in(shift_stack_0),
		.shift_save_in(shift_save_0),
		.dividend_in(dividend_0),
		.divisor_in(divisor_0),
		.proc_data_in(32'h00000000),
										.dividend_out(dividend_1),
										.divisor_out(divisor_1),
										.proc_data_out(proc_data_1),
										.shift_stack_out(shift_stack_1),
										.shift_save_out(shift_save_1),
										.core_num_out(core_num_1),
										.request_out(request_1),
										.sign_state_out(sign_state_1),
										.rem_or_div_out(rem_or_div_1),
										.ready_out(ready_step1)
	);
	div_rem_step Step2(
		.clk(clk), .reset(reset),
		.request_in(request_1),
		.sign_state_in(sign_state_1),
		.rem_or_div_in(rem_or_div_1),
		.core_num_in(core_num_1),
		.shift_stack_in(shift_stack_1),
		.shift_save_in(shift_save_1),
		.dividend_in(dividend_1),
		.divisor_in(divisor_1),
		.proc_data_in(proc_data_1),
										.dividend_out(dividend_2),
										.divisor_out(divisor_2),
										.proc_data_out(proc_data_2),
										.shift_stack_out(shift_stack_2),
										.shift_save_out(shift_save_2),
										.core_num_out(core_num_2),
										.request_out(request_2),
										.sign_state_out(sign_state_2),
										.rem_or_div_out(rem_or_div_2),
										.ready_out(ready_step2)
	);
	div_rem_step Step3(
		.clk(clk), .reset(reset),
		.request_in(request_2),
		.sign_state_in(sign_state_2),
		.rem_or_div_in(rem_or_div_2),
		.core_num_in(core_num_2),
		.shift_stack_in(shift_stack_2),
		.shift_save_in(shift_save_2),
		.dividend_in(dividend_2),
		.divisor_in(divisor_2),
		.proc_data_in(proc_data_2),
										.dividend_out(dividend_3),
										.divisor_out(divisor_3),
										.proc_data_out(proc_data_3),
										.shift_stack_out(shift_stack_3),
										.shift_save_out(shift_save_3),
										.core_num_out(core_num_3),
										.request_out(request_3),
										.sign_state_out(sign_state_3),
										.rem_or_div_out(rem_or_div_3),
										.ready_out(ready_step3)
	);
	div_rem_step Step4(
		.clk(clk), .reset(reset),
		.request_in(request_3),
		.sign_state_in(sign_state_3),
		.rem_or_div_in(rem_or_div_3),
		.core_num_in(core_num_3),
		.shift_stack_in(shift_stack_3),
		.shift_save_in(shift_save_3),
		.dividend_in(dividend_3),
		.divisor_in(divisor_3),
		.proc_data_in(proc_data_3),
										.dividend_out(dividend_4),
										.divisor_out(divisor_4),
										.proc_data_out(proc_data_4),
										.shift_stack_out(shift_stack_4),
										.shift_save_out(shift_save_4),
										.core_num_out(core_num_4),
										.request_out(request_4),
										.sign_state_out(sign_state_4),
										.rem_or_div_out(rem_or_div_4),
										.ready_out(ready_step4)
	);
	div_rem_step Step5(
		.clk(clk), .reset(reset),
		.request_in(request_4),
		.sign_state_in(sign_state_4),
		.rem_or_div_in(rem_or_div_4),
		.core_num_in(core_num_4),
		.shift_stack_in(shift_stack_4),
		.shift_save_in(shift_save_4),
		.dividend_in(dividend_4),
		.divisor_in(divisor_4),
		.proc_data_in(proc_data_4),
										.dividend_out(dividend_5),
										.divisor_out(divisor_5),
										.proc_data_out(proc_data_5),
										.shift_stack_out(shift_stack_5),
										.shift_save_out(shift_save_5),
										.core_num_out(core_num_5),
										.request_out(request_5),
										.sign_state_out(sign_state_5),
										.rem_or_div_out(rem_or_div_5),
										.ready_out(ready_step5)
	);
	div_rem_step Step6(
		.clk(clk), .reset(reset),
		.request_in(request_5),
		.sign_state_in(sign_state_5),
		.rem_or_div_in(rem_or_div_5),
		.core_num_in(core_num_5),
		.shift_stack_in(shift_stack_5),
		.shift_save_in(shift_save_5),
		.dividend_in(dividend_5),
		.divisor_in(divisor_5),
		.proc_data_in(proc_data_5),
										.dividend_out(dividend_6),
										.divisor_out(divisor_6),
										.proc_data_out(proc_data_6),
										.shift_stack_out(shift_stack_6),
										.shift_save_out(shift_save_6),
										.core_num_out(core_num_6),
										.request_out(request_6),
										.sign_state_out(sign_state_6),
										.rem_or_div_out(rem_or_div_6),
										.ready_out(ready_step6)
	);
	div_rem_step Step7(
		.clk(clk), .reset(reset),
		.request_in(request_6),
		.sign_state_in(sign_state_6),
		.rem_or_div_in(rem_or_div_6),
		.core_num_in(core_num_6),
		.shift_stack_in(shift_stack_6),
		.shift_save_in(shift_save_6),
		.dividend_in(dividend_6),
		.divisor_in(divisor_6),
		.proc_data_in(proc_data_6),
										.dividend_out(dividend_7),
										.divisor_out(divisor_7),
										.proc_data_out(proc_data_7),
										.shift_stack_out(shift_stack_7),
										.shift_save_out(shift_save_7),
										.core_num_out(core_num_7),
										.request_out(request_7),
										.sign_state_out(sign_state_7),
										.rem_or_div_out(rem_or_div_7),
										.ready_out(ready_step7)
	);
	div_rem_step Step8(
		.clk(clk), .reset(reset),
		.request_in(request_7),
		.sign_state_in(sign_state_7),
		.rem_or_div_in(rem_or_div_7),
		.core_num_in(core_num_7),
		.shift_stack_in(shift_stack_7),
		.shift_save_in(shift_save_7),
		.dividend_in(dividend_7),
		.divisor_in(divisor_7),
		.proc_data_in(proc_data_7),
										.dividend_out(dividend_8),
										.divisor_out(divisor_8),
										.proc_data_out(proc_data_8),
										.shift_stack_out(shift_stack_8),
										.shift_save_out(shift_save_8),
										.core_num_out(core_num_8),
										.request_out(request_8),
										.sign_state_out(sign_state_8),
										.rem_or_div_out(rem_or_div_8),
										.ready_out(ready_step8)
	);
	//End stage///////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] result_temp_0 = rem_or_div_0 ? remain_save : 0;
	wire [31:0] result_temp_1 = rem_or_div_1 ? (dividend_1 >> shift_save_1) : proc_data_1;
	wire [31:0] result_temp_2 = rem_or_div_2 ? (dividend_2 >> shift_save_2) : proc_data_2;
	wire [31:0] result_temp_3 = rem_or_div_3 ? (dividend_3 >> shift_save_3) : proc_data_3;
	wire [31:0] result_temp_4 = rem_or_div_4 ? (dividend_4 >> shift_save_4) : proc_data_4;
	wire [31:0] result_temp_5 = rem_or_div_5 ? (dividend_5 >> shift_save_5) : proc_data_5;
	wire [31:0] result_temp_6 = rem_or_div_6 ? (dividend_6 >> shift_save_6) : proc_data_6;
	wire [31:0] result_temp_7 = rem_or_div_7 ? (dividend_7 >> shift_save_7) : proc_data_7;
	wire [31:0] result_temp_8 = rem_or_div_8 ? (dividend_8 >> shift_save_8) : proc_data_8;
	
	wire [31:0] result_0 = sign_state_0 ? (-result_temp_0) : result_temp_0;
	wire [31:0] result_1 = sign_state_1 ? (-result_temp_1) : result_temp_1;
	wire [31:0] result_2 = sign_state_2 ? (-result_temp_2) : result_temp_2;
	wire [31:0] result_3 = sign_state_3 ? (-result_temp_3) : result_temp_3;
	wire [31:0] result_4 = sign_state_4 ? (-result_temp_4) : result_temp_4;
	wire [31:0] result_5 = sign_state_5 ? (-result_temp_5) : result_temp_5;
	wire [31:0] result_6 = sign_state_6 ? (-result_temp_6) : result_temp_6;
	wire [31:0] result_7 = sign_state_7 ? (-result_temp_7) : result_temp_7;
	wire [31:0] result_8 = sign_state_8 ? (-result_temp_8) : result_temp_8;
	
	always@(posedge clk, negedge reset) begin
		if(!reset) begin
			ready[0]				<= 0;
			ready[1]				<= 0;
			ready[2]				<= 0;
			ready[3]				<= 0;
			ans[0]					<= 0;
			ans[1]					<= 0;
			ans[2]					<= 0;
			ans[3]					<= 0;
		end else begin
			if (unnecessary_step && request_0) begin
				ready[core_num_0[1:0]]	<= 1;
				ans[core_num_0[1:0]]	<= result_0;
			end
			if (ready_step1) begin
				ready[core_num_1[1:0]]	<= 1;
				ans[core_num_1[1:0]]	<= result_1;
			end
			if (ready_step2) begin
				ready[core_num_2[1:0]]	<= 1;
				ans[core_num_2[1:0]]	<= result_2;
			end
			if (ready_step3) begin
				ready[core_num_3[1:0]]	<= 1;
				ans[core_num_3[1:0]]	<= result_3;
			end
			if (ready_step4) begin
				ready[core_num_4[1:0]]	<= 1;
				ans[core_num_4[1:0]]	<= result_4;
			end
			if (ready_step5) begin
				ready[core_num_5[1:0]]	<= 1;
				ans[core_num_5[1:0]]	<= result_5;
			end
			if (ready_step6) begin
				ready[core_num_6[1:0]]	<= 1;
				ans[core_num_6[1:0]]	<= result_6;
			end
			if (ready_step7) begin
				ready[core_num_7[1:0]]	<= 1;
				ans[core_num_7[1:0]]	<= result_7;
			end
			if (ready_step8) begin
				ready[core_num_8[1:0]]	<= 1;
				ans[core_num_8[1:0]]	<= result_8;
			end
			if (ready[0]) begin
				ready[0]			<= 0;
			end
			if (ready[1]) begin
				ready[1]			<= 0;
			end
			if (ready[2]) begin
				ready[2]			<= 0;
			end
			if (ready[3]) begin
				ready[3]			<= 0;
			end
		end
	end
	
	assign ready_0 = ready[0];
	assign ready_1 = ready[1];
	assign ready_2 = ready[2];
	assign ready_3 = ready[3];
	assign ans_0 = ans[0];
	assign ans_1 = ans[1];
	assign ans_2 = ans[2];
	assign ans_3 = ans[3];
endmodule