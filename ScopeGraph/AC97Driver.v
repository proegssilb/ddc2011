`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Bliss
// 
// Create Date:    23:08:00 03/21/2011 
// Design Name: 
// Module Name:    AC97Driver 
// Project Name:   Digilent Design Competition 2011
// Target Devices: Digilent Atlys (Rev C)
// Tool versions:  Xilinx ISE 12.2; M.63c
// Description: A simple line-in-only driver for the AC97 codec on the Atlys.
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
wire [15:0] slot1;
wire [19:0] addrSlot;
wire [19:0] dataSlot;

assign aReset = ~freset;
assign slot1 = {valid, valid, valid, 13'b0};
assign addrSlot = {1'b0, cmdAddr, 12'b0};
assign dataSlot = {cmdData, 4'b0};
assign aSync = (slotNum == 12 && (frameBit == 1 || frameBit == 0)) || slotNum == 0 ? 1 : 0;
assign aBitClk = fclk;

always @ (posedge fclk or posedge freset) begin
	if (freset) begin
		state <= 0;
		frameBit <= 0;
		slotNum <= 0;
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
		
		//Get the bits onto the wire
		case (slotNum)
			0: aSDO = slot1[frameBit];
			1: aSDO = addrSlot[frameBit];
			2: aSDO = dataSlot[frameBit];
			default: aSDO = 0;
		endcase
		
		//Update the transit state
		slotNum <= frameBit == 0 ? slotNum + 1 : slotNum;
		frameBit <= ( slotNum == 12 && frameBit == 0 ) ? 16 : frameBit == 0 ? 19 : frameBit - 1;
		state <= (state == 2) ? 2 : (slotNum == 6 && frameBit == 0) ? state + 1 : state;
		
		//Get the bits off the wire
		if (slotNum == 3 && frameBit > 3)
			fAudLIn[frameBit - 3] = aSDI;
		else if (slotNum == 4 && frameBit > 3)
			fAudRIn[frameBit - 3] = aSDI;
		
	end
end

endmodule
