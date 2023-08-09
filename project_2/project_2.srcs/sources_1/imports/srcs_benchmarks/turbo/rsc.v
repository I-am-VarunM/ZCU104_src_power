`include "parameters.v"

/* RSC encoder
	Given the u, and pre-state, generate the next state and p
*/

module RSC (u, ps, ns, p);
parameter STATE_NUM=`STATE_NUM;
input u;
input [STATE_NUM-1:0] ps;
output [STATE_NUM-1:0] ns;
output p;
	
	reg p;
	wire [STATE_NUM-1:0] ps;
	reg [STATE_NUM-1:0] ns;
	integer i,j;
	reg s0;
	wire [STATE_NUM:0] rg1;
	wire [STATE_NUM:0] rg2;
	reg [STATE_NUM:0] g1;
	reg [STATE_NUM:0] g2;
	
	assign rg1 = `G1;
	assign rg2 = `G2;
	always for (j=0;j<=STATE_NUM;j=j+1) begin
		g1[j]<=rg1[STATE_NUM-j];
		g2[j]<=rg2[STATE_NUM-j];
	end
	
	always @ (u or ps) begin
		s0 = g1[0] & u;
		
		for (i=0;i<STATE_NUM;i=i+1) begin
			s0 = s0 ^ ( g1[i+1] & ps[i]);
		end

		p = g2 & s0;
		for (i=0;i<STATE_NUM;i=i+1) begin
			p = p ^ (g2[i+1] & ps[i]);
		end
		
		for (i=1;i<STATE_NUM;i=i+1)	
			ns[i] = ps[i-1];
		ns[0] = s0;
	end


endmodule