module UnitsController(OpCode, func, RegDst, Branch, MemRead,
		       MemtoReg, ALUop, MemWrite, ALUsrc, RegWrite);

	input [5:0] OpCode;
	input [5:0] func;

	output RegDst, Branch, MemRead, MemtoReg, 
	       MemWrite, ALUsrc, RegWrite;
	output [2:0] ALUop;

	assign RegDst = (OpCode == 6'd0)?1'b1:1'b0;

	assign Branch = (OpCode == 6'b000100)?1'b1:1'b0;

	assign MemRead = (OpCode == 6'b100011)?1'b1:1'b0;

	assign MemtoReg = (OpCode == 6'b100011)?1'b1:1'b0;

	assign MemWrite = (OpCode == 6'b101011)?1'b1:1'b0;

	assign ALUsrc = (OpCode == 6'b100011 || OpCode == 6'b101011)?1'b1:1'b0;

	assign RegWrite = (OpCode == 6'd0 || OpCode == 6'b100011)?1'b1:1'b0;
	
	assign ALUop = ((OpCode == 6'b100011 || OpCode == 6'b101011) || (OpCode == 6'd0 && func == 6'b100000))?3'b010: //add (with lw & sw)
		       (OpCode == 000100 || (OpCode == 6'd0 && func == 6'b100010))?3'b110: //sub (with beq)
		       (OpCode == 6'd0 && func == 6'b100100)?3'b000:3'b001; //AND & OR

endmodule
