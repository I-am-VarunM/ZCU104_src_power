/*Syndrome Expansion Unit*/
module modified_syndrome_polyn(
							clock,
							reset,
							start_modified_syndrome_polyn_compute,
							send_syndromes,
							erase_position_0,
							erase_position_1,
							erase_position_2,							
							send_erasure_positions_for_synd_0,
							send_erasure_positions_for_synd_1,
							send_erasure_positions_for_synd_2,
							syndrome,
							no_of_parity,
							modified_syndrome_polyn_compute_done_0,
							modified_syndrome_polyn_compute_done_1,
							modified_syndrome_polyn_compute_done_2,
							erasure_ready_0,
							erasure_ready_1,
							erasure_ready_2,
							codeword_end_flag,
							load_non_zero_syndrome_done,
							modified_syndr_polyn_0,
							modified_syndr_polyn_1,
							modified_syndr_polyn_2,
							send_syndr_polyn_0,
							send_syndr_polyn_1,
							send_syndr_polyn_2,
							syndr_coef_ready_0,
							syndr_coef_ready_1,
							syndr_coef_ready_2,
							syndrome_ready,
							syndr_coef_addr,
							number_of_erasures_0,
							number_of_erasures_1,
							number_of_erasures_2,
							modified_syndr_coef_addr_0,
							modified_syndr_coef_addr_1,
							modified_syndr_coef_addr_2,
							erase_pos_done_0,
							erase_pos_done_1,
							erase_pos_done_2,
							error_free_codeword
							);
parameter width = 5;
parameter number_of_coefs = 16;
							
input clock,reset,start_modified_syndrome_polyn_compute;
input erasure_ready_0,erasure_ready_1,erasure_ready_2;
input codeword_end_flag,syndrome_ready;
input send_syndr_polyn_0,send_syndr_polyn_1,send_syndr_polyn_2;
input erase_pos_done_0,erase_pos_done_1,erase_pos_done_2;
input [7:0] erase_position_0,erase_position_1,erase_position_2;
input [7:0] syndrome;
input [width-1:0] syndr_coef_addr;
input [width-1:0] number_of_erasures_0;
input [width-1:0] number_of_erasures_1;
input [width-1:0] number_of_erasures_2;
input [width-1:0] no_of_parity;

output load_non_zero_syndrome_done;
output reg error_free_codeword;
output modified_syndrome_polyn_compute_done_0,modified_syndrome_polyn_compute_done_1,modified_syndrome_polyn_compute_done_2;
output reg send_syndromes,send_erasure_positions_for_synd_0,send_erasure_positions_for_synd_1,send_erasure_positions_for_synd_2;
output reg syndr_coef_ready_0,syndr_coef_ready_1,syndr_coef_ready_2;
output reg [7:0] modified_syndr_polyn_0,modified_syndr_polyn_1,modified_syndr_polyn_2;
output reg [width-1:0] modified_syndr_coef_addr_0,modified_syndr_coef_addr_1,modified_syndr_coef_addr_2;

reg load_non_zero_syndrome_done;
reg modified_syndrome_polyn_compute_done_reg_0,modified_syndrome_polyn_compute_done_reg_1,modified_syndrome_polyn_compute_done_reg_2;
reg [7:0] syndrom_0[0:number_of_coefs];
reg [7:0] syndrom_1[0:number_of_coefs];
reg [7:0] syndrom_2[0:number_of_coefs];
reg [7:0] current_syndrome_0[1:number_of_coefs+1];
reg [7:0] current_syndrome_1[1:number_of_coefs+1];
reg [7:0] current_syndrome_2[1:number_of_coefs+1];
reg [7:0] temp_polyn;
reg [7:0] erasure_reg_0,prev_erasures_0;
reg [7:0] erasure_reg_1,prev_erasures_1;
reg [7:0] erasure_reg_2,prev_erasures_2;
reg [width-1:0] next_syndr_coef_addr,prev_syndr_coef_addr;
reg [width-1:0] mod_syndrome_addr_counter_0;
reg [width-1:0] mod_syndrome_addr_counter_1;
reg [width-1:0] mod_syndrome_addr_counter_2;

reg [width-1:0]no_of_erasures_0,no_of_erasures_1,no_of_erasures_2,non_zero_coef_count;


integer i,count,j,k,m,p,q;

