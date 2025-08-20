`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/18 07:58:47
// Design Name: 
// Module Name: div_rem_step
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


module div_rem_step(
	input clk, reset,
	input request_in, sign_state_in, rem_or_div_in,
	input [2:0] core_num_in,
	input [4:0] shift_stack_in, shift_save_in,
	input [31:0] dividend_in, divisor_in, proc_data_in,
	output reg [31:0] dividend_out, divisor_out, proc_data_out,
	output reg [4:0] shift_stack_out, shift_save_out,
	output reg [2:0] core_num_out,
	output reg request_out, sign_state_out, rem_or_div_out,
	output reg ready_out
	);
	wire step1 = ($unsigned(dividend_in) < $unsigned(divisor_in));
	wire [31:0] step1_dividend = (step1) ? dividend_in : (dividend_in - divisor_in);
	wire [31:0] step1_divisor = (divisor_in >> 1);
	
	wire step2 = ($unsigned(step1_dividend) < $unsigned(step1_divisor));
	wire [31:0] step2_dividend = (step2) ? step1_dividend : (step1_dividend - step1_divisor);
	wire [31:0] step2_divisor = (step1_divisor >> 1);
	
	wire step3 = ($unsigned(step2_dividend) < $unsigned(step2_divisor));
	wire [31:0] step3_dividend = (step3) ? step2_dividend : (step2_dividend - step2_divisor);
	wire [31:0] step3_divisor = (step2_divisor >> 1);
	
	wire step4 = ($unsigned(step3_dividend) < $unsigned(step3_divisor));
	wire [31:0] step4_dividend = (step4) ? step3_dividend : (step3_dividend - step3_divisor);
	wire [31:0] step4_divisor = (step3_divisor >> 1);
	
	wire [31:0] result_temp_1 = ({proc_data_in[30:0],!step1});
	wire [31:0] result_temp_2 = ({proc_data_in[29:0],!step1,!step2});
	wire [31:0] result_temp_3 = ({proc_data_in[28:0],!step1,!step2,!step3});
	wire [31:0] result_temp_4 = ({proc_data_in[27:0],!step1,!step2,!step3,!step4});
	
	wire finish_step1 = (shift_stack_in == 0);
	wire finish_step2 = (shift_stack_in == 1);
	wire finish_step3 = (shift_stack_in == 2);
	wire finish = (shift_stack_in < 4);
	always@(posedge clk, negedge reset) begin
		if(!reset) begin
			dividend_out			<= 0;
			divisor_out				<= 0;
			proc_data_out			<= 0;
			shift_stack_out			<= 0;
			shift_save_out			<= 0;
			core_num_out			<= 0;
			request_out				<= 0;
			sign_state_out			<= 0;
			rem_or_div_out			<= 0;
			ready_out				<= 0;
		end else begin
			dividend_out			<= finish_step1 ? step1_dividend : (finish_step2 ? step2_dividend : (finish_step3 ? step3_dividend : step4_dividend));
			divisor_out				<= step4_divisor;
			proc_data_out			<= finish_step1 ? result_temp_1 : (finish_step2 ? result_temp_2 : (finish_step3 ? result_temp_3 : result_temp_4));
			shift_stack_out			<= shift_stack_in - 4;
			shift_save_out			<= shift_save_in;
			core_num_out			<= core_num_in;
			request_out				<= finish ? 0 : request_in;
			sign_state_out			<= sign_state_in;
			rem_or_div_out			<= rem_or_div_in;
			ready_out				<= finish && request_in;
		end
	end
endmodule