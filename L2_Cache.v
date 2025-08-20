`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2025/01/02 23:52:06
// Design Name: 
// Module Name: L2_Cache
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


module L2_Cache(
	//clock reset
	input clk, reset,
	//Main_Core interact
	input read_request_0, read_request_1, read_request_2, read_request_3,
	input write_request_0, write_request_1, write_request_2, write_request_3,
	input start_end_same_0, start_end_same_1, start_end_same_2, start_end_same_3,		//if 0 signal, need 1 more cycle
	input [28:0] address_0, address_1, address_2, address_3,
	input refresh_loc_0, refresh_loc_1, refresh_loc_2, refresh_loc_3,
	input [31:0] refresh_data_0, refresh_data_1, refresh_data_2, refresh_data_3,
	output L2_ready_0, L2_ready_1, L2_ready_2, L2_ready_3,
	output [63:0] read_data_0, read_data_1, read_data_2, read_data_3,
	output rewrite_active_0, rewrite_active_1, rewrite_active_2, rewrite_active_3,
	output [28:0] rewrite_address_0, rewrite_address_1, rewrite_address_2, rewrite_address_3,
	input trd_mod_0, trd_mod_1, trd_mod_2, trd_mod_3,
	input [7:0] trd_PID_0, trd_PID_1, trd_PID_2, trd_PID_3,
	//Kernel interact
	input new_PID,
	input [7:0] PID_register,
	input disable_PID,
	input [7:0] PID_discard,
	input un_lock_active,
	input [7:0] un_lock_PID,
	output not_pure_function
	);
	//default setting
	(* ram_style = "block" *) reg [31:0] L2_RAM [0:127];
	reg [1:0] lock_active [0:127];
	reg [7:0] lock_PID_num [0:1];
	//Priority Function prepare
	wire read_request [0:3];
	wire write_request [0:3];
	wire start_end_same [0:3];
	wire [28:0] address [0:3];
	wire refresh_loc [0:3];
	wire [31:0] refresh_data [0:3];
	wire trd_mod [0:3];
	wire [7:0] trd_PID [0:3];
	reg [2:0] waiting_queue [0:3];
	reg [2:0] operating_core_num;
	reg operating_doble;
	wire [3:0] read_request_L2;
	wire [3:0] write_request_L2;
	//Cache Function prepare
	wire [29:0] write_index;
	wire [31:0] write_data;
	wire [29:0] L2_index_A, L2_index_B;
	//Priority Function//////////////////////////////////////////////////////////////////////////////
	assign read_request[0] = read_request_0;
	assign read_request[1] = read_request_1;
	assign read_request[2] = read_request_2;
	assign read_request[3] = read_request_3;
	assign write_request[0] = write_request_0;
	assign write_request[1] = write_request_1;
	assign write_request[2] = write_request_2;
	assign write_request[3] = write_request_3;
	assign start_end_same[0] = start_end_same_0;
	assign start_end_same[1] = start_end_same_1;
	assign start_end_same[2] = start_end_same_2;
	assign start_end_same[3] = start_end_same_3;
	assign address[0] = address_0;
	assign address[1] = address_1;
	assign address[2] = address_2;
	assign address[3] = address_3;
	assign refresh_loc[0] = refresh_loc_0;
	assign refresh_loc[1] = refresh_loc_1;
	assign refresh_loc[2] = refresh_loc_2;
	assign refresh_loc[3] = refresh_loc_3;
	assign refresh_data[0] = refresh_data_0;
	assign refresh_data[1] = refresh_data_1;
	assign refresh_data[2] = refresh_data_2;
	assign refresh_data[3] = refresh_data_3;
	assign trd_mod[0] = trd_mod_0;
	assign trd_mod[1] = trd_mod_1;
	assign trd_mod[2] = trd_mod_2;
	assign trd_mod[3] = trd_mod_3;
	assign trd_PID[0] = trd_PID_0;
	assign trd_PID[1] = trd_PID_1;
	assign trd_PID[2] = trd_PID_2;
	assign trd_PID[3] = trd_PID_3;
	assign write_request_L2[0] = write_request[waiting_queue[0][1:0]];
	assign write_request_L2[1] = write_request[waiting_queue[1][1:0]];
	assign write_request_L2[2] = write_request[waiting_queue[2][1:0]];
	assign write_request_L2[3] = (waiting_queue[3] != 3'b111) & write_request[waiting_queue[3][1:0]];
	assign read_request_L2[0] = (({write_request_L2[3:1]}) == 3'b000) & read_request[waiting_queue[0][1:0]];
	assign read_request_L2[1] = (({write_request_L2[3:2],write_request_L2[0]}) == 3'b000) & read_request[waiting_queue[1][1:0]];
	assign read_request_L2[2] = (({write_request_L2[3],write_request_L2[1:0]}) == 3'b000) & read_request[waiting_queue[2][1:0]];
	assign read_request_L2[3] = (({write_request_L2[2:0]}) == 3'b000) & (waiting_queue[3] != 3'b111) & read_request[waiting_queue[3][1:0]];
	wire [2:0] operate_index = operating_doble ? 3'b111 : (write_request_L2[0] ? 3'b000 : (write_request_L2[1] ? 3'b001 : (write_request_L2[2] ? 3'b010 : (write_request_L2[3] ? 3'b011 : (read_request_L2[0] ? 3'b000 : (read_request_L2[1] ? 3'b001 : (read_request_L2[2] ? 3'b010 : (read_request_L2[3] ? 3'b011 : 3'b111))))))));
	wire [3:0] wait_shift_index;
	assign wait_shift_index[0] = 0;
	assign wait_shift_index[1] = (operate_index == 3'b000);
	assign wait_shift_index[2] = (operate_index < 2);
	assign wait_shift_index[3] = (operate_index < 3);
	always@(posedge clk, negedge reset) begin
		if (!reset) begin
			waiting_queue[0]			<= 3'b000;
			waiting_queue[1]			<= 3'b001;
			waiting_queue[2]			<= 3'b010;
			waiting_queue[3]			<= 3'b011;
			operating_core_num			<= 3'b111;
			operating_doble				<= 0;
		end else begin
			if (operate_index != 3'b001) begin
				waiting_queue[1 - wait_shift_index[1]]					<= waiting_queue[1];
			end
			if (operate_index != 3'b010) begin
				waiting_queue[2 - wait_shift_index[2]]					<= waiting_queue[2];
			end
			if ((operate_index != 3'b011) & (waiting_queue[3] != 3'b111)) begin
				waiting_queue[3 - wait_shift_index[3]]					<= waiting_queue[3];
			end
			if (operate_index != 3'b111) begin
				operating_core_num										<= waiting_queue[operate_index[1:0]];
				operating_doble											<= !start_end_same[operate_index[1:0]];
				waiting_queue[3]										<= 3'b111;
			end
			if ((operating_core_num != 3'b111) & !operating_doble) begin
				waiting_queue[3 - (operate_index != 3'b111)]			<= operating_core_num;
				if (operate_index == 3'b111) begin
					operating_core_num									<= 3'b111;
				end
			end
			if (operating_doble) begin
				operating_doble											<= 0;
			end
		end
	end
	//Cache Function ////////////////////////////////////////////////////////////////////////////////
	assign rewrite_active_0 = write_request[operating_core_num[1:0]] & (operating_core_num != 3'b000);
	assign rewrite_active_1 = write_request[operating_core_num[1:0]] & (operating_core_num != 3'b001);
	assign rewrite_active_2 = write_request[operating_core_num[1:0]] & (operating_core_num != 3'b010);
	assign rewrite_active_3 = write_request[operating_core_num[1:0]] & (operating_core_num != 3'b011);
	assign rewrite_address_0 = write_index[29:1];
	assign rewrite_address_1 = rewrite_address_0;
	assign rewrite_address_2 = rewrite_address_0;
	assign rewrite_address_3 = rewrite_address_0;
	assign not_pure_function = ((lock_active[L2_index_A][0] | lock_active[L2_index_B][0]) & trd_mod[operating_core_num[1:0]] & (trd_PID[operating_core_num[1:0]] == lock_PID_num[0])) | ((lock_active[L2_index_A][1] | lock_active[L2_index_B][1]) & trd_mod[operating_core_num[1:0]] & (trd_PID[operating_core_num[1:0]] == lock_PID_num[1]));
	//L2 Cache //////////////////////////////////////////////////////////////////////////////////////
	assign L2_index_A = ({address[operating_core_num[1:0]],1'b0});
	assign L2_index_B = ({address[operating_core_num[1:0]],1'b1});
	assign read_data_0 = ({L2_RAM[L2_index_B],L2_RAM[L2_index_A]});
	assign read_data_1 = read_data_0;
	assign read_data_2 = read_data_0;
	assign read_data_3 = read_data_0;
	assign L2_ready_0 = (operating_core_num == 3'b000);
	assign L2_ready_1 = (operating_core_num == 3'b001);
	assign L2_ready_2 = (operating_core_num == 3'b010);
	assign L2_ready_3 = (operating_core_num == 3'b011);
	integer i;
	assign write_index = ({address[operating_core_num[1:0]],refresh_loc[operating_core_num[1:0]]});
	assign write_data = refresh_data[operating_core_num[1:0]];
	always @(posedge clk, negedge  reset) begin
		if(!reset) begin
			$readmemh ("darksocv.ram.mem", L2_RAM);
			for (i=0;i<128;i=i+1) begin
				lock_active[i]		<= 0;
			end
			lock_PID_num[0]		<= 8'b11111111;
			lock_PID_num[1]		<= 8'b11111111;
		end else begin
			if (new_PID) begin
				if (lock_PID_num[0] == 8'b11111111) begin
					lock_PID_num[0]									<= PID_register;
				end else if (lock_PID_num[1] == 8'b11111111) begin
					lock_PID_num[1]									<= PID_register;
				end
			end
			if (disable_PID) begin
				if (lock_PID_num[0] == PID_discard) begin
					lock_PID_num[0]									<= 8'b11111111;
				end else if (lock_PID_num[1] == PID_discard) begin
					lock_PID_num[1]									<= 8'b11111111;
				end
			end
			if (write_request[operating_core_num[1:0]]) begin
				L2_RAM[write_index]							<= write_data;
				if (trd_mod[operating_core_num[1:0]]) begin
					if (lock_PID_num[0] == trd_PID[operating_core_num[1:0]]) begin
						lock_active[write_index][0]			<= 1;
					end else if (lock_PID_num[1] == trd_PID[operating_core_num[1:0]]) begin
						lock_active[write_index][1]			<= 1;
					end
				end
			end
			if (un_lock_active) begin
				if (lock_PID_num[0] == un_lock_PID) begin
					for (i=0;i<128;i=i+1) begin
						lock_active[i][0]							<= 0;
					end
				end else if (lock_PID_num[1] == un_lock_PID) begin
					for (i=0;i<128;i=i+1) begin
						lock_active[i][1]							<= 0;
					end
				end
			end
		end
	end
endmodule