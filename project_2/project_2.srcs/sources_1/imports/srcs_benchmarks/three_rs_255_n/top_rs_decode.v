module top_rs_decode(
									reset,
									ext_clk,
									k_value,						//number of message bytes							
									no_of_parity,					//number of parity bytes	
									new_data,
									send_data,						
										

//signals for the Dpram storing the 10-bit quantized channel data and the fading gain
//read by erasure generator
									rdaddress_in,
									q_in, 							//10-bit sampled signal
									rdaddress_fade,
									q_fade, 						//10-bit fading gain
									
//erasure generator signals
									sigma_value,					//standard deviation of gaussian noise
									sigma_square,					//variance of gaussian noise
									norm_sigma_square, 				//scaled variance
									fade_value,						//channel fading gain
									channel_char,					//scaled variance divide-by-fading gain
									threshold_0,
									threshold_1,
									threshold_2,					//pre-determined erasure threshold value
									cutoff_threshold_0,
									cutoff_threshold_1,
									cutoff_threshold_2,				
									cutoff_threshold_ready,
									new_channel_char,				// triggers sampled data to be sorted according to magnitude
									exact_smallest,					//most-unreliable-sampled signal
									normalized_signal,				//most-unreliable-sampled signal scaled
									modified_actual_distance,
									recieved_codeword,				//estimation of recieved codeword
									erasure_flag_0,
									erasure_flag_1,
									erasure_flag_2,
//signals for the Dpram storing the estimated recieved codeword & erasure flags 
//written by erassure generator, read by decoder	
									wren_decoder_in_buffer,
									write_addr,
									cw_data,
									decoder_rd_addr,
									recvd_codeword,
									rd_enable,

									erasure,
									recvd_erasure_flag_0,
									recvd_erasure_flag_1,
									recvd_erasure_flag_2,
//signals for the GF(256) lookup table													
									decode_strobe,
//FIFO signals
									rdaddress,
									q,
									wren,

//Signals for erasure position calculation											
									erase_position_0,
									erase_position_1,
									erase_position_2,
									number_of_erasures_0,
									number_of_erasures_1,
									number_of_erasures_2,
									erasures_absent_0,
									erasures_absent_1,
									erasures_absent_2,

//Signals for syndrome computation																				
									syndrome,
									unmodified_syndr_polyn_0,		//syndrome sent sent to MEA if there are no erasures
									unmodified_syndr_polyn_1,
									unmodified_syndr_polyn_2,
//Signals for erasure polynomial generation																				
									start_erasure_polyn_compute,
									erasure_polyn_0,
									no_of_erasure_coefs_0,
									erasure_coef_ready_0,
									erasure_polyn_1,
									no_of_erasure_coefs_1,
									erasure_coef_ready_1,
									erasure_polyn_2,
									no_of_erasure_coefs_2,
									erasure_coef_ready_2,

//Signals for modified syndrome polynomial generation																													
									load_non_zero_syndrome_done,
									start_modified_syndrome_polyn_compute,
									modified_syndr_polyn_0,
									syndr_coef_ready_0,
									modified_syndr_polyn_1,
									syndr_coef_ready_1,
									modified_syndr_polyn_2,
									syndr_coef_ready_2,
//Signals for modified Euclidean Algorithm	(MEA)
																																			
									send_erasure_polyn_0,
									send_syndr_polyn_0,
									send_unmodified_syndr_polyn_0,
									R_degree_0,
									Q_degree_0,
									L_degree_0,
									state_case_0,
									MEA_compute_done_0,
									locator_polyn_0,
									magnitue_polyn_0,				
									errata_loc_coefs_0, 				//errors-&-erasures locator polynomial
									errata_magnitude_coefs_0,			//errors-&-erasures magnitude polynomial
									locator_degree_0,					//number of errors identified
									send_erasure_polyn_1,
									send_syndr_polyn_1,
									send_unmodified_syndr_polyn_1,
									R_degree_1,
									Q_degree_1,
									L_degree_1,
									state_case_1,
									MEA_compute_done_1,
									locator_polyn_1,
									magnitue_polyn_1,				
									errata_loc_coefs_1, 				//errors-&-erasures locator polynomial
									errata_magnitude_coefs_1,			//errors-&-erasures magnitude polynomial
									locator_degree_1,					//number of errors identified
									send_erasure_polyn_2,
									send_syndr_polyn_2,
									send_unmodified_syndr_polyn_2,
									R_degree_2,
									Q_degree_2,
									L_degree_2,
									state_case_2,
									MEA_compute_done_2,
									locator_polyn_2,
									magnitue_polyn_2,				
									errata_loc_coefs_2, 				//errors-&-erasures locator polynomial
									errata_magnitude_coefs_2,			//errors-&-erasures magnitude polynomial
									locator_degree_2,
//Signals for Chien Serach algorithm, Forney algorithm and Error correction block																																													
									cycle,
									error_location_0,
									derivative_error_location,
									error_magnitude,
									corrected_cword_ready,
									corrected_cw,					//corrected codeword
									error_location_1,
									corrected_error_count,			//number of errors corrected
									signal_count,quotient,
									error_location_2
									
									//Q_x,R,L,U,m_counter,test_Q,test_R,test_L,test_U,
									//rdaddress_Q,rdaddress_R,rdaddress_L,rdaddress_U //test		
									
					);
		
