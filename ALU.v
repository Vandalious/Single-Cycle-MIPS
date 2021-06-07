module ALU(in1, in2, ALUctrl, out, zero);

	input signed [31:0] in1;
	input signed [31:0] in2;
	input [5:0] ALUctrl;

	output reg signed [31:0] out;
	output zero;

	always @(*) begin
		case (ALUctrl)
			6'b100000: out <= in1 + in2;
			6'b100010: out <= in1 - in2;
			6'b100100: out <= in1 & in2;
			6'b100101: out <= in1 | in2;
		endcase
	end
	
endmodule
