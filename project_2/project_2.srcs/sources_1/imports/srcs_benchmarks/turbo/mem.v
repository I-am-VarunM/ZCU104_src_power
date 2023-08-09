`include "parameters.v"

// two ports memory block

module MEM ( clk, wadd, wen, data, radd, q );
parameter BIT_WIDTH=`NOISE_BITWIDTH, ADD_WIDTH = `CODE_ADD_WIDTH, MEM_SIZE = `CODE_SIZE;

	input clk, wen;
	input [ADD_WIDTH-1:0] wadd, radd;
	input [BIT_WIDTH-1:0] data;
	output [BIT_WIDTH-1:0] q;
//	output [BIT_WIDTH-1:0] m_test ;

`ifdef ALTERA  // if it is Quartus Altera chip
	dpram amem (
	.data(data),
	.wren(wen),
	.wraddress(wadd),
	.rdaddress(radd),
	.clock(clk),
	.q(q));
	
	defparam amem.DATA_WIDTH=BIT_WIDTH,
		amem.ADD_WIDTH=ADD_WIDTH,
		amem.MEM_SIZE=MEM_SIZE;
	
`else
	reg [BIT_WIDTH-1:0] memory [MEM_SIZE-1:0];
	
	always @ ( posedge clk )
	begin
		if ( wen ) begin
			memory[wadd] <= data;
$display ( "memory[%d]=%d\n",wadd,memory[wadd]);			
		end 
	end

	assign q = memory[radd];
//	assign m_test = memory[0];
`endif
	
endmodule


/* 2 read ports memory */
module MEM2R ( clk, wadd, wen, data, radda, qa, raddb, qb );
parameter BIT_WIDTH=`NOISE_BITWIDTH, ADD_WIDTH = `CODE_ADD_WIDTH, 
	MEM_SIZE = `CODE_SIZE;

	input clk, wen;
	input [ADD_WIDTH-1:0] wadd, radda, raddb;
	input [BIT_WIDTH-1:0] data;
	output [BIT_WIDTH-1:0] qa, qb;
	

`ifdef ALTERA
	tpram amem (
	.data(data),
	.wraddress(wadd),
	.rdaddress_a(radda),
	.rdaddress_b(raddb),
	.wren(wen),
	.clock(clk),
	.qa(qa),
	.qb(qb));

	defparam	amem.DATA_WIDTH=BIT_WIDTH,
		amem.ADD_WIDTH=ADD_WIDTH,
		amem.MEM_SIZE=MEM_SIZE;

`else	
	reg [BIT_WIDTH-1:0] memory [MEM_SIZE-1:0];
	
	always @ ( posedge clk )
	begin
		if ( wen ) begin
			memory[wadd] <= data;
		end 
	end
	
	assign qa = memory[radda];
	assign qb = memory[raddb];
`endif
endmodule