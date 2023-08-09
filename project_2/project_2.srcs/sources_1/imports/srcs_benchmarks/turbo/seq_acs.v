`define PROBE

/* when start goes high, start to computer one path metric at each cycle */
module SEQ_ACS (clk,reset,u,p,Li,start, 
	pointer, decision, metric_diff, md_valid, 
	sur_pointer, dis_pointer, dis_valid, done, out_en
`ifdef PROBE
	, pre_add, probe0,probe1,probe2,probe3
`endif
	);
parameter BIT_WIDTH=`NOISE_BITWIDTH, POINTER_WIDTH=`NMAX_WIDTH,
	NMAX=`N_MAX;
input clk, reset;
input [BIT_WIDTH-1:0] u,p,Li;
input start; // start to compute, one cycle high
output [POINTER_WIDTH-1:0] pointer; // current output row address
output decision; // decision bit
output [BIT_WIDTH-1:0] metric_diff;
output md_valid, dis_valid;  // metric difference valid, discarded path pointer valid
output [POINTER_WIDTH-1:0] sur_pointer, dis_pointer; // survivor path pointer, discarded path pointer
output done;
output out_en;

`ifdef PROBE
output [POINTER_WIDTH:0] pre_add;
output [3:0] probe0,probe1,probe2,probe3;
`endif


/* --------------- variables ------------------- */
	reg [POINTER_WIDTH-1:0] pointer; // current output row address
	// previous path metric
	reg [BIT_WIDTH-1:0] pre_metric [NMAX-1:0];
	// current path metric
	reg [BIT_WIDTH-1:0] metric [NMAX-1:0];
	// path valid and pre-path valid
	reg [NMAX-1:0] path_valid, pre_valid;
	// indicate if the path has been used to compute next metric
	// each state can generate two paths
	reg [2*NMAX-1:0] path_used;
	// indicate if the state is stored in the memory
	reg [`ALL_STATE-1:0] pre_state_valid, state_valid;
	
	// obtain the path state from the current path address
	reg [`STATE_NUM-1:0] path_state [NMAX-1:0];
	reg [`STATE_NUM-1:0] pre_path_state [NMAX-1:0];

	// threshold of metric to prune path, update every level
	reg [BIT_WIDTH-1:0] Threshold;
	// state of the two merging paths for each ACS block
	// these should be a fixed number of a given code
	reg [`STATE_NUM-1:0] path0 [`ALL_STATE-1:0];
	reg [`STATE_NUM-1:0] path1 [`ALL_STATE-1:0];
	// obtain the path address from the current path state
	reg [POINTER_WIDTH-1:0] path_id [`ALL_STATE-1:0];
	reg [POINTER_WIDTH-1:0] new_path_id [`ALL_STATE-1:0];

	wire [BIT_WIDTH-1:0] bm0,bm1,bm2,bm3;  // branch metric 00,01,10,11

	reg [`STATE_NUM-1:0] cstate_delay;
	wire [`STATE_NUM-1:0] current_state;
	wire current_p;
	

	// interface for ACS BLOCK
        wire [BIT_WIDTH-1:0] metric_out;
	reg [BIT_WIDTH-1:0] m0, m1, p0,p1, old_metric0, old_metric1;
	reg valid0, valid1;
	wire m_valid;
	wire [POINTER_WIDTH-1:0] p0_add, p1_add;
	reg [POINTER_WIDTH-1:0] p0add_delay, p1add_delay;
	reg m0_valid, m1_valid;
	wire less; // metric < Threshold
	wire acs_decision;
	wire [`STATE_NUM-1:0] other_path_state; // the state of the merging path

	/* ------- control signals ----------*/
	integer i,j,k;
	// the number of paths that meet the Threshold
	// need one more bit than NMAX since it counts up to NMAX
	reg [POINTER_WIDTH:0] count;
	// address of pre_path
	reg [POINTER_WIDTH:0] pre_add;
	// count>NMAX, need to increase threshold and start over
	wire over_count;
	wire all_invalid; // no path valid after check all states
	reg working;

	// current output meet the requirement of validility and threshold
	wire output_valid;
	reg acsin_valid;
	wire fnsh_cond;  // possible finish condition: all pre-paths have been checked 
	reg finish, finish_delay;  // finish current column
	wire finish_pulse;
	

/* ----------- Procedure ---------------------*/

`ifdef PROBE
	assign probe0[0]=m0_valid;
	assign probe0[1]=m1_valid;
	assign probe0[2]=working;
	assign probe0[3]=out_en;
	assign probe1=p1_add;
	assign probe2=Threshold;
	assign probe3=over_count;
`endif	

	always @ (posedge clk) acsin_valid = working & (!path_used[pre_add]);
	assign out_en = output_valid;
	assign output_valid =  acsin_valid & m_valid & less;
	assign sur_pointer = acs_decision ? p1add_delay : p0add_delay;
	assign dis_pointer = acs_decision ? p0add_delay : p1add_delay;
	// the path from the previous metric is always valid. Only need to look at the merging path
	assign dis_valid = m1_valid;
	assign done = finish_pulse;
	
	/* locate the path state for each ACS */