/////////////////////////////////////////////
//PARAMETERIZED Triple DECODER RS
//Implements (255,k) RS Decoder
//Define k as desired, valid values are:
//217, 221, 225, 233, 237, 239
//Insure only ONE K is defined for correct operation
/////////////////////////////////////////////

//`define K217
//`define K221
//`define K225
//`define K233
//`define K237
`define K239

`ifdef K217
	parameter width = 6;
	parameter dif = 38;
	parameter erasure_threshold_value_0 = -9'd220;// T = 0.1
	parameter erasure_threshold_value_1 = -9'd115;// T = 0.24
	parameter erasure_threshold_value_2 = -9'd66;// T = 0.34
`endif

`ifdef K221
	parameter width = 6;
	parameter dif = 34;
	parameter erasure_threshold_value_0 = -9'd244;//T = 0.08
	parameter erasure_threshold_value_1 = -9'd132;//T = 0.21
	parameter erasure_threshold_value_2 = -9'd85;// T = 0.3
`endif

`ifdef K225
	parameter width = 6;
	parameter dif = 30;
	parameter erasure_threshold_value_0 = -9'd244;//T = 0.08
	parameter erasure_threshold_value_1 = -9'd127;//T = 0.22
	parameter erasure_threshold_value_2 = -9'd85;// T = 0.3
`endif

`ifdef K233
	parameter width = 5;
	parameter dif = 22;
	parameter erasure_threshold_value_0 = -9'd244;//T = 0.08
	parameter erasure_threshold_value_1 = -9'd152;//T = 0.18
	parameter erasure_threshold_value_2 = -9'd105;//T = 0.36
`endif

`ifdef K237
	parameter width = 5;
	parameter dif = 18;
	parameter erasure_threshold_value_0 = -9'd244;//T = 0.08
	parameter erasure_threshold_value_1 = -9'd127;//T = 0.22
	parameter erasure_threshold_value_2 = -9'd62;//T = 0.35
`endif

`ifdef K239
	parameter width = 5;
	parameter dif = 16;
	parameter erasure_threshold_value_0 = -9'd94;//T = 0.28
	parameter erasure_threshold_value_1 = -9'd173;//T = 0.15
	parameter erasure_threshold_value_2 = -9'd75;// T = 0.32
