module erasure_generator(
						clk,
						reset,
						erasure_flag_0,
						erasure_flag_1,
						erasure_flag_2,
						sigma_value,
						sigma_square,norm_sigma_square,
						cutoff_threshold_0,
						cutoff_threshold_1,
						cutoff_threshold_2,
						exact_smallest,
						normalized_signal,
						modified_actual_distance,
						channel_char,
						threshold_0,
						threshold_1,
						threshold_2,
						new_channel_char,
						recieved_codeword,
						rdaddress,q,q_fade,rdaddress_fade,rden,
						signal_count,
						send_data//,quotient
						);
parameter width = 10;
parameter num_inputs = 8;
parameter	A_width = 15;
parameter	B_width = 9;
parameter erasure_threshold_value_0 = -9'd94;//T = 0.28
parameter erasure_threshold_value_1 = -9'd173;//T = 0.15
parameter erasure_threshold_value_2 = -9'd75;// T = 0.32

input clk,reset;
input send_data;
input [4:0] sigma_value;

output new_channel_char;
output reg rden;
output reg erasure_flag_0,erasure_flag_1,erasure_flag_2;
output [A_width+B_width-1:0] modified_actual_distance;
output [A_width+B_width-1:0] cutoff_threshold_0,cutoff_threshold_1;
output [A_width+B_width-1:0] cutoff_threshold_2;
output reg [width:0] rdaddress;
output reg [width-1:0] exact_smallest;
output reg [B_width-1:0] threshold_0,threshold_1,threshold_2;
output reg [7:0] rdaddress_fade;
output reg [0:7] recieved_codeword;
output [3:0] signal_count;

output wire [A_width-1:0] normalized_signal;
output wire [A_width-1:0]norm_sigma_square;
reg [A_width-1:0] quotient; 
output wire [width-1:0]sigma_square;
output wire [width-1:0]q,q_fade;
wire [width-1:0]absolute_value;

//wire [14:0] channel_char;

/*Approx Data is representaed in signed magnitude. MSB is the sign bit*/

reg second_best_negated_signal;//used as a selector
reg new_channel_char;//erasure_flag,
reg [A_width+B_width-1:0] modified_actual_dist;
reg [A_width+B_width-1:0] cutoff_threshold_reg;
reg [A_width-1:0]norm_variance;
reg [A_width-1:0]quotient_out;
reg [width:0] addr;
reg [width-1:0] exact_signals[0:7];
reg [width-1:0] sorted_exact_signals[0:7];
reg [7:0] best_approx_signal,fading_value;
reg [3:0] signal_count;
reg [width-1:0] minimum_value;
reg [3:0] index;
reg [7:0] addr1;
reg [width-1:0] variance;
reg [width-1:0] unreliable_signal,exact_recvd_signal;
reg [4:0] prev_sigma_value;
output reg [A_width-1:0]channel_char; 

integer approx_distance,norm_exact_signal,actual_distance;

integer i,j,k,m;
   



//signals for the Dpram storing the 10-bit quantized channel output 
//Dpram size = 8 x 255 x 10 bits
input_buffer		buffer(
							.wraddress		(wraddress),//address not used  ;
							.wren			(wren),//write enable not used
							.data			(data),//input data not used
							.rden			(rden),
							.rdaddress		(rdaddress),//[10:0]
							.clock			(clk),
							.q				(q)//;[9:0]  
							);
							
//signals for the Dpram storing the 10-bit quantized channel fading gain 
//Dpram size = 255 x 10 bits							
fading				fade(
						.wraddress		(wraddress),//address not used  ;
						.wren			(wren),//write enable not used
						.data			(data),//input data not used
						.rden			(rden),
						.rdaddress		(rdaddress_fade),//[10:0]
						.clock			(clk),
						.q				(q_fade)//;[9:0]q_fade  
							);

							
signed_multiplier3	s_mult3	(
							.dataa			(normalized_signal),
							.datab			(approx_distance),
							.result			(modified_actual_dist),
							.clock			(clk)
							);

unsigned_multiplier calc_variance(
							.dataa			(sigma_value),//standard deviation of gaussian noise
							.datab			(sigma_value),
							.result			(sigma_square)//variance of gaussian noise
							);

unsigned_divider	uns_div(
							.numer		(norm_variance),
							.denom		(fading_value),
							.quotient	(quotient),
							.clock		(clk)
							);

mult_by_32			scaled_1(
							.dataa		(unreliable_signal),
							.result		(normalized_signal)
							);

mult_by_32_2			scaled_2(
							.dataa		(variance),
							.result		(norm_sigma_square)
							);

absolute_values		compute_abs(
							.data		(exact_recvd_signal),
							.result		(absolute_value)
							);
							
signed_multiplier	s_mult1	(
							.dataa			(channel_char),//variance-divide-by-fading gain
							.datab			(threshold_0),//pre-determined erasure threshold values
							.result			(cutoff_threshold_0),//product
							.clock			(clk)
							);
						
signed_multiplier2		s_mult2	(
								.dataa			(channel_char),//variance-divide-by-fading gain
								.datab			(threshold_1),//pre-determined erasure threshold values
								.result			(cutoff_threshold_1),//
								.clock			(clk)
								);

