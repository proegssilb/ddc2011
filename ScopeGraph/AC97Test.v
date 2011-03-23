`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:28:47 03/22/2011 
// Design Name: 
// Module Name:    AC97Test 
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
module AC97Test(
    output [7:0] Led,
    input clk,
	 input [5:0] btn,
    output BITCLK,
    input AUDSDI,
    output AUDSDO,
    output AUDSYNC,
    output AUDRST
    );
	 
	 wire [15:0] audL, audR;
	 
	 assign Led = audL[7:0];

AC97Driver audioDriver (
	 //FPGA IOs
    .fclk(clk),
    .freset(btn[0]),
    .fAudRIn(audR),
    .fAudLIn(audL),
	 //AC97 IOs
    .aBitClk(BITCLK),
    .aSDO(AUDSDO),
    .aSDI(AUDSDI),
    .aSync(AUDSYNC),
    .aReset(AUDRST)
	 );

endmodule