`endif

input reset,ext_clk;
input[7:0]k_value;//number of bytes in the message
input [4:0] sigma_value;//standard deviation of the noise

//erasure generator outputs
output reg wren_decoder_in_buffer,rd_enable,wren,erasure;
output new_channel_char;//start_sort;
output [9:0] fade_value;
output [0:7]recieved_codeword;
output [9:0] exact_smallest;
output [14:0] normalized_signal;
output [23:0] modified_actual_distance;
output [8:0] threshold_0,threshold_1,threshold_2;
output [10:0] rdaddress_in;
output reg [7:0] write_addr,cw_data,decoder_rd_addr;
output [7:0] rdaddress_fade;
output [3:0] signal_count;
//decoder outputs
output reg send_data,new_data;
output decode_strobe;
output [7:0]erase_position_0,erase_position_1,erase_position_2;
output [7:0]erasure_polyn_0,modified_syndr_polyn_0;
output [7:0]erasure_polyn_1,modified_syndr_polyn_1;
output [7:0]erasure_polyn_2,modified_syndr_polyn_2;
output reg start_erasure_polyn_compute,start_modified_syndrome_polyn_compute;
output [width-1:0] no_of_erasure_coefs_0,no_of_erasure_coefs_1,no_of_erasure_coefs_2;
output reg [width-1:0] no_of_parity;
output [width-1:0]number_of_erasures_0,number_of_erasures_1,number_of_erasures_2;
output [7:0] syndrome;
output [7:0] unmodified_syndr_polyn_0,unmodified_syndr_polyn_1,unmodified_syndr_polyn_2;
output [7:0] locator_polyn_0,magnitue_polyn_0,locator_polyn_1,magnitue_polyn_1;
output [7:0] locator_polyn_2,magnitue_polyn_2;
output load_non_zero_syndrome_done;
output send_erasure_polyn_0,send_erasure_polyn_1,send_erasure_polyn_2;
output syndr_coef_ready_0,send_syndr_polyn_0,erasure_coef_ready_0;
output syndr_coef_ready_1,send_syndr_polyn_1,erasure_coef_ready_1;
output syndr_coef_ready_2,send_syndr_polyn_2,erasure_coef_ready_2;
output reg erasures_absent_0,erasures_absent_1,erasures_absent_2;
output send_unmodified_syndr_polyn_0,send_unmodified_syndr_polyn_1;
output send_unmodified_syndr_polyn_2;
output MEA_compute_done_0,MEA_compute_done_1,MEA_compute_done_2;
output [2:0]state_case_0,state_case_1,state_case_2;
output [width-1:0]R_degree_0,Q_degree_0,L_degree_0;
output [width-1:0]R_degree_1,Q_degree_1,L_degree_1;
output [width-1:0]R_degree_2,Q_degree_2,L_degree_2;
output [7:0]corrected_error_count;
output [8:0]cycle;
output [7:0] q,corrected_cw;
output corrected_cword_ready;

//output [7:0] Q_x,R,L,U,test_Q,test_R,test_L,test_U;
//output [5:0] m_counter,rdaddress_Q,rdaddress_R,rdaddress_L,rdaddress_U;

reg[7:0] temp_k_value;
reg[width-1:0]temp_no_of_parity;
reg [7:0]count,write_flag_addr;

integer cw_addr;

//erasure generator outputs
output wire cutoff_threshold_ready;
output wire [14:0] channel_char;
output wire [14:0] quotient;
output wire[9:0]sigma_square;
output wire [14:0]norm_sigma_square;
output wire[23:0]cutoff_threshold_0;
output wire[23:0]cutoff_threshold_1;
output wire[23:0]cutoff_threshold_2;
output wire [9:0] q_in,q_fade;
output wire [7:0] recvd_codeword;
output wire erasure_flag_0,recvd_erasure_flag_0;
output wire erasure_flag_1,recvd_erasure_flag_1;
output wire erasure_flag_2,recvd_erasure_flag_2;

//GF(256) lookup table
wire read_alpha_inverse,gf_table_ready;
wire [7:0] err_loc_derivativative,alpha_inverse;//,chien_root;

//FIFO wires
output wire [7:0] rdaddress;
wire rden_delay_buffer;

//wire [7:0]erase_position;
wire [7:0]erase_position_0,erase_position_1;
wire erasure_polyn_compute_done_0,modified_syndrome_polyn_compute_done_0;
wire erasure_polyn_compute_done_1,modified_syndrome_polyn_compute_done_1;
wire erasure_polyn_compute_done_2,modified_syndrome_polyn_compute_done_2;

wire send_syndromes,codeword_end_flag,erasure_ready;
wire [width-1:0]syndr_coef_addr;
wire syndrome_ready;
wire unmodified_syndrome_ready_0,unmodified_syndrome_ready_1,unmodified_syndrome_ready_2;

output wire [7:0] error_location_0,derivative_error_location,error_magnitude;
output wire [7:0] errata_loc_coefs_0,errata_magnitude_coefs_0;
output wire [width-1:0]locator_degree_0;	
wire [width-1:0] erase_coef_addr_0,errata_loc_addr_0,errata_magnitude_addr_0;
wire [width-1:0] modified_syndr_coef_addr_0,unmodified_syndr_coef_addr_0;
wire deactivate_chien_serach_0;//codeword is error-free

output wire [7:0] error_location_1;
output wire [7:0] errata_loc_coefs_1,errata_magnitude_coefs_1;
output wire [width-1:0]locator_degree_1;	
wire [width-1:0] erase_coef_addr_1,errata_loc_addr_1,errata_magnitude_addr_1;
wire [width-1:0] modified_syndr_coef_addr_1,unmodified_syndr_coef_addr_1;
wire deactivate_chien_serach_1;//codeword is error-free

output wire [7:0] error_location_2;
output wire [7:0] errata_loc_coefs_2,errata_magnitude_coefs_2;
output wire [width-1:0]locator_degree_2;	
wire [width-1:0] erase_coef_addr_2,errata_loc_addr_2,errata_magnitude_addr_2;
wire [width-1:0] modified_syndr_coef_addr_2,unmodified_syndr_coef_addr_2;
wire deactivate_chien_serach_2;//codeword is error-free


defparam inst0.erasure_threshold_value_0=erasure_threshold_value_0;
defparam inst0.erasure_threshold_value_1=erasure_threshold_value_1;
defparam inst0.erasure_threshold_value_2=erasure_threshold_value_2;
erasure_generator	inst0(
						.clk						(ext_clk),
						.reset						(reset),
						.rden						(rden),				
						.rdaddress					(rdaddress_in),
						.q							(q_in),				
						.rdaddress_fade				(rdaddress_fade),
						.q_fade						(q_fade),
						.new_channel_char			(new_channel_char),
						.sigma_value				(sigma_value),
						.sigma_square				(sigma_square),
						.norm_sigma_square			(norm_sigma_square),
						.cutoff_threshold_0			(cutoff_threshold_0),
						.cutoff_threshold_1			(cutoff_threshold_1),
						.cutoff_threshold_2			(cutoff_threshold_2),						
						.exact_smallest				(exact_smallest),
						.normalized_signal			(normalized_signal),
						.modified_actual_distance	(modified_actual_distance),
						.channel_char				(channel_char),	
						.threshold_0				(threshold_0),
						.threshold_1				(threshold_1),
						.threshold_2				(threshold_2),						
						.recieved_codeword			(recieved_codeword),
						.erasure_flag_0				(erasure_flag_0),
						.erasure_flag_1				(erasure_flag_1),
						.erasure_flag_2				(erasure_flag_2),						
						.signal_count				(signal_count),
						.send_data					(send_data)
					//	.quotient					(quotient)
						);
//buffer used by the erasure generator to store the estimated recieved codeword.
//buffer is read by syndrome computation block in the reed-solomon decoder						
decoder_input_buffer 	decoder_input(
									.data				(cw_data),//gets data from erasure generator
									.wren				(wren_decoder_in_buffer),
									.wraddress			(write_addr),
									.rden				(rd_enable),
									.rdaddress			(decoder_rd_addr),
									.clock				(ext_clk),
									.q					(recvd_codeword)
									);
//buffer used by the erasure generator to store the erasures flag.
//buffer is read by erasure_position calculation block in the reed-solomon decoder	
decoder_erasure_flags 	decoder_erasures_0(
									.data				(erasure_flag_0),
									.wren				(wren_decoder_in_buffer),
									.wraddress			(write_flag_addr),
									.rden				(rd_enable),
									.rdaddress			(decoder_rd_addr),
									.clock				(ext_clk),
									.q					(recvd_erasure_flag_0)
									);
								
decoder_erasure_flags_1 	decoder_erasures_1(
									.data				(erasure_flag_1),//gets erasure flags from erasure generator
									.wren				(wren_decoder_in_buffer),
									.wraddress			(write_flag_addr),
									.rden				(rd_enable),
									.rdaddress			(decoder_rd_addr),
									.clock				(ext_clk),
									.q					(recvd_erasure_flag_1)
									);	
									
decoder_erasure_flags_2 	decoder_erasures_2(
									.data				(erasure_flag_2),//gets erasure flags from erasure generator
									.wren				(wren_decoder_in_buffer),
									.wraddress			(write_flag_addr),
									.rden				(rd_enable),
									.rdaddress			(decoder_rd_addr),
									.clock				(ext_clk),
									.q					(recvd_erasure_flag_2)
									);									
								
//signals for the GF(256) lookup table
GF_256_elements 			inst1(
								.clock					(ext_clk),								
								.reset					(reset),
								.read_alpha_inverse		(read_alpha_inverse),
								.gf_table_ready			(gf_table_ready),
								.err_loc_derivativative	(err_loc_derivativative),
								.alpha_inverse			(alpha_inverse),
								.decode_strobe			(decode_strobe)
						 		 );

//signals for reed solomon delay buffer (FIFO)
delay_buffer			inst2(
								.wraddress				(decoder_rd_addr),//rd
								.wren					(wren),
								.data					(recvd_codeword),//transfer data from in_decoder buffer
								.clock					(ext_clk),
								.rdaddress				(rdaddress),
								.rden					(rden_delay_buffer),
								.q						(q)
							);

defparam inst3.width=width;
defparam inst3.max_number_of_erasures=dif;
erasure_position_calc	inst3(
							.clock								(ext_clk),
							.reset								(reset),
							.number_of_erasures_0				(number_of_erasures_0),
							.number_of_erasures_1				(number_of_erasures_1),
							.number_of_erasures_2				(number_of_erasures_2),
							.erase_position_0					(erase_position_0[7:0]),
							.erase_position_1					(erase_position_1[7:0]),
							.erase_position_2					(erase_position_2[7:0]),
							.erasure_flag_0						(recvd_erasure_flag_0),
							.erasure_flag_1						(recvd_erasure_flag_1),
							.erasure_flag_2						(recvd_erasure_flag_2),
							.new_data							(new_data),
							.erase_pos_done_0					(erase_pos_done_0),
							.erase_pos_done_1					(erase_pos_done_1),
							.erase_pos_done_2					(erase_pos_done_2),
							.erasure_ready_0					(erasure_ready_0),
							.erasure_ready_1					(erasure_ready_1),
							.erasure_ready_2					(erasure_ready_2),
							.send_erasure_positions_for_loc_0	(send_erasure_positions_for_loc_0),
							.send_erasure_positions_for_loc_1	(send_erasure_positions_for_loc_1),
							.send_erasure_positions_for_loc_2	(send_erasure_positions_for_loc_2),
							.send_erasure_positions_for_synd_0	(send_erasure_positions_for_synd_0),
							.send_erasure_positions_for_synd_1	(send_erasure_positions_for_synd_1),
							.send_erasure_positions_for_synd_2	(send_erasure_positions_for_synd_2),
							.decoder_rd_addr					(decoder_rd_addr)
							);

///////////
////////////
`ifdef K239
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes				inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif
`ifdef K237
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes237			inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif

`ifdef K233
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes233			inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif
`ifdef K225
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes225			inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif

`ifdef K221
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes221			inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif	

