module DataMemory(reset, clk, Address, WriteData, MemRead, MemWrite, ReadData);

	input reset, clk, MemRead, MemWrite;
	input [31:0] Address;
	input [31:0] WriteData;

	output [31:0] ReadData;

	reg [7:0] Data[1023:0]; //1024 slots of 8 bits (1 byte), each 4 of them making up a word (4 x 8 = 32bits ----> 256 words of 32bits length)

	assign ReadData = MemRead?{Data[Address + 3], Data[Address + 2], Data[Address + 1], Data[Address]}:32'd0; //if MemRead, fill 4 slots from the address into the ReadData (o/p)

	integer i;

	initial begin
		Data[3] <= 8'd0; Data[2] <= 8'd0; Data[1] <= 8'd0; Data[0] <= 8'd23; //0th word = 23
		Data[7] <= 8'd0; Data[6] <= 8'd0; Data[5] <= 8'd0; Data[4] <= 8'd180; //1st word = 180
		Data[11] <= 8'd0; Data[10] <= 8'd0; Data[9] <= 8'd75; Data[8] <= 8'd56; //2nd word = 19,256
		Data[15] <= 8'd0; Data[14] <= 8'd20; Data[13] <= 8'd0; Data[12] <= 8'd0; //3rd word = 1,310,720
		Data[19] <= 8'd7; Data[18] <= 8'd91; Data[17] <= 8'd205; Data[16] <= 8'd21; //4th word = 123,456,789
		Data[23] <= 8'd0; Data[22] <= 8'd0; Data[21] <= 8'd0; Data[20] <= 8'd1; //5th word = 1
		Data[27] <= 8'd255; Data[26] <= 8'd255; Data[25] <= 8'd255; Data[24] <= 8'd255; //6th word = -1

		for (i = 28; i < 1024; i = i + 1) begin
			Data[i] <= 8'd0; //rest of the words are 0
		end
	end

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
