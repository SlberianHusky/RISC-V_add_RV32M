`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ko Jun Hee
// 
// Create Date: 2024/12/22 23:46:15
// Design Name: 
// Module Name: InFetch
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


module InFetch(
	//clock reset
	input clk, reset,
	//taken signal from memory stage
	input taken,
	//forwarding for jalr instruction
	output [4:0] jalr_rd,
	input jalr_ready,
	input [31:0] jalr_reg_in,
	//transmit next two pcs(taken, not taken) to another InFetch modules
	output [31:0] NT_pc_out, T_pc_out,
	//take two pcs(taken, not taken) from another InFetch modules
	input [31:0] NT_pc_in, T_pc_in,
	//InFetch result(To InDecode)
	output reg [31:0] instruction_out, PC_out,
	//stall
	input stall,
	//flush
	input flush
	);
	reg previous_taken;
	reg previous_stall;
	wire real_taken = previous_stall ? previous_taken : taken;
	wire [31:0] instruction;
	wire [31:0] pc_now = (real_taken) ? T_pc_now : NT_pc_now;
	wire jal = instruction[5] & !instruction[4] & instruction[3];
	wire jalr = (!instruction[4]) & (!instruction[3]) & instruction[2];
	wire branch = !instruction[2];
	wire signed [31:0] jal_imm = {{12{instruction[31]}},instruction[19:12],instruction[20],instruction[30:21],1'b0};
	wire signed [31:0] jalr_imm = {{20{instruction[31]}},instruction[31:20]};
	wire signed [31:0] branch_imm = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
	assign jalr_rd = instruction[19:15];
	wire [31:0] jal_pc = pc_now + jal_imm;
	wire [31:0] jalr_pc = jalr_reg_in + jalr_imm;
	assign T_pc_out = pc_now + branch_imm;
	reg [31:0] NT_pc_now, T_pc_now;
	
	//======== L1 I-Cache module ======== InFetch has 1 L1 I-Cache, 1core has 4 L1 I-Cache
	parameter ROM_size = 1024;
	(* ram_style = "block" *) reg [31:0] ROM [0:ROM_size-1];	//assembly code included
	initial begin
		$readmemh ("darksocv.rom.mem", ROM);
	end
	assign instruction = ROM[pc_now[31:2]];
	//======== L1 I-Cache module ========
	
	//======== PC_reg module ========
	always @ (posedge clk, negedge reset) begin
		if (!reset) begin
			NT_pc_now <= 0;
			T_pc_now <= 0;
		end
		else if (!stall & !flush) begin
			NT_pc_now <= NT_pc_in;
			T_pc_now <= T_pc_in;
		end
	end
	//======== PC_reg module ========
	
	assign NT_pc_out = (jal) ? jal_pc : ((jalr) ? ((jalr_ready) ? jalr_pc : pc_now) : (pc_now + 4));
	always @(posedge clk, negedge reset)
	begin
		if (!reset) begin
			instruction_out		<= 0;
			PC_out				<= 0;
			previous_taken		<= 0;
			previous_stall		<= 0;
		end else begin
			if (!previous_stall) begin
				previous_taken	<= taken;
			end
			previous_stall		<= stall;
			if (!stall) begin
				instruction_out	<= (flush | (jalr & !jalr_ready)) ? 32'b0 : instruction;
				PC_out			<= pc_now;
			end
		end
	end
endmodule