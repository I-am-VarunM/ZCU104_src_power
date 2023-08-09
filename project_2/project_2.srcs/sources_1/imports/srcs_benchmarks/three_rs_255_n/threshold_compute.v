module threshold_compute(
						new_channel_char,
						fade_value,
						sigma_value,
						clock,
						reset,
						cutoff_threshold_ready,
						//cutoff_threshold,
						cutoff_threshold_0,
						cutoff_threshold_1,
						sigma_square,
						norm_sigma_square,
						channel_char, 
						//threshold
						threshold_0,
						threshold_1
						);

parameter	A_width = 15;
parameter	B_width = 9;

input new_channel_char,clock,reset;
input [9:0] fade_value;
input [4:0] sigma_value;

output[9:0]sigma_square;
output [14:0]norm_sigma_square;
reg [14:0]channel_char; 
//output [8:0] threshold;reg [8:0]threshold;
output [8:0] threshold_0;reg [8:0]threshold_0;
output [8:0] threshold_1;reg [8:0]threshold_1;

output cutoff_threshold_ready; reg cutoff_threshold_ready;

reg [8:0] threshold_regs[0:6];

//output	[A_width+B_width-1:0]	cutoff_threshold;
//reg	[A_width+B_width-1:0]	product;
output	[A_width+B_width-1:0]	cutoff_threshold_0;
output	[A_width+B_width-1:0]	cutoff_threshold_1;
reg	[A_width+B_width-1:0]	product_0;
reg	[A_width+B_width-1:0]	product_1;

unsigned_multiplier variance(
							.dataa			(sigma_value),//standard deviation of gaussian noise
							.datab			(sigma_value),
							.result			(sigma_square)//variance of gaussian noise
							);
							
signed_multiplier		s_mult1	(
								.dataa			(channel_char),//variance-divide-by-fading gain
								.datab			(threshold_0),//pre-determined erasure threshold values
								.result			(product_0)//
								);
						
signed_multiplier2		s_mult2	(
								.dataa			(channel_char),//variance-divide-by-fading gain
								.datab			(threshold_1),//pre-determined erasure threshold values
								.result			(product_1)//
								);


/* floating point threshold values represented as fixed point values*/
/*threshold_reg = ln((1/(1-threshold)-1)*/
/*threshold is varied between 0.2 and 0.4*/
/***cutoff-threshold = threshold_reg * channel_char***/
always @(posedge reset)
begin
threshold_regs[0] <=  -9'd85;//-9'd139;//0.20=>-1.39;
threshold_regs[1] <= -9'd173;//0.15=>-1.73;-9'd127;// 0.22=>-1.27;
//threshold_regs[2] <= -9'd105;//0.26=>-1.05;
//threshold_regs[3] <= -9'd85;//0.3=>-0.85;
//threshold_regs[4] <= -9'd62;//0.35=>-0.62;
//threshold_regs[5] <= -9'd53;//0.37=>-0.53
//threshold_regs[6] <= -9'd41;//0.4=>-0.41;
end

always @(posedge clock)
begin
if(reset==1'b1)cutoff_threshold_ready=1'b0;
else 
begin //assuming RS(255,239) IS FOR FOR SIGMA = 0.14; THRESHOLD SET AT 0.2 and 0.15
if(new_channel_char==1'b1)
	begin
		norm_sigma_square = sigma_square<<5;//*5'd32 variance is scaled
		channel_char = norm_sigma_square/fade_value;
		threshold_0=threshold_regs[0];
		threshold_1=threshold_regs[1];
		//if((sigma_value>=6'd10)&&(sigma_value<=6'd13))threshold=threshold_regs[0];
		//else if((sigma_value>=5'd14)&&(sigma_value<=6'd16))threshold=threshold_regs[1];
		//else if((sigma_value>=5'd17)&&(sigma_value<=6'd19))threshold=threshold_regs[0];//2
		//else if((sigma_value>=5'd20)&&(sigma_value<=6'd22))threshold=threshold_regs[3];
		//else if((sigma_value>=5'd23)&&(sigma_value<=6'd24))threshold=threshold_regs[4];
		//else if((sigma_value>=5'd25)&&(sigma_value<=6'd27))threshold=threshold_regs[5];
		//else if((sigma_value>=5'd28)&&(sigma_value<=6'd30))threshold=threshold_regs[6];
		
		cutoff_threshold_ready=1'b1;
		
	end
end
end

//assign cutoff_threshold = product;
assign cutoff_threshold_0 = product_0;
assign cutoff_threshold_1 = product_1;

endmodule