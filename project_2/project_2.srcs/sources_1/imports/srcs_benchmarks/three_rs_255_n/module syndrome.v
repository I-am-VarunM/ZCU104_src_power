module syndrome (
				data,
				reset,
				start_syndrome,
				root,
				address,
				stop_syndrome,
				clock,
				syndrome,
				syndrome_done,
				send_roots,
				roots_ready,
				send_roots_done,
				send_data,
				new_data,
				no_of_parity_plus_one
				);


output syndrome_done,send_roots;
output [7:0] syndrome;

input [7:0] data, root,address,no_of_parity_plus_one;
input  clock,send_data, reset, new_data,start_syndrome,roots_ready,stop_syndrome,send_roots_done;

//parameter cycles = 255;
//wire[7:0] recd;
reg[7:0] synd_alpha [1:32]; //[1:32];
reg[7:0] data_out [1:32];//[1:32];
reg[7:0] temp_data [1:32];//[1:32];
reg[7:0]syndrom [1:32];//[1:32];
reg[7:0]num_of_syndromes;
reg[7:0]alpha;

`include "shared_multiply.h"
integer count,i,j,k;

//always @(reset)
//begin
//for(j=1;j<33;j=j+1)	
//	temp_data[j]<=8'b0;
//end

always @(posedge clock)
begin
	if(start_syndrome==1'b1)
	begin
		send_roots=1'b1;
		if(roots_ready==1'b1)
			begin
			synd_alpha[address[7:0]]<=root;
			send_roots<=1'b0;
 			//address[7:0]<=temp_address[7:0];
			end
	end
end

always @(posedge clock)
begin
	if(send_roots_done==1'b1)
		send_data<=1'b1;
end

always @(posedge clock)
begin
	//count = 0;
	if(new_data==1'b1)
	begin
	for(i=1;i<33;i=i+1)
		begin
			gf_multiplier(temp_data[i],synd_alpha[i],data_out[i]);
			temp_data[i]<=data_out[i]^data[7:0];
			syndrom[i]<=temp_data[i];
		end
	end
end
//assign 	syndrome = syndrom[num_of_syndromes];
always @(posedge clock)
begin
	if(stop_syndrome==1'b1)
	 begin
		if(count>=33)
		//if (num_of_syndromes==no_of_parity_plus_one)
		begin 
			syndrome_done<= 1'b1;
			count=0;
			//num_of_syndromes<=8'b0;
		end
		else
		begin
			count=count+1;
			//num_of_syndromes<=num_of_syndromes+8'd1;
			syndrome<=syndrome[count];
			//syndrome<= syndrom[num_of_syndromes];
		end
	end		
	else 
	count=0;
	//num_of_syndromes<=8'b0;	
end

endmodule