`ifdef K217
defparam inst4.width=width;
defparam inst4.number_of_coefs=dif;
syndromes217			inst4 (
								.recd							(recvd_codeword),
								.reset							(reset),
								.clock							(ext_clk),
								.syndrome						(syndrome),
								.unmodified_syndr_polyn_0		(unmodified_syndr_polyn_0),
								.unmodified_syndr_polyn_1		(unmodified_syndr_polyn_1),
								.unmodified_syndr_polyn_2		(unmodified_syndr_polyn_2),
								.new_data						(new_data),
								.codeword_end_flag				(codeword_end_flag),
								.send_syndromes					(send_syndromes),
								.send_unmodified_syndr_polyn_0	(send_unmodified_syndr_polyn_0),
								.send_unmodified_syndr_polyn_1	(send_unmodified_syndr_polyn_1),
								.send_unmodified_syndr_polyn_2	(send_unmodified_syndr_polyn_2),
								.syndr_coef_addr				(syndr_coef_addr),
								.unmodified_syndr_coef_addr_0	(unmodified_syndr_coef_addr_0),
								.unmodified_syndr_coef_addr_1	(unmodified_syndr_coef_addr_1),
								.unmodified_syndr_coef_addr_2	(unmodified_syndr_coef_addr_2),
								.unmodified_syndrome_ready_0	(unmodified_syndrome_ready_0),
								.unmodified_syndrome_ready_1	(unmodified_syndrome_ready_1),
								.unmodified_syndrome_ready_2	(unmodified_syndrome_ready_2),
								.syndrome_ready					(syndrome_ready),
								.decoder_rd_addr				(decoder_rd_addr)
								);
`endif						

