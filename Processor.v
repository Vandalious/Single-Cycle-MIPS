/*
	This code is inspired from another implementation. So
	there are some simple approaches that will be updated
	in future commits.

	Authors:
		Arash Hajiannezhad
		Alireza Jafartash
*/


module Processor (reset, clk);

	/*
		Processor

			reset: Set the PC to 0 if it's enabled.
			clk: Clock wire input.
	*/
	// Begin

	input reset, clk;

	reg [31:0] PC;
	wire [31:0] PCplus4; //obviously, current PC + 4
	wire [31:0] next; //for when we wanna choose either Branch or simple + 4
	assign PCplus4 = PC + 32'd4;

	always @(posedge reset or posedge clk) begin
		if (reset) begin
			PC <= 32'd0;
		end

		else begin
			PC <= next;
		end
	end
	// End


	/*
		Instruction Memory

			Instruction: a 32 bit mask to store the instruction.
			IM: The instructionMemoryUnit
	*/
	// Begin
	wire[31:0] Instruction;	
	
	InstructionMemory IM(
		.Address(PC),
		.Instruction(Instruction)
	);
	// End


	
	/*
		Controller Wires

			RegDst: Selector of the MUX of inst[20:16] and inst[15:11].
			Branch: For the beq instruction, goes to the and gate with zero from ALU.
			MemRead: Activator for DataMemory unit to read.
			MemtoReg: Selector of the MUX after DataMemory to select which result is going be stored in a register.
			MemWrite: Activator for DataMemory to write date.
			ALUop: The operations of ALU coded with 2bits. See the ALU_README.md to check the definitions.
			ALUsrc: Selector of the MUX before ALU for the case of beq instruction.
			RegWrite: Activator for RegsiterFile unit to write the data in destination register.
	*/
	// Begin
	wire RegDst;
	wire Branch;
	wire MemRead;
	wire MemtoReg;
	wire MemWrite;
	wire [2:0] ALUop;
	wire ALUsrc;
	wire RegWrite;
	
	UnitsController UC(
		.OpCode(Instruction[31:26]),
		.func(Instruction[5:0]),
		.RegDst(RegDst),
		.Branch(Branch),
		.MemRead(MemRead),
		.MemtoReg(MemtoReg),
		.ALUop(ALUop),
		.MemWrite(MemWrite),
		.ALUsrc(ALUsrc),
		.RegWrite(RegWrite));
	// End	



	/*
		RegisterFile

			ReadData1: Data stroed in address inst[25:21] and goes to ALU input 1
			ReadData2: Data stored in address inst[20:16] and goes to ALU input 2 (after a MUX filter)
			WriteReg: The result of the MUX selecting between inst[20:16] and inst[15:11] acctually for the lw and sw cases.
			WriteData: The wire outcoming from MemoryData unit and then a MUX. It will be assigend at the MemoryData unit section.
	*/
	// Begin
	wire [31:0] ReadData1; //aka ALU input 1
	wire [31:0] ReadData2; //potential ALU input 2
	wire [4:0] WriteRegSrc; //end of RegisterFile wires
	wire [31:0] WriteData; //will be assigned later on in this code
	assign WriteRegSrc = RegDst ? Instruction[15:11] : Instruction[20:16]; // MUX

	RegisterFile RF(.reset(reset), .clk(clk), .ReadReg1(Instruction[25:21]), .ReadReg2(Instruction[20:16]),
			.WriteReg(WriteRegSrc), .WriteData(WriteData), .RegWrite(RegWrite),
			.ReadData1(ReadData1), .ReadData2(ReadData2));
	// End



	/*
		ALUController
			ALUctrl: The code goes straight to the ALU unit.
			ALUop: Defined in Controller section.
			Instruction: Defined in InstructionMemmory section.
	*/
	// Begin
	wire [2:0] ALUctrl;

	ALUController ALUC(.ALUop(ALUop), .func(Instruction[5:0]), .ALUctrl(ALUctrl));
	// End



	/*
		ALU + SignExtend
			SignExtended: The result of inst[15:0] after extending.
			ALUinput2: The result of the MUX between RegisterFile and ALU.
			ALUres: The result outcoming from ALU.
			zero: If the result is zero. Used for beq when ALU subtract two addresses.
	*/
	// Begin
	wire [31:0] SignExtended;
	assign SignExtended = (Instruction[15] == 1'b0)?{16'd0, Instruction[15:0]}:{16'b1111111111111111, Instruction[15:0]}; //sign extension
	wire [31:0] ALUinput2;
	wire [31:0] ALUres;
	wire zero;
	assign ALUinput2 = ALUsrc?SignExtended:ReadData2;

	ALU alu(.in1(ReadData1), .in2(ALUinput2), .ALUctrl(ALUctrl), .out(ALUres), .zero(zero));
	// End



	/*
		MemoryData
			ramReadData: ?
			clk: Clock of the processor
			ALUres: ?
			MemWrite: Defined in Controllers secition
	*/
	// Begin
	wire [31:0] ramReadData;
	
	DataMemory RAM(.reset(reset), .clk(clk), .Address(ALUres), .WriteData(ReadData2), .MemRead(MemRead),
		       .MemWrite(MemWrite), .ReadData(ramReadData));
	

	assign WriteData = MemtoReg?ramReadData:ALUres;
	// End



	// Finishind Wires for the next PC
	wire [31:0] BranchDst;
	assign BranchDst = {SignExtended[29:0], 2'b00} + PCplus4; //(Sign Extension shifted left by 2) + (PC + 4)

	assign next = (Branch && zero)?BranchDst:PCplus4;

endmodule
