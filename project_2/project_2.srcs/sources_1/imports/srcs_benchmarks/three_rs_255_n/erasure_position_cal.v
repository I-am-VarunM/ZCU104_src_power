/*Erasure location extraction unit*/
module erasure_position_calc(
						erasure_flag_0,
						erasure_flag_1,
						erasure_flag_2,
						erase_position_0,
						erase_position_1,
						erase_position_2,
						new_data,
						reset,
						clock,
						erasure_ready_0,
						erasure_ready_1,
						erasure_ready_2,
						send_erasure_positions_for_loc_0,
						send_erasure_positions_for_loc_1,
						send_erasure_positions_for_loc_2,
						send_erasure_positions_for_synd_0,
						send_erasure_positions_for_synd_1,						
						send_erasure_positions_for_synd_2,						
						number_of_erasures_0,
						number_of_erasures_1,
						number_of_erasures_2,
						erase_pos_done_0,
						erase_pos_done_1,
						erase_pos_done_2,
						decoder_rd_addr
						);
						
parameter width = 5;
parameter max_number_of_erasures = 16;

input erasure_flag_0, erasure_flag_1,erasure_flag_2;
input clock,reset,new_data;
input send_erasure_positions_for_loc_0,send_erasure_positions_for_loc_1,send_erasure_positions_for_loc_2;
input send_erasure_positions_for_synd_0,send_erasure_positions_for_synd_1,send_erasure_positions_for_synd_2;
input [7:0]decoder_rd_addr;

output reg erasure_ready_0;
output reg erasure_ready_1;
output reg erasure_ready_2;
output reg erase_pos_done_0;
output reg erase_pos_done_1;
output reg erase_pos_done_2;
output [7:0] erase_position_0;
output [7:0] erase_position_1;
output [7:0] erase_position_2;
output [width-1:0] number_of_erasures_0;
output [width-1:0] number_of_erasures_1;
output [width-1:0] number_of_erasures_2;

reg [7:0] inverse_alpha_one;
reg [7:0] erase_position_reg_0,erase_position_reg_1,erase_position_reg_2;
reg [width-1:0] no_of_erasures_0,no_of_erasures_1,no_of_erasures_2;
reg [7:0] current_erasure,temp_current_erasure;
reg[7:0] erasures_0[0:max_number_of_erasures-1];
reg[7:0] erasures_1[0:max_number_of_erasures-1];
reg[7:0] erasures_2[0:max_number_of_erasures-1];
reg [width-1:0] erasure_addr_counter_0,erasure_addr_counter_1,erasure_addr_counter_2;

reg [7:0] count_0,count_1,count_2;
integer i,cw_byte_count;

`include "shared_multiply.h"


always @(posedge clock)
begin
if(reset==1'b1)
begin
	inverse_alpha_one [7:0]<= 8'b10001110;//this is alpha_to_254
	current_erasure <= 8'd1;
end	
else begin				
	if (new_data==1'b1 && cw_byte_count<255)
	begin
		gf_multiplier(inverse_alpha_one,current_erasure,temp_current_erasure);//determining erasure positions
		current_erasure<=temp_current_erasure;
		cw_byte_count= cw_byte_count+1;//counts the number of codeword bytes
	end
end
end
//end

always @(posedge clock)
begin
if(reset==1'b1)
begin
count_0 =0;
count_1 =0;
count_2 =0;
end
else if(reset==1'b0)
begin
	if(decoder_rd_addr >= 8'd1)
		begin
			if(erasure_flag_0==1'b1)
				begin
					erasures_0[count_0]<=current_erasure;
	 				count_0 <= count_0+1;
	 				no_of_erasures_0 <= count_0 + 1;//count the number of erasures from generator-0
				end
			if(erasure_flag_1==1'b1)
				begin
					erasures_1[count_1]<=current_erasure;
	 				count_1 <= count_1+1;
	 				no_of_erasures_1 <= count_1 + 1;//count the number of erasures from generator-1
				end
			if(erasure_flag_2==1'b1)
				begin
					erasures_2[count_2] <=current_erasure;
	 				count_2 <=count_2+1;
	 				no_of_erasures_2 <= count_2 + 1;//count the number of erasures from generator-2
				end
		end

end
end

/****Sending out the coefficients of erasure positions*****/
always @(posedge clock)
begin
if(reset==1'b0)
begin
	erasure_ready_0=1'b0;
	erasure_ready_1=1'b0;
	erasure_ready_2=1'b0;
	if(send_erasure_positions_for_loc_0==1'b1 && send_erasure_positions_for_synd_0==1'b1)
	begin
		erase_position_reg_0 = erasures_0[erasure_addr_counter_0];
		erasure_addr_counter_0 = erasure_addr_counter_0 + 1;
		if(erasure_addr_counter_0==no_of_erasures_0)erase_pos_done_0=1'b1;
		erasure_ready_0=1'b1;
	end
	else begin erasure_ready_0=1'b0; erase_pos_done_0=1'b0; end
	
	if(send_erasure_positions_for_loc_1==1'b1 && send_erasure_positions_for_synd_1==1'b1)
	begin
		erase_position_reg_1 = erasures_1[erasure_addr_counter_1];
		erasure_addr_counter_1 = erasure_addr_counter_1 + 1;
		if(erasure_addr_counter_1==no_of_erasures_1)erase_pos_done_1=1'b1;
		erasure_ready_1=1'b1;
	end
	else begin erasure_ready_1=1'b0; erase_pos_done_1=1'b0;end
	
	if(send_erasure_positions_for_loc_2==1'b1 && send_erasure_positions_for_synd_2==1'b1)
	begin
		erase_position_reg_2 = erasures_2[erasure_addr_counter_2];
		erasure_addr_counter_2 = erasure_addr_counter_2 + 1;
		if(erasure_addr_counter_2==no_of_erasures_2)erase_pos_done_2=1'b1;
		erasure_ready_2=1'b1;
	end
	else begin erasure_ready_2=1'b0; erase_pos_done_2=1'b0;end 
end
end

assign number_of_erasures_0 = no_of_erasures_0;
assign number_of_erasures_1 = no_of_erasures_1;
assign number_of_erasures_2 = no_of_erasures_2;
assign erase_position_0 [7:0]= erase_position_reg_0;
assign erase_position_1 [7:0]= erase_position_reg_1;
assign erase_position_2 [7:0]= erase_position_reg_2;
endmodule