defparam inst5.width=width;
defparam inst5.number_of_coefs=dif;																			
modified_syndrome_polyn		inst5(
								.clock									(ext_clk),
								.reset									(reset),
								.start_modified_syndrome_polyn_compute	(start_modified_syndrome_polyn_compute),
								.send_syndromes							(send_syndromes),
								.erase_position_0						(erase_position_0),
								.erase_position_1						(erase_position_1),
								.erase_position_2						(erase_position_2),
								.send_erasure_positions_for_synd_0		(send_erasure_positions_for_synd_0),
								.send_erasure_positions_for_synd_1		(send_erasure_positions_for_synd_1),
								.send_erasure_positions_for_synd_2		(send_erasure_positions_for_synd_2),
								.syndrome								(syndrome),
								.no_of_parity							(no_of_parity),
								.modified_syndrome_polyn_compute_done_0	(modified_syndr_polyn_compute_done_0),
								.modified_syndrome_polyn_compute_done_1	(modified_syndr_polyn_compute_done_1),
								.modified_syndrome_polyn_compute_done_2	(modified_syndr_polyn_compute_done_2),
								.erasure_ready_0						(erasure_ready_0),
								.erasure_ready_1						(erasure_ready_1),
								.erasure_ready_2						(erasure_ready_2),
								.modified_syndr_polyn_0					(modified_syndr_polyn_0),
								.modified_syndr_polyn_1					(modified_syndr_polyn_1),
								.modified_syndr_polyn_2					(modified_syndr_polyn_2),
								.load_non_zero_syndrome_done			(load_non_zero_syndrome_done),
								.codeword_end_flag						(codeword_end_flag),
								.send_syndr_polyn_0						(send_syndr_polyn_0),
								.send_syndr_polyn_1						(send_syndr_polyn_1),
								.send_syndr_polyn_2						(send_syndr_polyn_2),
								.syndr_coef_ready_0						(syndr_coef_ready_0),
								.syndr_coef_ready_1						(syndr_coef_ready_1),
								.syndr_coef_ready_2						(syndr_coef_ready_2),
								.syndr_coef_addr						(syndr_coef_addr),
								.erase_pos_done_0						(erase_pos_done_0),
								.erase_pos_done_1						(erase_pos_done_1),
								.erase_pos_done_2						(erase_pos_done_2),
								.syndrome_ready							(syndrome_ready),
								.number_of_erasures_0					(number_of_erasures_0),
								.number_of_erasures_1					(number_of_erasures_1),
								.number_of_erasures_2					(number_of_erasures_2),
								.modified_syndr_coef_addr_0				(modified_syndr_coef_addr_0),
								.modified_syndr_coef_addr_1				(modified_syndr_coef_addr_1),								
								.modified_syndr_coef_addr_2				(modified_syndr_coef_addr_2),								
								.error_free_codeword					(deactivate_chien_serach)
								);
								
defparam inst6a.width=width;
defparam inst6a.number_of_coefs=dif;
erasure_locator_polyn_0	inst6a	(
								.clock							(ext_clk),
								.reset							(reset),
								.start_erasure_polyn_compute	(start_erasure_polyn_compute),
								.erase_position					(erase_position_0),
								.send_erasure_positions_for_loc	(send_erasure_positions_for_loc_0),
								.erasure_loc_polyn				(erasure_polyn_0),
								.no_of_parity					(no_of_parity),
								.erasure_polyn_compute_done		(erasure_polyn_compute_done_0),
								.erase_pos_done					(erase_pos_done_0),
								.erasure_ready					(erasure_ready_0),
								.erase_coef_addr				(erase_coef_addr_0),
								.no_of_erasure_coefs			(no_of_erasure_coefs_0),
								.number_of_erasures				(number_of_erasures_0),
								.send_erasure_polyn				(send_erasure_polyn_0),
								.erasure_coef_ready				(erasure_coef_ready_0)
								);

defparam inst6b.width=width;
defparam inst6b.number_of_coefs=dif;
erasure_locator_polyn	inst6b	(
								.clock							(ext_clk),
								.reset							(reset),
								.start_erasure_polyn_compute	(start_erasure_polyn_compute),
								.erase_position					(erase_position_1),
								.send_erasure_positions_for_loc	(send_erasure_positions_for_loc_1),
								.erasure_loc_polyn				(erasure_polyn_1),
								.no_of_parity					(no_of_parity),
								.erasure_polyn_compute_done		(erasure_polyn_compute_done_1),
								.erase_pos_done					(erase_pos_done_1),
								.erasure_ready					(erasure_ready_1),
								.erase_coef_addr				(erase_coef_addr_1),
								.no_of_erasure_coefs			(no_of_erasure_coefs_1),
								.number_of_erasures				(number_of_erasures_1),
								.send_erasure_polyn				(send_erasure_polyn_1),
								.erasure_coef_ready				(erasure_coef_ready_1)
								);

