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

	initial begin
		Register[0] <= 32'd0; //$0 = 0
		Register[1] <= 32'd5; //$1 = 5
		Register[2] <= 32'd654; //$2 = 654
		Register[3] <= 32'd123987; //$3 = 123987
		Register[4] <= -32'd53; //$4 = -53
		Register[5] <= 32'd103; //$5 = 103
		Register[6] <= 32'd2; //$6 = 2

		for (i = 7; i < 32; i = i + 1) begin
			Register[i] <= 32'd0; //rest of the Registers are set to 0
		end
	end

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
