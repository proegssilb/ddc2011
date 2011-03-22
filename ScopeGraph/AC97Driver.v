`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:08:00 03/21/2011 
// Design Name: 
// Module Name:    AC97Driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//Command 1: Set Source
parameter RecordingSource = 16'b00000_100_00000_100;
parameter RecSrcAddr = 7'h1A;
//Command 2: Set Volume
parameter LineInVolume = 16'h0808;
parameter LineInVolAddr = 7'h10;

module AC97Driver(
    //FPGA IOs
    input  fclk,
    input  freset,
    output reg [15:0] fAudRIn,
    output reg [15:0] fAudLIn,
	 //AC97 IOs
    output aBitClk,
    output reg aSDO,
    input  aSDI,
    output aSync,
    output aReset
    );

reg [3:0]  state;
reg [19:0] frameBit;
reg [3:0]  slotNum;
reg        valid;
reg [6:0]  cmdAddr;
reg [15:0] cmdData;

assign aReset = ~freset;

always @ (posedge fclk or posedge freset) begin
	if (freset) begin
		state = 0;
		frameBit = 0;
		slotNum = 0;
		valid = 0;
	end else begin
		//Command logic
		case (state)
			0: begin
					//do first instruction
					cmdAddr = RecSrcAddr;
					cmdData = RecordingSource;
					valid = 1;
				end
			1: begin
					//do second instruction
					cmdAddr = LineInVolAddr;
					cmdData = LineInVolume;
					valid = 1;
				end
			default: begin
					//Just stream data.
					valid = 0;
					cmdAddr = 0;
					cmdData = 0;
				end
		endcase
		case (slotNum)
			0: aSDO = {valid, valid, valid, 13'b0}[frameBit];
			1: aSDO = {0, cmdAddr, 12'b0}[frameBit];
			2: aSDO = {cmdData, 4'b0}[frameBit];
			default: aSDO = 0;
		endcase
		slotNum <= ( (|slotNum) & frameBit == 19 | frameBit == 15 ) ? slotNum + 1 : slotNum;
		frameBit <= ( (|slotNum) & frameBit == 19 | frameBit == 15 ) ? 0 : slotNum + 1;
	end
end

endmodule
