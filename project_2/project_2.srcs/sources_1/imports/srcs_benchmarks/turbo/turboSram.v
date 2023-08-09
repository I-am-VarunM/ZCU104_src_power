/*
   The Turbo Decoder System using SRAM port to communicate with Nios
	That is the version to work with Nios Standard_32
	The SRAM has two banks.
	The reading from these two banks are controlled by the highest bit of the read_address
	
	Each bank has 4 memory blocks for u,p,q and o respectively.
	Block u has two read ports because it needs to provide both u and iu.
	Address: Block u and p use in_add, and block iu and q use in_iadd.
	Block o is the decoded bits. Its write port is 1-bit wide and read port is 8-bit wide for Nios.
*/
`include "parameters.v"
//`define PROBE
module turboSram ( clk,reset, up_in, iuq_in, in_add, in_iadd,
	decoded, out_add, out_en,
	pingpang,bank,all_done
`ifdef PROBE
	,probe1, probe2,probe3
`endif
	);
	parameter CHANNEL_WIDTH=`NOISE_BITWIDTH, ADD_WIDTH=`CODE_ADD_WIDTH;
	input clk,reset;
    input [2*CHANNEL_WIDTH-1:0] up_in, iuq_in;
	output [ADD_WIDTH:0] in_add, in_iadd;
    output decoded;
	output [9:0] out_add;
	output out_en;
	output pingpang;
`ifdef PROBE
	output [CHANNEL_WIDTH-1:0] probe1;
	wire [CHANNEL_WIDTH-1:0] probe1;
	output [`CODE_ADD_WIDTH+1:0] probe2, probe3;
	wire [`CODE_ADD_WIDTH+1:0] probe2, probe3;
`endif
	output bank;
	output [3:0] all_done;
	reg [3:0] all_done;
	
	wire reset,lreset;
	wire done1, done2;
	wire [CHANNEL_WIDTH-1:0] u,p,q; 
	wire [CHANNEL_WIDTH-1:0] ub;   /* interleaved u */
	wire d1en,d2en;
	wire d1out,d2out;

	wire [CHANNEL_WIDTH-1:0] Li12, Lo12, Li21, Lo21;
	wire decided_bit;

	reg [ADD_WIDTH-1:0] radd, iradd;
	reg [9:0] wadd;
	reg bank;
	reg ppd; //pingpang delay
	reg outenr; //out_en delay
	
	// sram addresses
	assign in_add[ADD_WIDTH-1:0]=radd;
	assign in_iadd[ADD_WIDTH-1:0]=iradd;
	assign in_add[ADD_WIDTH] = bank;
	assign in_iadd[ADD_WIDTH] = bank;

	assign out_add = wadd;
//	assign out_add[ADD_WIDTH] = bank;
	
	always @ (posedge clk) outenr<=out_en;
	
	always @ (posedge clk) 
		if ( lreset == 1'b0 ) begin
			radd<=0; iradd<=0;
		end else begin 
			if (d1en) radd<=radd+1;
			if (d2en) iradd<=iradd+1;
		end
	always @ (posedge clk)
		if ( lreset == 1'b0 ) wadd<=0;
		else  begin
			//if (wadd == `CODE_SIZE) wadd<=0;
			if ( out_en&!outenr ) wadd<=wadd+1;
		end
	
	always @ (posedge clk)
		if ( reset == 1'b0 ) begin bank<=0;
		end else begin
			ppd <= pingpang;
			if ( ~ppd & pingpang ) begin
				bank<=~bank;  // flap when postedge of pingpang
			end
		end

	always @ (posedge clk)
	if (~reset) all_done<=1;
	else if ( ~ppd & pingpang ) all_done<=all_done+1;

	// SRAM data port
	assign u = up_in[2*CHANNEL_WIDTH-1:CHANNEL_WIDTH];
	assign ub = iuq_in[2*CHANNEL_WIDTH-1:CHANNEL_WIDTH];
	assign p = up_in[CHANNEL_WIDTH-1:0];
	assign q = iuq_in[CHANNEL_WIDTH-1:0];


	/* two turbo decoders
	  when d1en, read u,p,Li12
	  when d1out, write Lo21
    */
//	ASOVA d1 (clk,reset, u,p, Li21, d1en, d1out, Lo12, done1);
//	ASOVA d2 (clk,reset, ub,q, Li12, d2en, d2out, Lo21,done2);
	TraceBack d1 (clk,lreset, u,p, Li21, d1en, d1out, Lo12, done1);
	TraceBack d2 (clk,lreset, ub,q, Li12, d2en, d2out, Lo21, done2);


	/* interleaver and deinterleaver between d1 and d2 */
	InterBuffer inter12 ( clk, reset, d1out, Lo12, d2en, Li12, pingpang );
		defparam inter12.BIT_WIDTH=`NOISE_BITWIDTH,
			inter12.ADD_WIDTH=`CODE_ADD_WIDTH;

	DeInterBuffer inter21 ( clk, reset, d2out, Lo21, d1en, Li21, pingpang );
		defparam inter21.BIT_WIDTH=`NOISE_BITWIDTH,
			inter21.ADD_WIDTH=`CODE_ADD_WIDTH;
	//assign Li12=Lo12;
	//assign Li21=Lo21;

	Decider decider1 ( clk,reset, d1en, d1out, Lo12, Li21, out_en,decided_bit);
	assign decoded = decided_bit;


	/* decide when to switch pingpang */
	assign pingpang = done1 & done2;
	//greset is global reset, use "reset" to clear Decoder buffer for every iteration
	assign lreset = reset & ~pingpang; 

`ifdef PROBE
	assign probe1[0]=done1;
	assign probe1[1]=done2;
always @(posedge clk)
	if ( out_add==24 & out_en) begin
	//probe2[0]=1;
	 //probe3[0]=out_en;
	 //probe3[1]=decoded;
	end
`endif
endmodule
