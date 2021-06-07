module ALU(in1, in2, ALUctrl, out, zero);

	input signed [31:0] in1;
	input signed [31:0] in2;
	input [2:0] ALUctrl;

	output reg signed [31:0] out;
	output zero;

	assign zero = (out == 0);

	always @(*) begin
		case (ALUctrl)
			3'b010: out <= in1 + in2;
			3'b110: out <= in1 - in2;
			3'b000: out <= in1 & in2;
			3'b001: out <= in1 | in2;
		endcase
	end

endmodule
