`include "parameters.v"

/* 2 write port, 3 read port memory, for ASOVA survivor memory only
	Clocked memmory. Data will apprear on the output port after clk edge.
 */
/*
  	data1: {pointer to survivor,
		pointer to competitive, vlaid_bit of comptetive pointer,
		decision bit,
		delta valid, delta}
  	data2: {deltat valid, updated delta}
	q1: traceback data
	q2: delta to be updated and its pointers
	q3: competitive decision bit and pointer
*/
module W2R3MEM (clk,reset, data1, wr_add, wen1,
				data2, wadd2, wen2,
				q1, radd1, q2, radd2, q3, radd3);
parameter DELTA_WIDTH=`NOISE_BITWIDTH,
		NMAX=`N_MAX,
		POINTER_WIDTH=`NMAX_WIDTH,
		MEM_SIZE=`MEM_SIZE,
		ADD_SIZE=`MEM_ADDWIDTH+`NMAX_WIDTH;
input clk,reset;
input wen1,wen2;
input [(DELTA_WIDTH+2*POINTER_WIDTH+3)-1:0] data1;
input [DELTA_WIDTH:0] data2; // delat valid, update delta only
input [ADD_SIZE-1:0] wr_add,wadd2,radd1,radd2,radd3;
output [(DELTA_WIDTH+2*POINTER_WIDTH+3)-1:0] q2;
output [(2*POINTER_WIDTH+2)-1:0] q1,q3;

	// memory bank # for write new data
	wire [1:0] bank, up_bank, tr_bank, re_bank;
	reg [1:0] rd1_de, rd2_de, rd3_de;  // delay of the bank-bits of radd1,radd2,radd3
	// address includes MEM_ADDWIDTH column_bits and NMAX_WIDTH row_bits
	wire [ADD_SIZE-1:0] wr_add, tc_add, up_addr, up_addo, up_addw;


/* ---------- interface variables ------------*/
	// write address of 4 memory banks
	wire [ADD_SIZE-3:0] wadda,waddb,waddc,waddd;
	// write enable for delta memory banks
	wire wena, wenb, wenc, wend;
	// input data of the delta memory banks
	wire [DELTA_WIDTH:0] da, db, dc, dd;
	// read address of delta memory banks
	wire [ADD_SIZE-3:0] radd;
	// output data of the delta memory banks
	wire [DELTA_WIDTH:0] delta0, delta1, delta2, delta3;

	// write enable for pointer memory banks
	wire wenpa, wenpb, wenpc, wenpd;
	// input data of pointer memory: two pointers, one decision bit and dis_valid
	wire [(2*POINTER_WIDTH+2)-1:0] dp;
	// read address of delta memory banks
	wire [ADD_SIZE-3:0] radda, raddb, raddc, raddd;
	// output data of pointer memory
	wire [(2*POINTER_WIDTH+2)-1:0] q0a,q1a,q2a,q3a,q0b,q1b,q2b,q3b;


	// 4 memory bank for delta
	MEM md0 ( clk, wadda, wena, da, radd, delta0 );
	MEM md1 ( clk, waddb, wenb, db, radd, delta1 );
	MEM md2 ( clk, waddc, wenc, dc, radd, delta2 );
	MEM md3 ( clk, waddd, wend, dd, radd, delta3 );
	defparam md0.BIT_WIDTH=DELTA_WIDTH+1,
		md0.ADD_WIDTH = ADD_SIZE-2, md0.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam md1.BIT_WIDTH=DELTA_WIDTH+1,
		md1.ADD_WIDTH = ADD_SIZE-2, md1.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam md2.BIT_WIDTH=DELTA_WIDTH+1,
		md2.ADD_WIDTH = ADD_SIZE-2, md2.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam md3.BIT_WIDTH=DELTA_WIDTH+1,
		md3.ADD_WIDTH = ADD_SIZE-2, md3.MEM_SIZE = NMAX*MEM_SIZE/4;

	// 4 memory banks for decision, pointers
	// they need two read ports when updating
	MEM2R m0( clk, wadda, wenpa, dp, radda, q0a, radd3, q0b );
	MEM2R m1( clk, waddb, wenpb, dp, raddb, q1a, radd3, q1b );
	MEM2R m2( clk, waddc, wenpc, dp, raddc, q2a, radd3, q2b );
	MEM2R m3( clk, waddd, wenpd, dp, raddd, q3a, radd3, q3b );	
	defparam m0.BIT_WIDTH=2*POINTER_WIDTH+2,
		m0.ADD_WIDTH = ADD_SIZE-2, m0.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam m1.BIT_WIDTH=2*POINTER_WIDTH+2,
		m1.ADD_WIDTH = ADD_SIZE-2, m1.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam m2.BIT_WIDTH=2*POINTER_WIDTH+2,
		m2.ADD_WIDTH = ADD_SIZE-2, m2.MEM_SIZE = NMAX*MEM_SIZE/4;
	defparam m3.BIT_WIDTH=2*POINTER_WIDTH+2,
		m3.ADD_WIDTH = ADD_SIZE-2, m3.MEM_SIZE = NMAX*MEM_SIZE/4;

	assign bank = wr_add[ADD_SIZE-1:ADD_SIZE-2];
	assign up_bank = wadd2[ADD_SIZE-1:ADD_SIZE-2];
	assign tr_bank = radd1[ADD_SIZE-1:ADD_SIZE-2];
	assign re_bank = radd2[ADD_SIZE-1:ADD_SIZE-2];
	
	// write address
	assign wadda= ( bank=='b00) ? wr_add[ADD_SIZE-3:0] : wadd2[ADD_SIZE-3:0];
	assign waddb= ( bank=='b01) ? wr_add[ADD_SIZE-3:0] : wadd2[ADD_SIZE-3:0];
	assign waddc= ( bank=='b10) ? wr_add[ADD_SIZE-3:0] : wadd2[ADD_SIZE-3:0];
	assign waddd= ( bank=='b11) ? wr_add[ADD_SIZE-3:0] : wadd2[ADD_SIZE-3:0];
	
	// write enable
	assign wena= ((bank=='b00) & wen1) | ((up_bank=='b00) & wen2);
	assign wenb= ((bank=='b01) & wen1) | ((up_bank=='b01) & wen2);
	assign wenc= ((bank=='b10) & wen1) | ((up_bank=='b10) & wen2);
	assign wend= ((bank=='b11) & wen1) | ((up_bank=='b11) & wen2);

	// pointer memory will not be written when updating
	assign wenpa= (bank=='b00)  ? wen1 : 0;
	assign wenpb= (bank=='b01)  ? wen1 : 0;
	assign wenpc= (bank=='b10)  ? wen1 : 0;
	assign wenpd= (bank=='b11)  ? wen1 : 0;

	// write data
	assign da= ( bank=='b00) ? data1[DELTA_WIDTH:0] : data2;
	assign db= ( bank=='b01) ? data1[DELTA_WIDTH:0] : data2;
	assign dc= ( bank=='b10) ? data1[DELTA_WIDTH:0] : data2;
	assign dd= ( bank=='b11) ? data1[DELTA_WIDTH:0] : data2;
	assign dp= data1[(DELTA_WIDTH+2*POINTER_WIDTH+3)-1 : (DELTA_WIDTH+1)];
	
	// read address
	assign radd = radd2[ADD_SIZE-3:0];
	assign radda = (tr_bank=='b00) ? radd1[ADD_SIZE-3:0] : radd2[ADD_SIZE-3:0];
	assign raddb = (tr_bank=='b01) ? radd1[ADD_SIZE-3:0] : radd2[ADD_SIZE-3:0];
	assign raddc = (tr_bank=='b10) ? radd1[ADD_SIZE-3:0] : radd2[ADD_SIZE-3:0];
	assign raddd = (tr_bank=='b11) ? radd1[ADD_SIZE-3:0] : radd2[ADD_SIZE-3:0];

	// read data is one cycle after the address is given
	always @ (posedge clk) begin
		rd1_de<=radd1[ADD_SIZE-1:ADD_SIZE-2];
		rd2_de<=radd2[ADD_SIZE-1:ADD_SIZE-2];
		rd3_de<=radd3[ADD_SIZE-1:ADD_SIZE-2];
	end
	assign q1 = (rd1_de[1]) ? 
		(rd1_de[0] ? q3a : q2a) :  (rd1_de[0] ? q1a : q0a);
	assign q2 = (rd2_de[1]) ? 
		(rd2_de[0] ? {q3a,delta3} : {q2a,delta2}) 
			: (rd2_de[0] ? {q1a,delta1} : {q0a,delta0});
	assign q3 = (rd3_de[1]) ? (rd3_de[0] ? q3b : q2b) :  (rd3_de[0] ? q1b : q0b);

endmodule
