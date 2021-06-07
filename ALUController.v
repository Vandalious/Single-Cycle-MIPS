module ALUcontroller(ALUop, func, ALUctrl); //pretty much useless in this implementation

	input [2:0] ALUop;
	input [4:0] func; //useless (just for the sake of the book's model)

	output reg [2:0] ALUctrl;
	
	assign ALUctrl = ALUop;

endmodule
	
