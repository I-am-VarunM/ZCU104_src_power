`timescale 1ns / 1ps
`include "parameters.v"

module keygrid_4x4 (
	presses, 
	column_ins,
	row_outs);

// This helps testing of a 4x4 keypad by sending signals out based on the
// incoming high signals.  The theoretical keypad is as below
/*     0  1  2  3
*   -------------
*   0| 0  1  2  3
*   1| 4  5  6  7
*   2| 8  9  10 11
*   3| 12 13 14 15
*/
input [15:0]presses;
input [3:0]column_ins;
output [3:0]row_outs;
wire [3:0]row_outs;

assign row_outs[0] = ((presses[0] == 1'b1 && column_ins[0] == 1'b1) || (presses[1] == 1'b1 && column_ins[1] == 1'b1) || (presses[2] == 1'b1 && column_ins[2] == 1'b1) || (presses[3] == 1'b1 && column_ins[3] == 1'b1)) ? 1'b1 : 1'b0;
assign row_outs[1] = ((presses[4] == 1'b1 && column_ins[0] == 1'b1) || (presses[5] == 1'b1 && column_ins[1] == 1'b1) || (presses[6] == 1'b1 && column_ins[2] == 1'b1) || (presses[7] == 1'b1 && column_ins[3] == 1'b1)) ? 1'b1 : 1'b0;
assign row_outs[2] = ((presses[8] == 1'b1 && column_ins[0] == 1'b1) || (presses[9] == 1'b1 && column_ins[1] == 1'b1) || (presses[10] == 1'b1 && column_ins[2] == 1'b1) || (presses[11] == 1'b1 && column_ins[3] == 1'b1)) ? 1'b1 : 1'b0;
assign row_outs[3] = ((presses[12] == 1'b1 && column_ins[0] == 1'b1) || (presses[13] == 1'b1 && column_ins[1] == 1'b1) || (presses[14] == 1'b1 && column_ins[2] == 1'b1) || (presses[15] == 1'b1 && column_ins[3] == 1'b1)) ? 1'b1 : 1'b0;

endmodule

