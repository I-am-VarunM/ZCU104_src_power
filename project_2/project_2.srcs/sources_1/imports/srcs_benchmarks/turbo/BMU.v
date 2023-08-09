`include "parameters.v"
`define PROBE
/* 
	Branch Metric Gengerate Unit
	it generates branch metric for input 00,01,10,11
	it works for rate 2 codes only

	bm(uk,pk) = (1/2) uk*L(uk) + Lc/2 * (y*uk+p*pk)
		(uk,pk) = {-1,1}
		
	??? should I take (uk,pk)={0,1}?? 
		then in the branch (ukpk)=(00), bm0=0;

	input: 
		u,p: signed BIT_WIDTH with DECIMAL_POINT
		Li: signed BIT_WIDTH integer
	output:
		bm0,1,2,3: signed
			bitwidth=2*BIT_WIDTH
			decial point = 2*DECIMAL_POINT+1, 1 because of (1/2)
*/

module BMU ( clk, en, 
	u, p, Li,
	bm0,bm1,bm2,bm3,
	product0,product1,product2,product3
`ifdef PROBE	
	,probe0,probe1,probe2,probe3
`endif
	);

	parameter BIT_WIDTH=`NOISE_BITWIDTH;
	parameter DECIMAL_POINT = `FIX_POINT;

	input clk,en;
	input [BIT_WIDTH-1:0] u, p, Li;
	output [BIT_WIDTH-1:0] bm0,bm1,bm2,bm3;
	//output [2*BIT_WIDTH-1:0] out;
`ifdef PROBE
	output [BIT_WIDTH:0] probe0,probe1,probe2,probe3;
`endif

	wire [2*BIT_WIDTH:0] Lc;
	
	// to prevent overflow, bitwidth increase 1
	wire [BIT_WIDTH:0] ui,pi;
	output [2*BIT_WIDTH:0] product0, product1, product2,product3;
	// Note!!: BIT_WIDTH+1
	wire [BIT_WIDTH:0] a0,a1,a2,a3;  //(y*uk+p*pk),
	reg [2*BIT_WIDTH-2*DECIMAL_POINT-1:0] re0,re1,re2,re3;  // results


	reg  [BIT_WIDTH-1:0] bmr0,bmr1,bmr2,bmr3;
	assign bm0 = bmr0;
	assign bm1 = bmr1;
	assign bm2 = bmr2;
	assign bm3 = bmr3;

	assign Lc=`LC_VALUE;
	assign ui={u[BIT_WIDTH-1],u};
	assign pi={p[BIT_WIDTH-1],p};

	assign a0 = TCAdder(-ui,-pi);
	assign a1 = -ui+pi;
	assign a2 = ui-pi;
	assign a3 = ui+pi;


	DW02_mult  mult0 (Lc, a0, 1'b1, product0);
		defparam mult0.A_width=BIT_WIDTH, mult0.B_width=BIT_WIDTH+1;
	DW02_mult  mult1 (Lc, a1, 1'b1, product1);
		defparam mult1.A_width=BIT_WIDTH, mult1.B_width=BIT_WIDTH+1;
	DW02_mult  mult2 (Lc, a2, 1'b1, product2);
		defparam mult2.A_width=BIT_WIDTH, mult2.B_width=BIT_WIDTH+1;
	DW02_mult  mult3 (Lc, a3, 1'b1, product3);
		defparam mult3.A_width=BIT_WIDTH, mult3.B_width=BIT_WIDTH+1;
		
	always @ ( posedge clk ) 
//	if ( en ) 
	begin
		// uk,pk = 0,0
		re0 = product0[2*BIT_WIDTH:2*DECIMAL_POINT] - Li;
		re1 = product1[2*BIT_WIDTH:2*DECIMAL_POINT] - Li;
		re2 = product2[2*BIT_WIDTH:2*DECIMAL_POINT] + Li;
		re3 = product3[2*BIT_WIDTH:2*DECIMAL_POINT] + Li;

		if (2*BIT_WIDTH-2*DECIMAL_POINT > BIT_WIDTH ) begin
			bmr0= re0[2*BIT_WIDTH-2*DECIMAL_POINT-1:2*BIT_WIDTH-2*DECIMAL_POINT-BIT_WIDTH];
			bmr1= re1[2*BIT_WIDTH-2*DECIMAL_POINT-1:2*BIT_WIDTH-2*DECIMAL_POINT-BIT_WIDTH];
			bmr2= re2[2*BIT_WIDTH-2*DECIMAL_POINT-1:2*BIT_WIDTH-2*DECIMAL_POINT-BIT_WIDTH];
			bmr3= re3[2*BIT_WIDTH-2*DECIMAL_POINT-1:2*BIT_WIDTH-2*DECIMAL_POINT-BIT_WIDTH];
		end else begin
			bmr0=re0;
			bmr1=re1;
			bmr2=re2;
			bmr3=re3;
		end
	end


/* 	
	The overcome the overflow of -(-4)-(-4)=8
*/
	function [BIT_WIDTH:0] TCAdder;
		input [BIT_WIDTH:0] A;
		input [BIT_WIDTH:0] B;

		reg [BIT_WIDTH:0] tcsum;
		integer TCi;

	begin
//		wire [BIT_WIDTH-1:0] temp_s;
		tcsum = A + B;


		if ( A[BIT_WIDTH] ^ B[BIT_WIDTH] ) begin  // + and -
			TCAdder = tcsum;
		end else 
			if ( A[BIT_WIDTH] )	begin  // - and -
				if ( tcsum[BIT_WIDTH]) 
					TCAdder=tcsum;
				else begin
					for (TCi=0;TCi<BIT_WIDTH;TCi=TCi+1)
						TCAdder[TCi]=0;
					TCAdder[BIT_WIDTH]=1;
				end
			end else // + and +
				if ( tcsum[BIT_WIDTH] ) begin
					for (TCi=0;TCi<BIT_WIDTH;TCi=TCi+1)
						TCAdder[TCi] = 1;
					TCAdder[BIT_WIDTH]=0;
				end	else
					TCAdder = tcsum;
	end
	endfunction

`ifdef PROBE
	assign probe0 = a0;
	assign probe1 = a1;
	assign probe2 = a2;
	assign probe3 = a3;
`endif

endmodule