module Processor (reset, clk);

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

	wire[31:0] Instruction;	
	
	InstructionMemory IM(.Address(PC), .Instruction(Instruction));


	wire RegDst;
	wire Branch;
	wire MemRead;
	wire MemtoReg;
	wire [2:0] ALUop;
	wire MemWrite;
	wire ALUsrc;
	wire RegWrite; //end of Control wires
	
	UnitsController UC(.OpCode(Instruction[31:26]), .func(Instruction[5:0]), .RegDst(RegDst),
			   .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUop(ALUop),
			   .MemWrite(MemWrite), .ALUsrc(ALUsrc), .RegWrite(RegWrite));

	wire [31:0] WriteData; //will be assigned later on in this code
	wire [31:0] ReadData1; //aka ALU input 1
	wire [31:0] ReadData2; //potential ALU input 2
	wire [4:0] WriteRegSrc; //end of RegisterFile wires
	assign WriteRegSrc = RegDst?Instruction[15:11]:Instruction[20:16];

	RegisterFile RF(.reset(reset), .clk(clk), .ReadReg1(Instruction[25:21]), .ReadReg2(Instruction[20:16]),
			.WriteReg(WriteRegSrc), .WriteData(WriteData), .RegWrite(RegWrite),
			.ReadData1(ReadData1), .ReadData2(ReadData2));


	wire [2:0] ALUctrl;

	ALUController ALUC(.ALUop(ALUop), .func(Instruction[5:0]), .ALUctrl(ALUctrl));


	wire [31:0] SignExtended;
	assign SignExtended = (Instruction[15] == 1'b0)?{16'd0, Instruction[15:0]}:{16'b1111111111111111, Instruction[15:0]}; //sign extension
	wire [31:0] ALUinput2;
	wire [31:0] ALUres;
	wire zero;
	assign ALUinput2 = ALUsrc?SignExtended:ReadData2;

	ALU alu(.in1(ReadData1), .in2(ALUinput2), .ALUctrl(ALUctrl), .out(ALUres), .zero(zero));


	wire [31:0] ramReadData;
	
	DataMemory RAM(.reset(reset), .clk(clk), .Address(ALUres), .WriteData(ReadData2), .MemRead(MemRead),
		       .MemWrite(MemWrite), .ReadData(ramReadData));


	assign WriteData = MemtoReg?ramReadData:ALUres;

	wire [31:0] BranchDst;
	assign BranchDst = {SignExtended[29:0], 2'b00} + PCplus4; //(Sign Extension shifted left by 2) + (PC + 4)

	assign next = (Branch && zero)?BranchDst:PCplus4;

endmodule