defparam inst6c.width=width;
defparam inst6c.number_of_coefs=dif;
erasure_locator_polyn	inst6c	(
								.clock							(ext_clk),
								.reset							(reset),
								.start_erasure_polyn_compute	(start_erasure_polyn_compute),
								.erase_position					(erase_position_2),
								.send_erasure_positions_for_loc	(send_erasure_positions_for_loc_2),
								.erasure_loc_polyn				(erasure_polyn_2),
								.no_of_parity					(no_of_parity),
								.erasure_polyn_compute_done		(erasure_polyn_compute_done_2),
								.erase_pos_done					(erase_pos_done_2),
								.erasure_ready					(erasure_ready_2),
								.erase_coef_addr				(erase_coef_addr_2),
								.no_of_erasure_coefs			(no_of_erasure_coefs_2),
								.number_of_erasures				(number_of_erasures_2),
								.send_erasure_polyn				(send_erasure_polyn_2),
								.erasure_coef_ready				(erasure_coef_ready_2)
								);
defparam inst7a.width=width;
defparam inst7a.number_of_coefs=dif;					
modified_euclid_alg_0		inst7a(
							.clock									(ext_clk),
							.reset									(reset),
							.no_of_parity							(no_of_parity),
							.no_of_erasure_coefs					(no_of_erasure_coefs_0),
							.erasure_polyn_compute_done				(erasure_polyn_compute_done_0),
							.modified_syndr_polyn_compute_done		(modified_syndr_polyn_compute_done_0),
							.locator_polyn							(locator_polyn_0),
							.magnitue_polyn							(magnitue_polyn_0),
							.erasure_polyn							(erasure_polyn_0),
							.modified_syndr_polyn					(modified_syndr_polyn_0),
							.unmodified_syndr_polyn					(unmodified_syndr_polyn_0),
							.erase_coef_addr						(erase_coef_addr_0),
							.modified_syndr_coef_addr				(modified_syndr_coef_addr_0),
							.unmodified_syndr_coef_addr				(unmodified_syndr_coef_addr_0),
							.erasure_coef_ready						(erasure_coef_ready_0),
							.send_erasure_polyn						(send_erasure_polyn_0),
							.send_syndr_polyn						(send_syndr_polyn_0),
							.send_unmodified_syndr_polyn			(send_unmodified_syndr_polyn_0),
							.syndr_coef_ready						(syndr_coef_ready_0),
							.unmodified_syndrome_ready				(unmodified_syndrome_ready_0),
							.MEA_compute_done						(MEA_compute_done_0),
							.reg_initialization_complete			(reg_initialization_complete_0),
							.MEA_iteration							(MEA_iteration_0),
							.reg_init								(reg_init_0),
							.state_case								(state_case_0),
							.R_degree								(R_degree_0),
							.Q_degree								(Q_degree_0),
							.locator_degree							(locator_degree_0),
							.send_loc_errata_coefs					(send_loc_errata_coefs_0),
							.send_magnitude_errata_coefs			(send_magnitude_errata_coefs_0),
							.errata_loc_coefs						(errata_loc_coefs_0),
							.errata_magnitude_coefs					(errata_magnitude_coefs_0),
							.errata_loc_coef_ready					(errata_loc_coef_ready_0),
							.errata_magnitude_coef_ready			(errata_magnitude_coef_ready_0),
							.errata_loc_addr						(errata_loc_addr_0),
							.errata_magnitude_addr					(errata_magnitude_addr_0),
							.erasures_absent						(erasures_absent_0),
							.L_degree								(L_degree_0),
							.chien_regs_initialized					(chien_regs_initialized_0)
							);								

defparam inst7b.width=width;
defparam inst7b.number_of_coefs=dif;
modified_euclid_alg_1		inst7b(
							.clock									(ext_clk),
							.reset									(reset),
							.no_of_parity							(no_of_parity),
							.no_of_erasure_coefs					(no_of_erasure_coefs_1),
							.erasure_polyn_compute_done				(erasure_polyn_compute_done_1),
							.modified_syndr_polyn_compute_done		(modified_syndr_polyn_compute_done_1),
							.locator_polyn							(locator_polyn_1),
							.magnitue_polyn							(magnitue_polyn_1),
							.erasure_polyn							(erasure_polyn_1),
							.modified_syndr_polyn					(modified_syndr_polyn_1),
							.unmodified_syndr_polyn					(unmodified_syndr_polyn_1),
							.erase_coef_addr						(erase_coef_addr_1),
							.modified_syndr_coef_addr				(modified_syndr_coef_addr_1),
							.unmodified_syndr_coef_addr				(unmodified_syndr_coef_addr_1),
							.erasure_coef_ready						(erasure_coef_ready_1),
							.send_erasure_polyn						(send_erasure_polyn_1),
							.send_syndr_polyn						(send_syndr_polyn_1),
							.send_unmodified_syndr_polyn			(send_unmodified_syndr_polyn_1),
							.syndr_coef_ready						(syndr_coef_ready_1),
							.unmodified_syndrome_ready				(unmodified_syndrome_ready_1),
							.MEA_compute_done						(MEA_compute_done_1),
							.reg_initialization_complete			(reg_initialization_complete_1),
							.MEA_iteration							(MEA_iteration_1),
							.reg_init								(reg_init_1),
							.state_case								(state_case_1),
							.R_degree								(R_degree_1),
							.Q_degree								(Q_degree_1),
							.locator_degree							(locator_degree_1),
							.send_loc_errata_coefs					(send_loc_errata_coefs_1),
							.send_magnitude_errata_coefs			(send_magnitude_errata_coefs_1),
							.errata_loc_coefs						(errata_loc_coefs_1),
							.errata_magnitude_coefs					(errata_magnitude_coefs_1),
							.errata_loc_coef_ready					(errata_loc_coef_ready_1),
							.errata_magnitude_coef_ready			(errata_magnitude_coef_ready_1),
							.errata_loc_addr						(errata_loc_addr_1),
							.errata_magnitude_addr					(errata_magnitude_addr_1),
							.erasures_absent						(erasures_absent_1_1),
							.L_degree								(L_degree_1),
							.chien_regs_initialized					(chien_regs_initialized_1)
							);								

