/* define all the parameters here */

`define ALTERA

//codeword length, which is the interleaver length
`define CODE_SIZE 1024
`define CODE_ADD_WIDTH 10


//encoder state number
`define STATE_NUM 4
`define ALL_STATE 16
//`define G1 ('o5)
//`define G2 ('o7)
//Note*: change pre_state and pre_p in ASOVA.v if STATE_NUM changes
`define G1 ('o31)
`define G2 ('o27)


/**********************/
/* Channel Parameters */
/**********************/
// the bitwidth of channal input data, 2's complement format
`define NOISE_BITWIDTH 4
// the decimal point position of channel input data
// BIT_WIDTH=5, FIX_POINT=2 =>  xxx.xx
`define FIX_POINT 0

/**********************/
/* Decoder Parameters */
/**********************/
// MEMSIZE>TRACE_SIZE+UPDATE_SIZE
`define MEM_SIZE 64
`define MEM_ADDWIDTH 6
`define TRACE_SIZE 32
`define UPDATE_SIZE 16


`define N_MAX 4
// NMAX_WIDTH should always be log2(N_MAX)
`define NMAX_WIDTH 2


/*	Lc = 4/(sigma^2)
	used in BMU for branch matric generation 
*/
`define LC_VALUE (3'b011)

// the (max metric - THRESHOLD_BASE) will be the threshold for each level
`define THRESHOLD_BASE 3
// if survivor path outnumber Nmax, how much threshold increase
`define THRESHOLD_STEP 2



