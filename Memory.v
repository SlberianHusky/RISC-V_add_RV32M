`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/18 12:41:34
// Design Name: 
// Module Name: Memory
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


module Memory(
	//clock reset
	input clk, reset,
	//forward for Branch
	input [31:0] mem_forward_data,
	output taken,
	//input from Execution
	input br_0, br_1, br_2, br_3, br_4, br_5, byte, half, word, unsign, Rs1_branch_forward, Rs2_branch_forward,
	input Ctl_MemtoReg_in, Ctl_RegWrite_in, Ctl_MemWrite_in, multi_thread_set_in, multi_task_set_in, finish_function_in,
	input [4:0] Rd_in,
	input [31:0] ALUresult_in, ReadData1, ReadData2, PC_in,
	//for jalr_forward
	output [4:0] jalr_forward_Rd,
	output jalr_forward_Ctl_RegWrite, jalr_forward_Ctl_MemtoReg,
	//L2_Cache interaction
	output read_request_active, write_request_active, address_start_end_same,
	output [28:0] address_to_L2,
	output refresh_data_loc,		//L2 Cache coherence
	output [31:0] refresh_data_to_L2,
	input L2_operate_ready,		//If another process is using the data for 'Read', it must be 0.
	input [63:0] data_from_L2,
	input rewrite_active,
	input [28:0] rewrite_address,
	//multithread, multitask interaction
	output reg [31:0] thread_finish_pc,
	output reg multi_thread_set_out, multi_task_set_out, finish_function_out,
	//Memory result(To WriteBack)
	output reg Ctl_RegWrite_out,
	output reg [4:0] Rd_out,
	output reg [31:0] MEMresult_out,
	//stall
	output wait_L2_data_stall,
	//flush
	input flush
    );
	//Branch prepare
	reg [31:0] forwardA_temp, forwardB_temp;
	reg previous_flush;
	wire [31:0] forwardA_now = Rs1_branch_forward ? mem_forward_data : ReadData1;
	wire [31:0] forwardB_now = Rs2_branch_forward ? mem_forward_data : ReadData2;
	wire [31:0] forwardA = previous_flush ? forwardA_temp : forwardA_now;
	wire [31:0] forwardB = previous_flush ? forwardB_temp : forwardB_now;
	//L1 D-Cache prepare
	reg [26:0] Tag [0:7];
	(* ram_style = "block" *) reg [63:0] L1_Cache [0:7];
	reg valid [0:7];
	reg stack [0:7];
	reg start_end_temp;
	reg double_Memory;
	reg real_finish;
	//Branch determine //////////////////////////////////////////////////////////////////////////////////////
	wire taken_0 = br_0 ? (forwardA == forwardB) : 0;
	wire taken_1 = br_1 ? (forwardA != forwardB) : 0;
	wire taken_2 = br_2 ? ($signed(forwardA) < $signed(forwardB)) : 0;
	wire taken_3 = br_3 ? ($signed(forwardA) >= $signed(forwardB)) : 0;
	wire taken_4 = br_4 ? ($unsigned(forwardA) < $unsigned(forwardB)) : 0;
	wire taken_5 = br_5 ? ($unsigned(forwardA) >= $unsigned(forwardB)) : 0;
	assign taken = taken_0 | taken_1 | taken_2 | taken_3 | taken_4 | taken_5;
	always @(posedge clk, negedge  reset) begin
		if(!reset) begin
			previous_flush			<= 0;
			forwardA_temp			<= 0;
			forwardB_temp			<= 0;
		end else begin
			previous_flush					<= flush;
			if (!previous_flush) begin
				forwardA_temp				<= forwardA_now;
				forwardB_temp				<= forwardB_now;
			end
		end
	end
	//jalr_forward //////////////////////////////////////////////////////////////////////////////////////////
	assign jalr_forward_Rd = Rd_in;
	assign jalr_forward_Ctl_RegWrite = Ctl_RegWrite_in;
	assign jalr_forward_Ctl_MemtoReg = Ctl_MemtoReg_in;
	//find_directory ////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] start_address = ALUresult_in;
	wire [1:0] end_adder = word ? 2'b11 : (half ? 2'b01 : 2'b00);
	wire [31:0] end_address = ALUresult_in + end_adder;
	//hit-miss determine ////////////////////////////////////////////////////////////////////////////////////
	wire [2:0] set_start_test_0 = ({start_address[4:3],1'b0});
	wire [2:0] set_end_test_0 = ({end_address[4:3],1'b0});
	wire [2:0] set_start_test_1 = ({start_address[4:3],1'b1});
	wire [2:0] set_end_test_1 = ({end_address[4:3],1'b1});
	wire hit_start_0 = (Tag[set_start_test_0] == start_address[31:5]) && valid[set_start_test_0];
	wire hit_start_1 = (Tag[set_start_test_1] == start_address[31:5]) && valid[set_start_test_1];
	wire hit_end_0 = (Tag[set_end_test_0] == end_address[31:5]) && valid[set_end_test_0];
	wire hit_end_1 = (Tag[set_end_test_1] == end_address[31:5]) && valid[set_end_test_1];
	wire hit_start = hit_start_0 || hit_start_1;
	wire hit_end = hit_end_0 || hit_end_1;
	wire h_need = hit_start && hit_end;
	wire m_need = (Ctl_MemtoReg_in || Ctl_MemWrite_in);
	wire hit = h_need && m_need;
	wire miss = (~h_need) && m_need;
	//read_write_both(hit) //////////////////////////////////////////////////////////////////////////////////
	wire [2:0] set_start = ({start_address[4:3],hit_start_1});
	wire [2:0] set_end = ({end_address[4:3],hit_end_1});
	wire [7:0] L1_Cache_start_end [7:0];
	assign L1_Cache_start_end[0] = start_address[2] ? L1_Cache[set_start][39:32] : L1_Cache[set_start][7:0];
	assign L1_Cache_start_end[1] = start_address[2] ? L1_Cache[set_start][47:40] : L1_Cache[set_start][15:8];
	assign L1_Cache_start_end[2] = start_address[2] ? L1_Cache[set_start][55:48] : L1_Cache[set_start][23:16];
	assign L1_Cache_start_end[3] = start_address[2] ? L1_Cache[set_start][63:56] : L1_Cache[set_start][31:24];
	assign L1_Cache_start_end[4] = end_address[2] ? L1_Cache[set_end][39:32] : L1_Cache[set_end][7:0];
	assign L1_Cache_start_end[5] = end_address[2] ? L1_Cache[set_end][47:40] : L1_Cache[set_end][15:8];
	assign L1_Cache_start_end[6] = end_address[2] ? L1_Cache[set_end][55:48] : L1_Cache[set_end][23:16];
	assign L1_Cache_start_end[7] = end_address[2] ? L1_Cache[set_end][63:56] : L1_Cache[set_end][31:24];
	wire start_end_same = (set_start == set_end);
	//read_operation(hit) ///////////////////////////////////////////////////////////////////////////////////
	wire [7:0] read_byte_0 = L1_Cache_start_end[start_address[1:0]];
	wire [7:0] read_byte_1 = L1_Cache_start_end[start_address[1:0] + 1];
	wire [7:0] read_byte_2 = L1_Cache_start_end[start_address[1:0] + 2];
	wire [7:0] read_byte_3 = L1_Cache_start_end[start_address[1:0] + 3];
	wire signbit = byte ? read_byte_0[7] : read_byte_1[7];
	wire [7:0] result_byte_1 = byte ? (unsign ? 8'b00000000 : ({8{signbit}})) : read_byte_1;
	wire [7:0] result_byte_2 = word ? read_byte_2 : (unsign ? 8'b00000000 : ({8{signbit}}));
	wire [7:0] result_byte_3 = word ? read_byte_3 : (unsign ? 8'b00000000 : ({8{signbit}}));
	//write_operation(hit) //////////////////////////////////////////////////////////////////////////////////
	wire [7:0] write_byte [3:0];
	assign write_byte[0] = forwardB[7:0];
	assign write_byte[1] = forwardB[15:8];
	assign write_byte[2] = forwardB[23:16];
	assign write_byte[3] = forwardB[31:24];
	wire [7:0] L1_Cache_write [7:0];
	wire stateA_0 = (start_address[1] | start_address[0]);
	wire stateA_1 = ((start_address[1:0] == 2'b00) & byte) | start_address[1];
	wire stateA_2 = (!start_address[1] & !start_address[0] & !word) | (start_address[0] & (start_address[1] & byte));
	wire stateA_3 = (!start_address[1] & !word) | (!start_address[0] & byte);
	wire stateA_4 = (!start_address[1] & !start_address[0]) | (half & (!start_address[1] | !start_address[0])) | byte;
	wire stateA_5 = !start_address[1] | half | byte;
	wire stateA_6 = !start_address[1] & !start_address[0] & !word;
	wire stateB_2 = (start_address[1:0] == 2'b00) & word;
	wire stateB_3 = !start_address[1] & word;
	wire stateB_4 = (!start_address[1] & start_address[0]) | (start_address[1] & !start_address[0]) & word;
	wire stateB_5 = start_address[1] & word;
	wire stateB_6 = (start_address[1:0] == 2'b11) & word;
	wire stateC_1 = (start_address[1:0] == 2'b00) & !byte;
	wire stateC_2 = (start_address[1:0] == 2'b01) & !byte;
	wire stateC_3 = !start_address[0] & !byte;
	wire stateC_4 = start_address[0] & !byte;
	wire stateC_5 = start_address[1] & !start_address[0] & word;
	wire stateC_6 = start_address[1] & start_address[0] & word;
	assign L1_Cache_write[0] = stateA_0 ? L1_Cache_start_end[0] : write_byte[0];
	assign L1_Cache_write[1] = stateA_1 ? L1_Cache_start_end[1] : write_byte[{1'b0,stateC_1}];
	assign L1_Cache_write[2] = stateA_2 ? L1_Cache_start_end[2] : write_byte[{stateB_2,stateC_2}];
	assign L1_Cache_write[3] = stateA_3 ? L1_Cache_start_end[3] : write_byte[{stateB_3,stateC_3}];
	assign L1_Cache_write[4] = stateA_4 ? L1_Cache_start_end[4] : write_byte[{stateB_4,stateC_4}];
	assign L1_Cache_write[5] = stateA_5 ? L1_Cache_start_end[5] : write_byte[{stateB_5,stateC_5}];
	assign L1_Cache_write[6] = stateA_6 ? L1_Cache_start_end[6] : write_byte[{stateB_6,stateC_6}];
	assign L1_Cache_write[7] = L1_Cache_start_end[7];
	wire [31:0] write_word_start_0 = start_address[2] ? L1_Cache[set_start][31:0] : ({L1_Cache_write[3],L1_Cache_write[2],L1_Cache_write[1],L1_Cache_write[0]});
	wire [31:0] write_word_start_1 = start_address[2] ? ({L1_Cache_write[3],L1_Cache_write[2],L1_Cache_write[1],L1_Cache_write[0]}) : L1_Cache[set_start][63:32];
	wire [31:0] write_word_end_0 = end_address[2] ? L1_Cache[set_end][31:0] : ({L1_Cache_write[7],L1_Cache_write[6],L1_Cache_write[5],L1_Cache_write[4]});
	wire [31:0] write_word_end_1 = end_address[2] ? ({L1_Cache_write[7],L1_Cache_write[6],L1_Cache_write[5],L1_Cache_write[4]}) : L1_Cache[set_end][63:32];
	assign write_request_active = hit & Ctl_MemWrite_in;
	assign address_start_end_same = start_end_same;
	assign refresh_data_loc = (double_Memory | start_end_temp) ? start_address[2] : end_address[2];
	assign refresh_data_to_L2 = (double_Memory | start_end_temp) ? (start_address[2] ? write_word_start_1 : write_word_start_0) : (end_address[2] ? write_word_end_1 : write_word_end_0);
	//race_condition ////////////////////////////////////////////////////////////////////////////////////////
	wire race_condition_set [7:0];
	assign race_condition_set[0] = rewrite_active & (rewrite_address[1:0] == 2'b00) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[1] = rewrite_active & (rewrite_address[1:0] == 2'b00) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[2] = rewrite_active & (rewrite_address[1:0] == 2'b01) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[3] = rewrite_active & (rewrite_address[1:0] == 2'b01) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[4] = rewrite_active & (rewrite_address[1:0] == 2'b10) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[5] = rewrite_active & (rewrite_address[1:0] == 2'b10) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[6] = rewrite_active & (rewrite_address[1:0] == 2'b11) & (rewrite_address[28:2] == Tag[0]);
	assign race_condition_set[7] = rewrite_active & (rewrite_address[1:0] == 2'b11) & (rewrite_address[28:2] == Tag[0]);
	//data_request_L2(miss) /////////////////////////////////////////////////////////////////////////////////
	assign read_request_active = miss;
	assign address_to_L2 = (double_Memory | start_end_temp) ? start_address[31:3] : end_address[31:3];
	wire [2:0] refresh_set_start = {start_address[4:3],!stack[{start_address[4:3],1'b0}]};
	wire [2:0] refresh_set_end = {end_address[4:3],!stack[{end_address[4:3],1'b0}]};
	//L1 D-Cache ////////////////////////////////////////////////////////////////////////////////////////////
	integer i;
	always @(posedge clk, negedge  reset) begin
		if(!reset) begin
			for (i=0;i<8;i=i+1) begin
				Tag[i]				<= 0;
				L1_Cache[i]			<= 0;
				valid[i]			<= 0;
				stack[i]			<= 1;
			end
			start_end_temp			<= 1;
			double_Memory			<= 0;
			real_finish				<= 1;
		end else begin
			if (hit & !race_condition_set[set_start] & !race_condition_set[set_end]) begin
				stack[set_start]							<= 0;
				stack[{set_start[2:1],!set_start[0]}]		<= 1;
				if (!start_end_same) begin
					stack[set_end]							<= 0;
					stack[{set_end[2:1],!set_end[0]}]		<= 1;
				end
				if (Ctl_MemWrite_in) begin
					L1_Cache[set_start]						<= ({write_word_start_1,write_word_start_0});
					if (!start_end_same) begin
						L1_Cache[set_end]					<= ({write_word_end_1,write_word_end_0});
						start_end_temp						<= 0;
						double_Memory						<= 1;
					end
					if (L2_operate_ready & !start_end_temp & double_Memory) begin
						double_Memory						<= 0;
					end
					if (L2_operate_ready & !start_end_temp & !double_Memory) begin
						start_end_temp						<= 1;
					end
				end
			end
			if (miss) begin
				real_finish													<= 0;
			end
			if (miss & L2_operate_ready & ((double_Memory & !start_end_temp) | start_end_temp)) begin
				Tag[refresh_set_start]										<= start_address[31:5];
				L1_Cache[refresh_set_start]									<= data_from_L2;
				valid[refresh_set_start]									<= 1;
				stack[refresh_set_start]									<= 0;
				stack[{refresh_set_start[2:1],!refresh_set_start[0]}]		<= 1;
				double_Memory												<= 0;
			end
			if (miss & L2_operate_ready & start_end_temp) begin
				real_finish													<= 1;
			end
			if (miss & L2_operate_ready & !double_Memory & !start_end_temp) begin
				Tag[refresh_set_end]										<= end_address[31:5];
				L1_Cache[refresh_set_end]									<= data_from_L2;
				valid[refresh_set_end]										<= 1;
				stack[refresh_set_end]										<= 0;
				stack[{refresh_set_end[2:1],!refresh_set_end[0]}]			<= 1;
				start_end_temp												<= 1;
				real_finish													<= 1;
			end
			if (race_condition_set[0]) begin
				valid[0]													<= 0;
			end
			if (race_condition_set[1]) begin
				valid[1]													<= 0;
			end
			if (race_condition_set[2]) begin
				valid[2]													<= 0;
			end
			if (race_condition_set[3]) begin
				valid[3]													<= 0;
			end
			if (race_condition_set[4]) begin
				valid[4]													<= 0;
			end
			if (race_condition_set[5]) begin
				valid[5]													<= 0;
			end
			if (race_condition_set[6]) begin
				valid[6]													<= 0;
			end
			if (race_condition_set[7]) begin
				valid[7]													<= 0;
			end
		end
	end
	//stall_state ///////////////////////////////////////////////////////////////////////////////////////////
	assign wait_L2_data_stall = ((miss | (hit & Ctl_MemWrite_in)) & (!L2_operate_ready | (L2_operate_ready & double_Memory))) | !real_finish;
	//finish_Memory_stage ///////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk, negedge  reset) begin
		if(!reset || flush) begin
			thread_finish_pc			<= 0;
			multi_thread_set_out		<= 0;
			multi_task_set_out			<= 0;
			finish_function_out			<= 0;
			Ctl_RegWrite_out			<= 0;
			Rd_out						<= 0;
			MEMresult_out				<= 0;
		end else begin
			thread_finish_pc			<= PC_in;
			multi_thread_set_out		<= multi_thread_set_in;
			multi_task_set_out			<= multi_task_set_in;
			finish_function_out			<= finish_function_in;
			Ctl_RegWrite_out			<= Ctl_RegWrite_in;
			Rd_out						<= Rd_in;
			MEMresult_out				<= Ctl_MemtoReg_in ? ({result_byte_3,result_byte_2,result_byte_1,read_byte_0}) : ALUresult_in;
		end
	end
endmodule