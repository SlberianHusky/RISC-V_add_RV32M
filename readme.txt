Team number: AOHW25_456
Project name: RISC-V faster branch and context switch
Link to YouTube Video(s): https://youtu.be/H829Ik4NOag
Link to project repository: https://github.com/SlberianHusky/RISC-V_add_RV32M.git

University name: Hanyang University
Participant(s): Jun-Hee Ko
Email: gjhmanse@hanyang.ac.kr
University name: Hanyang University
Participant(s): Young-Jin Kim
Email: yjkim9591m@hanyang.ac.kr
Supervisor name: Professor Dong-Jin Lee
Supervisor e-mail: speedodj@hanyang.ac.kr

Board used: xc7a75tfgg484-1
Software Version: 2023.2
Brief description of project: Using parallelization of Fetch, Decode steps to eliminate loss due to branch prediction failure, Fast context switch implementation using context switch procedure simplification

Description of archive (explain directory structure, documents and source files):
(If you put it in Vivado, it will look like this.)
RISCV-MultiCore
	Main_Core0 : RISCVpipeline
		stall_flush_determine : Stall_Flush_determine
		A1_Core0_InFetch : InFetch
		A1_Core1_InFetch : InFetch
		A1_Core2_InFetch : InFetch
		A1_Core3_InFetch : InFetch
		A1_Jalr_Forwardeing : Jalr_Forwarding_unit
		A2_Core0_InDecode : InDecode
		A2_Core1_InDecode : InDecode
		A2_InDecode_Register : Register_unit
		A3_Execution : Execution
		A4_Memory : Memory
		A5_WriteBack : WriteBack
	Main_Core1 : RISCVpipeline
		<...>
	Main_Core2 : RISCVpipeline
		<...>
	Main_Core3 : RISCVpipeline
		<...>
	OS_Kernel : OS_Kernel
	MDU_Core0 : Divide_Remain_Unit
		Step1 : div_rem_step
		Step2 : div_rem_step
		Step3 : div_rem_step
		Step4 : div_rem_step
		Step5 : div_rem_step
		Step6 : div_rem_step
		Step7 : div_rem_step
		Step8 : div_rem_step
	MDU_Core1 : Divide_Remain_Unit
		<...>
	L2_Cache : L2_Cache
	Processor_ID_Queue : PID_Queue

Instructions to build and test project
Step 1: Create a project in Vivado and insert these files.
Step 2: After creating the test bench, insert the code below.
module tb_RISCV_MultiCore;
	reg clk;
	reg reset;
	RISCV_MultiCore uut (
		.clk(clk), 
		.reset(reset)
	);
	initial begin
		#0 reset = 0;
		#55 reset = 1;
	end
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
endmodule
Step 3: You can change 'darksocv.rom.mem' file. It is assembly code program This is an assembly-written program that can be performed by modifying within compatible commands.

Step 4: You can also change 'darksocv.ram.mem' file. This file represents the initial value of L2 Cache memory.
