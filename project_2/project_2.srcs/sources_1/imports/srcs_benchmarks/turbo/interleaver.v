/*********************************
	 mode block interleaver
input original address, output the interleaved address
all combitional logic, no clock
input sequence: 	000 001
					010 011
					100	101
					110 100
output sequnce:		001 011 101 100
					000	010 100 110
					
msb half of address: inverse, move to lsb
lsb half of address: move to msb
*/
`include "parameters.v"

module interleaver ( inadd, outadd );
parameter BIT_WIDTH=`NOISE_BITWIDTH;
parameter ROW=(BIT_WIDTH/2);
	input [BIT_WIDTH-1:0] inadd;
	output [BIT_WIDTH-1:0] outadd;

	assign outadd[ROW-1:0] = ~inadd[BIT_WIDTH-1:BIT_WIDTH-ROW];
	assign outadd[BIT_WIDTH-1:ROW] = inadd[BIT_WIDTH-ROW-1:0];

endmodule
	

module de_interleaver ( inadd, outadd );
parameter BIT_WIDTH=3;
parameter ROW=(BIT_WIDTH/2);
	input [BIT_WIDTH-1:0] inadd;
	output [BIT_WIDTH-1:0] outadd;

	assign outadd[BIT_WIDTH-1:BIT_WIDTH-ROW] = ~inadd[ROW-1:0];
	assign outadd[BIT_WIDTH-ROW-1:0] = inadd[BIT_WIDTH-1:ROW];

endmodule



/* interleaver buffer from D1 to D2
	when d1out, read from d1 and write into mem
	when d2en, read from mem and send data to d2
	pingpang
	
	*NOTE: data0 is always presenting on the read port;
		when d2en=1, data1 will apear after the first clk posedge
*/
module InterBuffer ( clk, reset, d1out, Lo12, d2en, Li12, pingpang );
	parameter BIT_WIDTH=`NOISE_BITWIDTH,
		ADD_WIDTH=`CODE_ADD_WIDTH;
	input clk,reset,d2en,d1out,pingpang;
	input [BIT_WIDTH-1:0] Lo12;
	output [BIT_WIDTH-1:0] Li12;
	
	reg pDelay;  //pingpang delay
	reg stateAB;
	wire a_wen, b_wen;	

	always @ (posedge clk ) pDelay <= pingpang;
    always @ (posedge clk)
		//if ( reset==0 )	stateAB=0; else
		if (pingpang & (~pDelay) ) stateAB <= ~stateAB;  // if posedge pingpang
	assign a_wen=d1out & (~stateAB);
	assign b_wen=d1out & stateAB;


	reg [ADD_WIDTH-1:0] wadd, radd;
	wire [ADD_WIDTH-1:0] raddi; // output of interleaver
	wire [BIT_WIDTH-1:0] outa,outb;

	MEM mema ( clk, wadd, a_wen, Lo12, raddi, outa );
	MEM memb ( clk, wadd, b_wen, Lo12, raddi, outb);
	
	always @ (posedge clk)
	if ( (reset==0)| pingpang ) begin
		wadd<=0; radd<=0;
	end else begin
		if ( d2en== 1'b1 )	radd<=radd+1;
		if ( d1out== 1'b1 ) wadd<=wadd+1;
	end

	interleaver inter1 ( radd, raddi );

	assign Li12 = stateAB ? outa : outb;
	
endmodule

/* interleaver buffer from D2 to D1
*/
module DeInterBuffer ( clk, reset, d2out, Lo21, d1en, Li21, pingpang );
	parameter BIT_WIDTH=`NOISE_BITWIDTH,
		ADD_WIDTH=`CODE_ADD_WIDTH;
	input clk,reset,d1en,d2out,pingpang;
	input [BIT_WIDTH-1:0] Lo21;
	output [BIT_WIDTH-1:0] Li21;

	reg pDelay;  //pingpang delay
	reg stateAB;
	wire a_wen, b_wen;	

	always @ (posedge clk ) pDelay <= pingpang;
    always @ (posedge clk)
		//if ( reset==0 )	stateAB=0; else 
	    if (pingpang & (~pDelay) ) stateAB <= ~stateAB;  // if posedge pingpang
	assign a_wen=d2out & (~stateAB);
	assign b_wen=d2out & stateAB;

	reg [ADD_WIDTH-1:0] wadd, radd;
	wire [ADD_WIDTH-1:0] raddi; // output of interleaver
	wire [BIT_WIDTH-1:0] outa,outb;

	MEM mema ( clk, wadd, a_wen, Lo21, raddi, outa );
	MEM memb ( clk, wadd, b_wen, Lo21, raddi, outb);
	
	always @ (posedge clk)
	if ( (reset==0) | pingpang ) begin
		wadd<=0; radd<=0;
	end else begin
		if ( d1en== 1'b1 )	radd<=radd+1;
		if ( d2out== 1'b1 ) wadd<=wadd+1;
	end

	de_interleaver inter1 ( radd, raddi );
		defparam inter1.BIT_WIDTH = BIT_WIDTH;

	assign Li21 = stateAB ? outa : outb;
	
endmodule