`include "shared_multiply.h"

always @(posedge clock)
begin
if(reset==1'b1)
	begin
	current_syndrome_0[1]=8'd0;
	current_syndrome_1[1]=8'd0;
	current_syndrome_2[1]=8'd0;
	end
end	

always @(posedge clock)
begin
if(reset==1'b1)
begin
load_non_zero_syndrome_done=1'b0;
send_syndromes=1'b0;
error_free_codeword=1'b0;
end	
else//if(reset==1'b0)
begin	
	if (codeword_end_flag==1'b1 && syndr_coef_addr <= no_of_parity)//requesting for the syndromes
		begin
			send_syndromes=1'b1;
		end 
		else if(syndr_coef_addr > no_of_parity )
			begin 
				send_syndromes=1'b0;
				if(non_zero_coef_count != 0)
					load_non_zero_syndrome_done=1'b1;
				else if(non_zero_coef_count == 0)
					error_free_codeword=1'b1;
					
			 end
end
end

always @(posedge clock)
begin
if(reset==1'b1)
begin
send_erasure_positions_for_synd_0=1'b0;
send_erasure_positions_for_synd_1=1'b0;
send_erasure_positions_for_synd_2=1'b0;
modified_syndrome_polyn_compute_done_reg_0=1'b0;
modified_syndrome_polyn_compute_done_reg_1=1'b0;
modified_syndrome_polyn_compute_done_reg_2=1'b0;

end
else if(reset==1'b0)
begin	
	if (start_modified_syndrome_polyn_compute==1'b1)
		begin
			send_erasure_positions_for_synd_0=1'b1;
			send_erasure_positions_for_synd_1=1'b1;
			send_erasure_positions_for_synd_2=1'b1;
			
			if(no_of_erasures_0 > number_of_erasures_0)//requesting for erasure positions from erasure-position calculator
				begin
				modified_syndrome_polyn_compute_done_reg_0=1'b1;
			 	send_erasure_positions_for_synd_0=1'b0;
				end
			else
				begin
				modified_syndrome_polyn_compute_done_reg_0=1'b0;
				end 
			
			if(no_of_erasures_1 > number_of_erasures_1)//requesting for erasure positions from erasure-position calculator
				begin
				modified_syndrome_polyn_compute_done_reg_1=1'b1;
			 	send_erasure_positions_for_synd_1=1'b0;
				end
			else
				begin
				modified_syndrome_polyn_compute_done_reg_1=1'b0;
				end 
			
			if(no_of_erasures_2 > number_of_erasures_2)//requesting for erasure positions from erasure-position calculator
				begin
				modified_syndrome_polyn_compute_done_reg_2=1'b1;
			 	send_erasure_positions_for_synd_2=1'b0;
				end
			else
				begin
				modified_syndrome_polyn_compute_done_reg_2=1'b0;
				end 
		end	
end	
end

always @(posedge clock)
begin
	if(reset==1'b0)
		begin
			if(syndrome_ready==1'b1)
				begin
					next_syndr_coef_addr = syndr_coef_addr;
					if (prev_syndr_coef_addr != next_syndr_coef_addr)
						begin
							syndrom_0[syndr_coef_addr]=syndrome; //loading the syndromes
							syndrom_1[syndr_coef_addr]=syndrome;
							syndrom_2[syndr_coef_addr]=syndrome;
							if(syndrome != 8'd0)non_zero_coef_count = non_zero_coef_count +1; 
							prev_syndr_coef_addr = next_syndr_coef_addr;
						end
				end
			if(erasure_ready_0==1'b1)
				begin
					erasure_reg_0=erase_position_0;
					if (prev_erasures_0 != erasure_reg_0)
						begin
							no_of_erasures_0=no_of_erasures_0+6'd1;
							prev_erasures_0 = erasure_reg_0;
							for(i=1;i<=number_of_coefs;i=i+1)//ARRAY 0 IS NOT BEING USED 	
								begin
									j = i + 1;
									gf_multiplier(erasure_reg_0,syndrom_0[i],current_syndrome_0[j]);//modifying syndrome using erasures
									syndrom_0[i]<= syndrom_0[i]^current_syndrome_0[i];
								end
			  			end	
				end
				
			if(erasure_ready_1==1'b1)
				begin
					erasure_reg_1=erase_position_1;
					if (prev_erasures_1 != erasure_reg_1)
						begin
							no_of_erasures_1=no_of_erasures_1+6'd1;
							prev_erasures_1 = erasure_reg_1;
							for(k=1;k<=number_of_coefs;k=k+1)//ARRAY 0 IS NOT BEING USED 	
								begin
									m = k + 1;
									gf_multiplier(erasure_reg_1,syndrom_1[k],current_syndrome_1[m]);//modifying syndrome using erasures
									syndrom_1[k]<= syndrom_1[k]^current_syndrome_1[k];
								end
			  			end	
				end
			
			if(erasure_ready_2==1'b1)
				begin
					erasure_reg_2=erase_position_2;
					if (prev_erasures_2 != erasure_reg_2)
						begin
							no_of_erasures_2=no_of_erasures_2+6'd1;
							prev_erasures_2 = erasure_reg_2;
							for(p=1;p<=number_of_coefs;p=p+1)//ARRAY 0 IS NOT BEING USED 	
								begin
									q = p + 1;
									gf_multiplier(erasure_reg_2,syndrom_2[p],current_syndrome_2[q]);//modifying syndrome using erasures
									syndrom_2[p]<= syndrom_2[p]^current_syndrome_2[p];
								end
			  			end	
				end
		end
	else if(reset==1'b1)
		begin
			next_syndr_coef_addr = 8'd0;
			prev_syndr_coef_addr = 8'd0;
			prev_erasures_0 = 8'd1;
			prev_erasures_1 = 8'd1;
			prev_erasures_2 = 8'd1;
		end
end

/****Sending out the coefficients of modified syndrome polynomial--> T(x)*****/
always @(posedge clock)
begin
	if(reset==1'b0)
		begin
			syndr_coef_ready_0=1'b0;
			syndr_coef_ready_1=1'b0;
			syndr_coef_ready_2=1'b0;			
			if(send_syndr_polyn_0==1'b1)
				begin
					modified_syndr_coef_addr_0 = mod_syndrome_addr_counter_0;
					modified_syndr_polyn_0 = syndrom_0[modified_syndr_coef_addr_0+1];//syndrom[0] is empty
					mod_syndrome_addr_counter_0 = mod_syndrome_addr_counter_0 + 1;//8'd1;
					syndr_coef_ready_0=1'b1;
				end
			else if (send_syndr_polyn_0==1'b0)
				begin 
					syndr_coef_ready_0 = 1'b0;
				end
			
			if(send_syndr_polyn_1==1'b1)
				begin
					modified_syndr_coef_addr_1 = mod_syndrome_addr_counter_1;
					modified_syndr_polyn_1 = syndrom_1[modified_syndr_coef_addr_1+1];//syndrom[0] is empty
					mod_syndrome_addr_counter_1 = mod_syndrome_addr_counter_1 + 1;//8'd1;
					syndr_coef_ready_1=1'b1;
				end
			else if (send_syndr_polyn_1==1'b0)
				begin 
					syndr_coef_ready_1 = 1'b0;
				end
				
			if(send_syndr_polyn_2==1'b1)
				begin
					modified_syndr_coef_addr_2 = mod_syndrome_addr_counter_2;
					modified_syndr_polyn_2 = syndrom_2[modified_syndr_coef_addr_2+1];//syndrom[0] is empty
					mod_syndrome_addr_counter_2 = mod_syndrome_addr_counter_2 + 1;//8'd1;
					syndr_coef_ready_2=1'b1;
				end
			else if (send_syndr_polyn_2==1'b0)
				begin 
					syndr_coef_ready_2 = 1'b0;
				end
		end
	else 
		begin 
			mod_syndrome_addr_counter_0 = 0;
			mod_syndrome_addr_counter_1 = 0;
			mod_syndrome_addr_counter_2 = 0;
		end//8'd0;
end

//assign load_non_zero_syndrome_done=load_non_zero_syndrome_done;
assign modified_syndrome_polyn_compute_done_0=modified_syndrome_polyn_compute_done_reg_0;
assign modified_syndrome_polyn_compute_done_1=modified_syndrome_polyn_compute_done_reg_1;
assign modified_syndrome_polyn_compute_done_2=modified_syndrome_polyn_compute_done_reg_2;
endmodule