/*	always for ( k=0;k<`ALL_STATE;k=k+1) begin
		path0[k] <= pre_state (k,0);
		path1[k] <= pre_state (k,1);
	end
*/

	/* BMU generate branch metric for (00,01,10,11) */
	BMU bmu ( clk, 1, u, p, Li, bm0,bm1,bm2,bm3);


	// working condition
	// finish condition
	assign fnsh_cond = (pre_add==2*NMAX-1) | (pre_valid[pre_add[POINTER_WIDTH:1]]==0);
	always @ (posedge clk) 
	if ( reset== 1'b0 ) begin
		finish <= 0;
		working <= 0;
	end else if ( fnsh_cond	& (~over_count)) begin
			finish <= 1;
			working <= 0;
	end else begin 
		finish <= 0;
		if (start) working <= 1;
	end
	always @ (posedge clk) finish_delay <= finish;
	assign finish_pulse = finish & ~finish_delay;
	
	
	always @ (posedge clk)
	if ( reset== 1'b0 ) begin
		pointer <= 0;
		pre_add <= 0;
		
		for(i=0;i<NMAX;i=i+1) path_valid[i]<=0;
		for(i=0;i<`ALL_STATE;i=i+1) state_valid[i]<=1'b0;
	end else if ( finish_pulse | over_count ) begin
		for(i=0;i<NMAX;i=i+1) path_valid<=0;
		for(i=0;i<`ALL_STATE;i=i+1) state_valid[i]<=0;
		pre_add <= 0;
		pointer <= 0;
	end else begin
		if ( working ) begin
			pre_add <= pre_add + 1;
		end
		if ( output_valid ) begin
			// if Threshold>0, metric=metric_out--;
			metric[pointer] <= Threshold[BIT_WIDTH-1] ? metric_out : metric_out-Threshold;
			path_valid[pointer]<=1;
			path_state[pointer] <= cstate_delay;
			state_valid[cstate_delay] <= 1'b1;
			new_path_id[cstate_delay] <= pointer;
			pointer <= pointer + 1;
		end
	end


	// ACS input
	assign p0_add = pre_add[POINTER_WIDTH:1];
	assign p1_add = path_id[other_path_state];
	always @ (posedge clk) begin
		old_metric0 = pre_metric[p0_add];
		old_metric1 = pre_metric[p1_add];
		m0_valid = pre_valid[p0_add];
		m1_valid = pre_valid[p1_add] & pre_state_valid[other_path_state];
		p0 = bm_choice(pre_add[0],current_p);
		p1 = bm_choice(~pre_add[0],~current_p); // the p of the merging paths are always odd?
	end
	// ACS output
	assign decision = ~pre_add[0] ^ acs_decision;  // it is (pre_add[0]_delay^acs_decision
	always @ (posedge clk) begin 
		cstate_delay = current_state;
		p0add_delay = p0_add;
		p1add_delay = p1_add;
	end
	
	RSC rsc0 (pre_add[0],pre_path_state[pre_add[POINTER_WIDTH:1]],current_state, current_p);
	PRESTATE prestate0 ( current_state, ~pre_add[0], other_path_state);
	// path0 is always from pre_metric, and path1 is always from indexing
	ACS_BLOCK acsblock (old_metric0, old_metric1, 
		m0_valid, m1_valid, p0, p1,
		acs_decision, metric_out, metric_diff, m_valid, md_valid);
	IS_LESS comparotor (Threshold,metric_out,1, less); 

	// pruning
	always @ (posedge clk)
	if ( (reset=='b0) | finish_pulse | over_count )
		count<=0;
	else if (output_valid)
		count<=count+1;
	assign over_count = (count==NMAX) & (output_valid) | all_invalid;
	assign all_invalid =  fnsh_cond &(count==0);
	always @ (posedge clk) 
	if ( (reset=='b0) | finish )
		Threshold <= 0 - `THRESHOLD_BASE;
	else if (all_invalid)
		Threshold = Threshold - 1;
	else if ( over_count )
		Threshold = Threshold + `THRESHOLD_STEP;
	IS_LESS thresholdLess (0,Threshold,1,Threshold_greater_0);

	// update column
	always @ (posedge clk) 
	if ( reset=='b0 ) begin
		for (i=1;i<NMAX;i=i+1)	pre_valid[i] <= 0;
		pre_valid[0] <= 1;
		pre_metric[0] <= 0;
		pre_path_state[0] <= 0;
		for (i=0;i<2*NMAX;i=i+1) path_used[i] <= 0;
		path_id[0] <= 0;
	end else if ( finish_pulse ) begin
		for (i=0;i<`ALL_STATE;i=i+1) begin
			path_id[i] <= new_path_id[i];
			pre_state_valid[i]<=state_valid[i];
		end

		for (i=0;i<NMAX;i=i+1) begin
			pre_valid[i] <= path_valid[i];
			pre_metric[i] <= metric[i];
			pre_path_state[i] <= path_state[i];
		end
		for (i=0;i<2*NMAX;i=i+1) path_used[i] <= 0;
	end else if ( over_count ) begin
		for (i=0;i<2*NMAX;i=i+1) path_used[i] <= 0;

	end else if (working) begin
		if (m0_valid) path_used[pre_add] <= 1;
		if (m1_valid) path_used[{p1_add,pre_add[0]}] <= 1;
	end


/* ----------------- Functions and Tasks --------------- */
	
	
	// given current u and p
	// decide which bm should be used for ACS
	function [BIT_WIDTH-1:0] bm_choice;
		input u,p;

		begin case ({u,p})
			'b00:	bm_choice=bm0;
			'b01:	bm_choice=bm1;
			'b10:	bm_choice=bm2;
			'b11:	bm_choice=bm3;
		endcase
		end
	endfunction

endmodule


/*
	ACS: select the survivor from the merging two paths
	input:
		path0: u=0
		path1: u=1
	output:
		survivor=0 means path0 wins, otherwise path1
	metric_i: metric of current node
		valid_i: the validity of metric
		mdiff: the metric difference of the two paths, always positive
		md_valid: the validity of mdiff
*/
module ACS_BLOCK (old_metric0, old_metric1, valid0, valid1, p0, p1,
	surviv, metric_i, mdiff_i, valid_i, md_valid_i);
parameter BIT_WIDTH=`NOISE_BITWIDTH;
	input [BIT_WIDTH-1:0] old_metric0,old_metric1;
	input valid0, valid1;
	input [BIT_WIDTH-1:0] p0, p1;
	output surviv;
	output [BIT_WIDTH-1:0] metric_i, mdiff_i;
	output valid_i, md_valid_i;
	//output [BIT_WIDTH-1:0] probea,probeb;
	
	reg [BIT_WIDTH-1:0] loc_diff;
	reg [BIT_WIDTH-1:0] new_metric0, new_metric1;
	reg valid_i, md_valid_i;
	reg [BIT_WIDTH-1:0] metric_i, mdiff_i;
	reg surviv;
	
	always begin
	//probea=old_metric0;probeb=old_metric1;
		new_metric0 = TCAdder(p0,old_metric0);
		new_metric1 = TCAdder(p1,old_metric1);
		loc_diff = new_metric0 - new_metric1;
		
		case ({valid0,valid1})
		'b00: begin valid_i<=0; md_valid_i<=0; end
		'b01: begin
				metric_i <= new_metric1;
				valid_i<=1;
				md_valid_i <=0;
				surviv<=1;
		end
		'b10: begin
			metric_i <= new_metric0;
			valid_i<=1;
			md_valid_i <=0;
			surviv <= 0;
		end
		'b11: 
			if ( loc_diff[BIT_WIDTH-1] ) begin  //p0<p1
				surviv<=1; valid_i<=1;
				metric_i <= new_metric1;
				mdiff_i <= ~loc_diff +1; // make it positive
				md_valid_i <=1;
			end else begin				// p0>p1
				surviv<=0; valid_i<=1;
				metric_i <= new_metric0;
				mdiff_i <= loc_diff;
				md_valid_i <=1;
			end
		endcase
	end
	
	

/* 	No overflow Two's Complement Adder
	if the result is too small to represent by the given bitwidth, the smallest value will be returned
	The same thing for too big numbers
*/
	function [BIT_WIDTH-1:0] TCAdder;
		input [BIT_WIDTH-1:0] A;
		input [BIT_WIDTH-1:0] B;

		reg [BIT_WIDTH-1:0] tcsum;
		integer TCi;

	begin
//		wire [BIT_WIDTH-1:0] temp_s;
		tcsum = A + B;

		if ( A[BIT_WIDTH-1] ^ B[BIT_WIDTH-1] ) begin  // + and -
			TCAdder = tcsum;
		end else 
			if ( A[BIT_WIDTH-1] )	begin  // - and -
				if ( tcsum[BIT_WIDTH-1]) 
					TCAdder=tcsum;
				else begin
					for (TCi=0;TCi<BIT_WIDTH-1;TCi=TCi+1)
						TCAdder[TCi]=0;
					TCAdder[BIT_WIDTH-1]=1;
				end
			end else // + and +
				if ( tcsum[BIT_WIDTH-1] ) begin
					for (TCi=0;TCi<BIT_WIDTH-1;TCi=TCi+1)
						TCAdder[TCi] = 1;
					TCAdder[BIT_WIDTH-1]=0;
				end	else
					TCAdder = tcsum;
	end
	endfunction

endmodule



// ABSTRACT:  2-Function Comparator
//           When is_less = 1   A < B
//                is_less = 0   A >= B
//           When TC  = 0   Unsigned numbers
//           When TC  = 1   Two's - complement numbers
module IS_LESS (A,B,TC, less);
	parameter BIT_WIDTH=`NOISE_BITWIDTH, sign = BIT_WIDTH - 1;
    input [BIT_WIDTH-1 : 0]  A, B;
    input TC; //Flag of Signed
	output less;
	
    reg less;
	reg a_is_0, b_is_1, result ;
    integer i;
 
	always begin
        if ( TC === 1'b0 ) begin  // unsigned numbers
          result = 0;
          for (i = 0; i <= sign; i = i + 1) begin
              a_is_0 = A[i] === 1'b0;
              b_is_1 = B[i] === 1'b1;
              result = (a_is_0 & b_is_1) |
                        (a_is_0 & result) |
                        (b_is_1 & result);
          end // loop
        end else begin  // signed numbers
          if ( A[sign] !== B[sign] ) begin
              result = A[sign] === 1'b1;
          end else begin
              result = 0;
              for (i = 0; i <= sign-1; i = i + 1) begin
                  a_is_0 = A[i] === 1'b0;
                  b_is_1 = B[i] === 1'b1;
                  result = (a_is_0 & b_is_1) |
                            (a_is_0 & result) |
                            (b_is_1 & result);
              end // loop
          end // if
        end // if
        less = result;
    end
endmodule // 


/* given the current state and u
	return the previous state */
module  PRESTATE (state,u_in, pre_state);
input [`STATE_NUM-1:0] state;
input u_in;
output [`STATE_NUM-1:0] pre_state;
reg	[`STATE_NUM-1:0] pre_state;

	// based on (7,5) code and trellis of proposal Fig. 6.5
	always if ( `STATE_NUM==2 )  // (5,7)
			case ({state,u_in})
                0,3     : pre_state=0;
                4,7     : pre_state=1;
                2,1     : pre_state=2;
                6,5     : pre_state=3;
			endcase
		else if (`STATE_NUM==3) //(15,13)
			case ({state,u_in})
                0,3     : pre_state=0;
                6,5     : pre_state=1;
                8,11    : pre_state=2;
                14,13   : pre_state=3;
                2,1     : pre_state=4;
                4,7     : pre_state=5;
                10,9    : pre_state=6;
                12,15   : pre_state=7;
			endcase
		else if (`STATE_NUM==4) //(31,27)
			case ({state,u_in})
				// run davis:comm/src/rsccoder.cc for the following data
                0,3     : pre_state=0;
                6,5     : pre_state=1;
                8,11    : pre_state=2;
                14,13   : pre_state=3;
                16,19   : pre_state=4;
                22,21   : pre_state=5;
                24,27   : pre_state=6;
                30,29   : pre_state=7;
                2,1     : pre_state=8;
                4,7     : pre_state=9;
                10,9    : pre_state=10;
                12,15   : pre_state=11;
                18,17   : pre_state=12;
                20,23   : pre_state=13;
                26,25   : pre_state=14;
                28,31   : pre_state=15;
			endcase
		else if (`STATE_NUM==5) //(65,57)
			case ({state,u_in})
                0,3     : pre_state=0;
                6,5     : pre_state=1;
                8,11    : pre_state=2;
                14,13   : pre_state=3;
                18,17   : pre_state=4;
                20,23   : pre_state=5;
                26,25   : pre_state=6;
                28,31   : pre_state=7;
                32,35   : pre_state=8;
                38,37   : pre_state=9;
                40,43   : pre_state=10;
                46,45   : pre_state=11;
                50,49   : pre_state=12;
                52,55   : pre_state=13;
                58,57   : pre_state=14;
                60,63   : pre_state=15;
                2,1     : pre_state=16;
                4,7     : pre_state=17;
                10,9    : pre_state=18;
                12,15   : pre_state=19;
                16,19   : pre_state=20;
                22,21   : pre_state=21;
                24,27   : pre_state=22;
                30,29   : pre_state=23;
                34,33   : pre_state=24;
                36,39   : pre_state=25;
                42,41   : pre_state=26;
                44,47   : pre_state=27;
                48,51   : pre_state=28;
                54,53   : pre_state=29;
                56,59   : pre_state=30;
                62,61   : pre_state=31;
			endcase
endmodule