defparam inst7c.width=width;
defparam inst7c.number_of_coefs=dif;
modified_euclid_alg_2		inst7c(
							.clock									(ext_clk),
							.reset									(reset),
							.no_of_parity							(no_of_parity),
							.no_of_erasure_coefs					(no_of_erasure_coefs_2),
							.erasure_polyn_compute_done				(erasure_polyn_compute_done_2),
							.modified_syndr_polyn_compute_done		(modified_syndr_polyn_compute_done_2),
							.locator_polyn							(locator_polyn_2),
							.magnitue_polyn							(magnitue_polyn_2),
							.erasure_polyn							(erasure_polyn_2),
							.modified_syndr_polyn					(modified_syndr_polyn_2),
							.unmodified_syndr_polyn					(unmodified_syndr_polyn_2),
							.erase_coef_addr						(erase_coef_addr_2),
							.modified_syndr_coef_addr				(modified_syndr_coef_addr_2),
							.unmodified_syndr_coef_addr				(unmodified_syndr_coef_addr_2),
							.erasure_coef_ready						(erasure_coef_ready_2),
							.send_erasure_polyn						(send_erasure_polyn_2),
							.send_syndr_polyn						(send_syndr_polyn_2),
							.send_unmodified_syndr_polyn			(send_unmodified_syndr_polyn_2),
							.syndr_coef_ready						(syndr_coef_ready_2),
							.unmodified_syndrome_ready				(unmodified_syndrome_ready_2),
							.MEA_compute_done						(MEA_compute_done_2),
							.reg_initialization_complete			(reg_initialization_complete_2),
							.MEA_iteration							(MEA_iteration_2),
							.reg_init								(reg_init_2),
							.state_case								(state_case_2),
							.R_degree								(R_degree_2),
							.Q_degree								(Q_degree_2),
							.locator_degree							(locator_degree_2),
							.send_loc_errata_coefs					(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs			(send_magnitude_errata_coefs_2),
							.errata_loc_coefs						(errata_loc_coefs_2),
							.errata_magnitude_coefs					(errata_magnitude_coefs_2),
							.errata_loc_coef_ready					(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready			(errata_magnitude_coef_ready_2),
							.errata_loc_addr						(errata_loc_addr_2),
							.errata_magnitude_addr					(errata_magnitude_addr_2),
							.erasures_absent						(erasures_absent_1_2),
							.L_degree								(L_degree_2),
							.chien_regs_initialized					(chien_regs_initialized_2)
							);								

//////////////
//////////////
`ifdef K239
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif

`ifdef K237
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg237	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif
`ifdef K233
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg233	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif
`ifdef K225
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg225	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif
`ifdef K221
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg221	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif
`ifdef K217
defparam inst8.width=width;
defparam inst8.number_of_coefs=dif;
defparam inst8.number_of_even_roots=dif/2;
chien_search_alg217	 inst8(
							.clock							(ext_clk),
							.reset							(reset),
							.no_of_parity					(no_of_parity),
							.MEA_compute_done_0				(MEA_compute_done_0),
							.MEA_compute_done_1				(MEA_compute_done_1),
							.MEA_compute_done_2				(MEA_compute_done_2),
							.locator_degree_0				(locator_degree_0),
							.locator_degree_1				(locator_degree_1),
							.locator_degree_2				(locator_degree_2),
							.send_loc_errata_coefs_0		(send_loc_errata_coefs_0),
							.send_loc_errata_coefs_1		(send_loc_errata_coefs_1),
							.send_loc_errata_coefs_2		(send_loc_errata_coefs_2),
							.send_magnitude_errata_coefs_0	(send_magnitude_errata_coefs_0),
							.send_magnitude_errata_coefs_1	(send_magnitude_errata_coefs_1),
							.send_magnitude_errata_coefs_2	(send_magnitude_errata_coefs_2),
							.errata_loc_coefs_0				(errata_loc_coefs_0),
							.errata_loc_coefs_1				(errata_loc_coefs_1),
							.errata_loc_coefs_2				(errata_loc_coefs_2),
							.errata_magnitude_coefs_0		(errata_magnitude_coefs_0),
							.errata_magnitude_coefs_1		(errata_magnitude_coefs_1),
							.errata_magnitude_coefs_2		(errata_magnitude_coefs_2),
							.errata_loc_coef_ready_0		(errata_loc_coef_ready_0),
							.errata_loc_coef_ready_1		(errata_loc_coef_ready_1),
							.errata_loc_coef_ready_2		(errata_loc_coef_ready_2),
							.errata_magnitude_coef_ready_0	(errata_magnitude_coef_ready_0),
							.errata_magnitude_coef_ready_1	(errata_magnitude_coef_ready_1),
							.errata_magnitude_coef_ready_2	(errata_magnitude_coef_ready_2),
							.error_location_0 				(error_location_0),
							.error_location_1 				(error_location_1),
							.error_location_2 				(error_location_2),
							.derivative_error_location 		(derivative_error_location),
							.error_magnitude				(error_magnitude),
							.errata_loc_addr_0				(errata_loc_addr_0),
							.errata_loc_addr_1				(errata_loc_addr_1),
							.errata_loc_addr_2				(errata_loc_addr_2),
							.errata_magnitude_addr_0		(errata_magnitude_addr_0),
							.errata_magnitude_addr_1		(errata_magnitude_addr_1),
							.errata_magnitude_addr_2		(errata_magnitude_addr_2),
							.corrected_error_count			(corrected_error_count),
							.corrected_cword_ready			(corrected_cword_ready),
							.cycle							(cycle),
							.read_alpha_inverse				(read_alpha_inverse),
							.err_loc_derivativative			(err_loc_derivativative),
							.alpha_inverse					(alpha_inverse),
							.gf_table_ready					(gf_table_ready),
							.rdaddress						(rdaddress),
							.rden_delay_buffer				(rden_delay_buffer),
							.q								(q),
							.corrected_cw					(corrected_cw),
							.deactivate_chien_serach		(deactivate_chien_serach),
							.chien_regs_initialized_0		(chien_regs_initialized_0),
							.chien_regs_initialized_1		(chien_regs_initialized_1),
							.chien_regs_initialized_2		(chien_regs_initialized_2)
							);
`endif
always @(posedge ext_clk)
begin
	if((reset==1'b0)&&(decode_strobe==1'b1))
	begin
	temp_k_value=k_value;//k is the number of data bytes
	no_of_parity=8'd255 - temp_k_value;
	end
	
end

always @(posedge ext_clk)
begin
if(reset==1'b1)
	begin
 	wren_decoder_in_buffer = 1'b0;
 	new_data=1'b0;
	rd_enable = 1'b0;
	send_data = 1'b0;
	wren = 1'b0;
	cw_addr = 0;
	end
else if(reset==1'b0)
begin
	if(new_channel_char==1'b1 && send_data == 1'b0)//erasure writes recived cw into the the  decoder input DPRAM
		begin
			wren_decoder_in_buffer <= 1'b1;
			write_addr <= rdaddress_fade;
			cw_data <= recieved_codeword;
			if(rdaddress_fade >= 1)
				write_flag_addr <= rdaddress_fade -1;
		end

	if(write_addr==8'd255 && cw_addr <= 256)//erasure-generator completed writting data
	begin
		rd_enable = 1'b1;	//decoder rd data from its input DPRAM
		wren = 1'b1;		//decoder write data in the delay buffer
		send_data = 1'b1;	//activates syndrome generation and erasure location extraction to begin; and halts erasure generator from sending data to decoder buffer
		if (cw_addr <= 255)
			decoder_rd_addr = cw_addr;
		cw_addr = cw_addr + 1;
	end
	if(cw_addr>9'd256)//decoder stops reading it's input DPRAM
		begin
		rd_enable = 1'b0;
		wren = 1'b0;
		end
	if((send_data==1'b1)&&(codeword_end_flag==1'b0))
		begin
		new_data=1'b1;
		end
end
end

always @(posedge ext_clk)
begin
if(reset==1'b1)
begin
	start_erasure_polyn_compute<=1'b0;
	start_modified_syndrome_polyn_compute<=1'b0;
	erasures_absent_0<=1'b0;
	erasures_absent_1<=1'b0;
	erasures_absent_2<=1'b0;
 end
else
	begin
		if(load_non_zero_syndrome_done==1'b1) 
			begin
				if(number_of_erasures_0!=6'd0 ||number_of_erasures_1!=6'd0 ||number_of_erasures_2!=6'd0)
					begin
						start_erasure_polyn_compute<=1'b1;
						start_modified_syndrome_polyn_compute<=1'b1;
						if(number_of_erasures_0==6'd0)erasures_absent_0<=1'b1;
						if(number_of_erasures_1==6'd0)erasures_absent_1<=1'b1;
						if(number_of_erasures_2==6'd0)erasures_absent_2<=1'b1;
					end
				else if(number_of_erasures_0==6'd0 && number_of_erasures_1==6'd0 && number_of_erasures_2==6'd0)
					begin
						start_erasure_polyn_compute<=1'b0;
						start_modified_syndrome_polyn_compute<=1'b0;
						erasures_absent_0<=1'b1;
						erasures_absent_1<=1'b1;
						erasures_absent_2<=1'b1;
					end
			end
		
	end
end
endmodule

