`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/18 12:37:30
// Design Name: 
// Module Name: Stall_Flush_determine
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


module Stall_Flush_determine(
	input finish_function, finish_thread, exe_stall_forward, exe_stall_div_rem, L2_data_wait_stall, core_control_active, context_switch_active,
	output inf_stall, inf_flush, ind_stall, ind_flush, exe_stall, exe_flush, mem_flush
	);
	assign inf_stall = (exe_stall_forward | exe_stall_div_rem | L2_data_wait_stall);
	assign inf_flush = (!core_control_active & context_switch_active) | finish_function | finish_thread;
	assign ind_stall = inf_stall;
	assign ind_flush = context_switch_active | finish_function | finish_thread;
	assign exe_stall = L2_data_wait_stall;
	assign exe_flush = (exe_stall_forward | exe_stall_div_rem) | ind_flush;
	assign mem_flush = L2_data_wait_stall | ind_flush;
endmodule