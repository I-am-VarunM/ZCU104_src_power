`include "parameters.v"

module Decider ( clk,reset, d1en, d1out, Lo12, Li21, out_en,ou);
	parameter CHANNEL_WIDTH=`NOISE_BITWIDTH;
	input clk,reset, d1en, d1out;
	input [CHANNEL_WIDTH-1:0] Lo12,Li21;
	output out_en,ou;

	reg [CHANNEL_WIDTH-1:0] data;
	reg t;
	always @ (posedge clk) 
	if (d1out) begin
		t<=~t;
		data = Lo12 + Li21;
	end

	assign out_en=d1out;
	assign ou = Lo12[CHANNEL_WIDTH-1];
endmodule