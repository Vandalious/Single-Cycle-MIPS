module RegisterFile(reset, clk, ReadReg1, ReadReg2, WriteReg, WriteData, RegWrite, ReadData1, ReadData2);

	input reset, clk, RegWrite;
	input [4:0] ReadReg1;
	input [4:0] ReadReg2;
	input [4:0] WriteReg;
	input [31:0] WriteData;

	output [31:0] ReadData1;
	output [31:0] ReadData2;

	reg [31:0] Register[31:0];

	assign ReadData1 = Register[ReadReg1];
	assign ReadData2 = Register[ReadReg2];

	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
			for (i = 1; i < 32; i = i + 1) begin
				Register[i] <= 32'd0;
			end
		end

		else if (RegWrite && (WriteReg != 5'd0)) begin
			Register[WriteReg] <= WriteData;
		end
	end

endmodule
