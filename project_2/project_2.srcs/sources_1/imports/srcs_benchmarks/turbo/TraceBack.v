/* Taceback ASOVA Decoder

	In each period, the following will happen:
	1. read in a combo of u,p,Li
	2. write 1 column of trellis
	3. traceback T columns
	4. update D columns of reliability infomation
	5. output 1 Lo
	
	The delay will be T+D periods. Throughput will be at least T cycles (T>D)

	data port distribution = {sur_p,dis_p,new_dec,metric_diff};

*/

`include "parameters.v"
//`define PROBE
`undef PROBE

module TraceBack (clk, reset, u,p, Li, read, lo_en, Lo, done
`ifdef PROBE
	,level,pr0, pr1, pr2, pr3, pr4,pr5,pr6,pr7
`endif
);
	parameter BIT_WIDTH=`NOISE_BITWIDTH,
		WIN_SIZE=`MEM_SIZE,
		Nmax = `N_MAX,
		ADD_SIZE = `MEM_ADDWIDTH+`NMAX_WIDTH,
		POINTER_WIDTH = `NMAX_WIDTH,
		TSIZE = `TRACE_SIZE, DSIZE=`UPDATE_SIZE;
		
	input clk,reset;
	input [BIT_WIDTH-1:0] u,p,Li;
	output read,lo_en,done;
	output [BIT_WIDTH-1:0] Lo;
`ifdef PROBE
	//output [`MEM_ADDWIDTH+1:0] level;
	output [`CODE_ADD_WIDTH+1:0] level;
	output [ADD_SIZE-1:0] pr0,pr1,pr2,pr3;
	output [(BIT_WIDTH+2*POINTER_WIDTH+3)-1:0] pr4,pr5,pr6,pr7;
`endif
	wire [BIT_WIDTH-1:0] Lo;

/* -------------variables--------- */
	// write row pointer
	wire [POINTER_WIDTH-1:0] wrp;
	// write column pointer, wcp-1
	reg [`MEM_ADDWIDTH-1:0] wcp, wcp_one;
	// traceback row pointer
	wire [POINTER_WIDTH-1:0] tcrp;
	// traceback column pointer
	reg [`MEM_ADDWIDTH-1:0] tccp;
	// update write row pointer
	reg [POINTER_WIDTH-1:0] udrp;
	// update write column pointer
	reg [`MEM_ADDWIDTH-1:0] udcp;
	// update read column pointer
	reg [`MEM_ADDWIDTH-1:0] re_cp;
	// update read row pointer
	wire [POINTER_WIDTH-1:0] re_rp;
	// update read competitive path row pointer
	wire [POINTER_WIDTH-1:0] cmp_rp;

	// new input metric difference
	wire [BIT_WIDTH-1:0] metric_diff;
	wire md_valid;  // metric difference validity
	// new input survivor pointer and discarded path pointer
	wire [POINTER_WIDTH-1:0] sur_p, dis_p;
	wire dis_valid;  // discared path pointer valid
	// new input decision bit;
	wire new_dec;
	
	// traceback path pointer
	wire [POINTER_WIDTH-1:0] tr_pointer;
	
	// read delta, updated delta and the metric difference to be compared with all delta
	wire [BIT_WIDTH-1:0] rdel, updel;
	reg  [BIT_WIDTH-1:0] delta;
	wire redel_valid, upmd_valid; // read delta valid, updated delta valid
	// update delta pointer, competitive path pointer
	wire [POINTER_WIDTH-1:0] up_pointer, cmp_pointer;
	reg [ADD_SIZE-1:0] up_start_point;  // update start address, obtained by traceback
	reg cmp_valid; // competitive pointer valid
	// decision bit of competitive path and ML path
	wire cmp_dec, ml_dec;
	
	
	/* -------- Control Signals ----------- */
	reg [`CODE_ADD_WIDTH+1:0] level;
	// enable signals for new data write, traceback and delta update
	reg write_en, tr_en, update_en;
	// all of the three procedures are not working
	wire idle;
	reg idle_delay;
	wire idle_pulse; // raising edge of idle;
	
	// cycle count for each stage
	reg [`MEM_ADDWIDTH+1:0] step;	
	// ACS block start and finish
	wire acs_start, acs_finish;
	
	reg done;
	
	
	
	/*--------- Survivor Memory Interface ----- */	
	wire wr_en;
        reg up_write;
	wire [(BIT_WIDTH+2*POINTER_WIDTH+3)-1:0] data1,data2;
	wire [ADD_SIZE-1:0] wr_add,up_wadd,radd1,radd2,radd3;
	wire [(BIT_WIDTH+2*POINTER_WIDTH+3)-1:0] q2;
	wire [(2*POINTER_WIDTH+2)-1:0] q1,q3;

	/* -------- output -----------*/
`ifdef PROBE
	assign pr0 = wr_add;
	assign pr1 = radd1;
	assign pr2 = radd2;
	assign pr3 = radd3;
	assign pr4 = data1;
	assign pr5 = q1;
	assign pr6 = q2;
	assign pr7 = q3;
`endif

	assign read = acs_start;
	assign lo_en = (level>TSIZE+DSIZE+1) & (step==DSIZE);
	assign Lo = {ml_dec,updel[BIT_WIDTH-1:1]};

	always @ (posedge clk)
		if ( ~reset ) done <= 0; else 
		if ( level == WIN_SIZE + `CODE_SIZE ) done <= 1;

	/*--------- survivor memory ----------- */
	W2R3MEM sur_mem (clk,reset, data1, wr_add, wr_en, data2, up_wadd, update_en,
				q1, radd1, q2, radd2, q3, radd3);
	assign wr_add = {wcp,wrp};
	assign radd1 = {tccp,tcrp};
	assign up_wadd = {udcp,udrp};
	assign radd2 = {re_cp,re_rp};
	assign radd3 = {re_cp,cmp_rp};

	assign data1 = {sur_p,dis_p,dis_valid,new_dec,md_valid,metric_diff};
	assign data2 = {upmd_valid,updel};

	assign tr_pointer = q1[(2*POINTER_WIDTH+2)-1:(POINTER_WIDTH+2)];

	assign rdel = q2[BIT_WIDTH-1:0];
	assign redel_valid = q2[BIT_WIDTH];
	assign ml_dec = q2[BIT_WIDTH+1];
	assign up_pointer = q2[(BIT_WIDTH+2*POINTER_WIDTH+3)-1:(BIT_WIDTH+POINTER_WIDTH+3)];
	assign cmp_dec = q3[0];
	assign cmp_pointer = q3[(POINTER_WIDTH+2)-1:2];
	
	// stage start and finish control
	assign idle = ~(write_en | tr_en | update_en);
	always @ (posedge clk) idle_delay <= idle;
	assign idle_pulse = (~idle_delay) & idle;
	always @ (posedge clk) 
	if ((reset=='b0) | done) begin
		level=0;
		step<=0;
	end else if ( idle_pulse ) begin
		// stage finish when all 3 procedures finish
		step<=0;
		// make sure that it is only cycle each time
		level<=level+1;
	end else begin // any procedure is still working
		step<=step+1;
	end
	
	// traceback control
	always @ (posedge clk)
	if ( reset=='b0 | done) begin
		tr_en<=0;
	end else if ( (step==0) & (level>TSIZE+DSIZE) ) begin
		// start
		tr_en<=1;
		tccp<=tccp-1;
	end else if ( step== TSIZE ) begin
		// finish
		tr_en<=0;
		up_start_point <= {tccp,tcrp};
	end else if ( step>TSIZE) begin
		tccp<=wcp_one;  // after wcp increase one, wcp might be updated after traceback finishes
	end else if ( tr_en) begin// working
		tccp<=tccp-1;
	end
	assign tcrp = (step==0) ? 0 : tr_pointer;

	// update control
	//assign update_en = cmp_valid | (q2[BIT_WIDTH+2]& (step==0) & (level>TSIZE+DSIZE));
	always @ (posedge clk)
	if ( (reset=='b0)|done ) begin
		update_en<=0;
		up_write<=0;
	end else if ( (step==1) & (level>TSIZE+DSIZE+1) ) begin
		// setup new delta
		update_en <= q2[BIT_WIDTH+2];
		delta <= rdel;
		re_cp <= re_cp -1;
		up_write <= 1;		
	end else if ( step >= DSIZE ) begin
		// finish
		update_en <= 0;
		up_write <=0 ;
		
		re_cp <= up_start_point[ADD_SIZE-1:POINTER_WIDTH];  // obtain update start column
	end else begin// working
		re_cp <= re_cp -1;
	end
	assign re_rp = (step==0) ? up_start_point[POINTER_WIDTH-1:0] : up_pointer;
	assign cmp_rp = (step==1) ? q2[(POINTER_WIDTH+BIT_WIDTH+3)-1:(BIT_WIDTH+3)] : cmp_pointer;
	
	NEW_DELTA update_delta ( delta, rdel, redel_valid, ml_dec, cmp_dec, updel);
	assign upmd_valid=1; // the updated delta must be valid if writing
	
	// write new data.
	// Sub module generate row address and finish signal
	SEQ_ACS acs0 (clk,reset,u,p,Li, acs_start, 
		wrp, new_dec,metric_diff, md_valid,
		sur_p, dis_p, dis_valid, acs_finish, wr_en
//		, pr0,pr1,pr2,pr3,pr4
		);
	assign acs_start = (step==0) & (level<`CODE_SIZE) & (~done);
	always @ (posedge clk)
	if ((reset=='b0)|done)  begin // reset
		write_en <= 0;
		wcp <= 0;  // +1 before starting
	end else if ( (step==0) & (level<`CODE_SIZE) ) begin // start
		write_en <= 1;
	end else if (acs_finish) begin // finish
		wcp_one = wcp;
		wcp <= wcp + 1;  // start from 0
		write_en <= 0;
	end
	
endmodule




// obtain the updated delta
module NEW_DELTA ( me_diff, old_delta, old_delta_valid, ua, ub, new_delta);
parameter BIT_WIDTH=`NOISE_BITWIDTH;
input [BIT_WIDTH-1:0] me_diff, old_delta;
input old_delta_valid;
input ua, ub;
output [BIT_WIDTH-1:0] new_delta;


	assign new_delta = ( ((ua^ub) & (me_diff<old_delta)) | (~old_delta_valid) ) ?
		me_diff : new_delta;

endmodule