signed_multiplier4		s_mult4	(
								.dataa			(channel_char),//variance-divide-by-fading gain
								.datab			(threshold_2),//pre-determined erasure threshold values
								.result			(cutoff_threshold_2),//
								.clock			(clk)
								);
							
/*Erasure generator samples 8 10-bit quantized signals and a 10-bit fading gain for the 8 signals, at a time
  from the input buffers*/
/*recieved signals are quantized with 0.01 precision*/
/* floating point threshold values represented as fixed point values*/
/*Erasure_threshold_value = ln((1/(1-threshold)-1)*/
/*The valid value of threshold is between 0 and 1, however the optimum threshold values, T are 
based on the simulations. See the thesis document for T values*/
always @(posedge clk)
begin
if(reset==1'b1)
	begin
	rden=1'b0;
	signal_count=4'd0;
	new_channel_char=1'b0;
	best_approx_signal=8'd0;
	addr1 = 8'd0;
	addr = 10'd0;
	end
else begin
	if(send_data==1'b0)
		begin
			rden=1'b1;
			if(signal_count <= 4'd10)
				begin
					fading_value <= q_fade;
					if (signal_count <= 4'd7)//get the 8 sampled data from the Dpram
						begin
					 		rdaddress <= addr;
					 		addr <= addr+1;
						end	
					if(signal_count == 4'd2)//get the fading gain of the 8 sampled signals
						begin
							new_channel_char=1'b0;
							minimum_value = {width{1'b1}};
							rdaddress_fade = addr1;
							addr1 = addr1+1;
						end
					/*finds the smallest signal in magnitude out of the 8 sampled signals*/
					/*This is considered the most unreliable siggnal*/
					if(signal_count >= 4'd3)
						begin
							sorted_exact_signals[signal_count-3] = absolute_value;
							if(absolute_value < minimum_value)
								begin
									minimum_value = absolute_value;
									index = signal_count-3;
								end
						end						
					if(rdaddress == 2)//compute the variance of the noise
						begin
							if(sigma_value!=prev_sigma_value)
								begin
									prev_sigma_value<=sigma_value;
									variance <= sigma_square;
								end
						end
					if(rdaddress == 4)
							norm_variance <=norm_sigma_square;
					/*Perform hard decision-estimation to find recieved symbol (byte) estimation*/		
					/*The codeword byte estimation determined using the sign bit*/
					if(signal_count >= 4'd2 && signal_count < 4'd10)
						begin
							exact_recvd_signal = q;
							exact_signals[signal_count-2]=q;
							if(q[9]==1'b1)
								best_approx_signal[signal_count-2]=1'b1;
							else if (q[9]==1'b0)
								best_approx_signal[signal_count-2]=1'b0;
						end
				signal_count<=signal_count+4'd1;
			end//best_approx_signal is the most likely byte (MLB)sent to the decoder
		else if(signal_count > 4'd10)//9
			begin
			recieved_codeword = best_approx_signal;//estimated codeword byte
			new_channel_char = 1'b1;
			signal_count = 4'd0;
			end
	end
	else if(send_data==1'b1)
		begin
			rden=1'b0;// stop sampling channel data from the DPRAM
			new_channel_char = 1'b0;
		end
	end
end
  
always @(posedge clk)
begin
	if(reset==1'b1)
		begin
			erasure_flag_0=1'b0;
			erasure_flag_1=1'b0;
			erasure_flag_2=1'b0;
		end
else begin
	if(new_channel_char==1'b1)
		begin
			channel_char <= quotient;
			threshold_0 <= erasure_threshold_value_0;
			threshold_1 <= erasure_threshold_value_1;
			threshold_2 <= erasure_threshold_value_2;
			
			exact_smallest = minimum_value;
			unreliable_signal = exact_signals[index];
			second_best_negated_signal= best_approx_signal[index];
			//second_best_negated_signal is the estimation of the unreliable signal (smallest value) of the 8 recvd
			if(second_best_negated_signal==1'b0)//2nd MLS - MLS
				approx_distance = -9'd200;//represent (-1)-(+1)= -2 is quantized as -200 using 0.01 precision
			else if(second_best_negated_signal==1'b1)
				approx_distance = 9'd200;//represent (1)-(-1)= 2 is quantized as 200 using 0.01 precision
			if(rdaddress >= 10)//results of the erasures flag begin here due to pipelining
				begin
					if({~modified_actual_dist[23], modified_actual_dist[22:0]} >= {~cutoff_threshold_0[23],cutoff_threshold_0[22:0]})erasure_flag_0=1'b1;
						else erasure_flag_0=1'b0;//signed comparator
					if({~modified_actual_dist[23], modified_actual_dist[22:0]} >= {~cutoff_threshold_1[23],cutoff_threshold_1[22:0]})erasure_flag_1=1'b1;
						else erasure_flag_1=1'b0;//signed comparator
					if({~modified_actual_dist[23], modified_actual_dist[22:0]} >= {~cutoff_threshold_2[23],cutoff_threshold_2[22:0]})erasure_flag_2=1'b1;
						else erasure_flag_2=1'b0;//signed comparator
				end			
		end
	end
end

//assign new_channel_char = new_channel_char;
//assign normalized_signal = normalized_signal;
assign modified_actual_distance = modified_actual_dist;
//assign signal_count = signal_count[3:0];

endmodule