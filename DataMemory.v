module DataMemory(reset, clk, Address, WriteData, MemRead, MemWrite, ReadData);

	input reset, clk, MemRead, MemWrite;
	input [31:0] Address;
	input [31:0] WriteData;

	output [31:0] ReadData;

	reg [7:0] Data[1023:0]; //1024 slots of 8 bits (1 byte), each 4 of them making up a word (4 x 8 = 32bits ----> 256 words of 32bits length)

	assign ReadData = MemRead?{Data[Address + 3], Data[Address + 2], Data[Address + 1], Data[Address]}:32'd0; //if MemRead, fill 4 slots from the address into the ReadData (o/p)

	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
			for (i = 0; i < 1024; i = i + 1) begin
				Data[i] <= 8'd0;
			end
		end

		else if (MemWrite) begin
			Data[Address] <= WriteData[7:0];
			Data[Address + 1] <= WriteData[15:8];
			Data[Address + 2] <= WriteData[23:16];
			Data[Address + 3] <= WriteData[31:24];
		end
	end

endmodule
