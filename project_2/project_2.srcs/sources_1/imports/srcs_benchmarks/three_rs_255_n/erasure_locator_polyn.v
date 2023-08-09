/*Erasure polynomial Generation*/
module erasure_locator_polyn(
							clock,
							reset,
							start_erasure_polyn_compute,
							erase_position,
							send_erasure_positions_for_loc,
							erasure_loc_polyn,
							no_of_parity,
							no_of_erasure_coefs,
							erasure_polyn_compute_done,
							number_of_erasures,
							erasure_ready,
							erasure_coef_ready,
							send_erasure_polyn,
							erase_coef_addr,
							erase_pos_done,
							);
							
parameter width = 5;
parameter number_of_coefs = 16;
							
input clock,reset,start_erasure_polyn_compute,erasure_ready,send_erasure_polyn;
input erase_pos_done;
input [7:0] erase_position;
input [width-1:0]number_of_erasures,no_of_parity;

output erasure_polyn_compute_done;
output reg send_erasure_positions_for_loc,erasure_coef_ready;
output [7:0] erasure_loc_polyn;
output [width-1:0] no_of_erasure_coefs;
output reg [width-1:0] erase_coef_addr;

reg erasure_polyn_compute_done_reg;
reg [7:0] erasure_location_polyn[0:number_of_coefs-1];
reg [7:0] temp_polyn[0:number_of_coefs];
reg [7:0] prev_erasure_location_polyn[0:number_of_coefs];
reg [7:0] current_erasure_location_polyn[0:number_of_coefs];
reg [7:0] temp_reg;
reg [width-1:0] erasure_reg;
reg [width-1:0]erasure_coef_addr;
reg [width-1:0]no_of_erasures;

integer i,j;

`include "shared_multiply.h"

always @(posedge clock)
begin
if(reset)
	begin
	current_erasure_location_polyn[0]=8'd1;
	end
end	

always @(posedge clock)
begin
if(reset==1'b1)
begin
send_erasure_positions_for_loc=1'b0;
erasure_polyn_compute_done_reg=1'b0;
end
else begin			
if (start_erasure_polyn_compute==1'b1)//sending for the erasure positions from erasure-position calculator
	begin
	send_erasure_positions_for_loc = 1'b1;
	if(no_of_erasures >= number_of_erasures && erase_pos_done == 1'b1)
		begin
		erasure_reg=number_of_erasures;
		erasure_polyn_compute_done_reg=1'b1;//keep trck of no of erasure coefs
		send_erasure_positions_for_loc = 1'b0;
		end
	else begin
		erasure_polyn_compute_done_reg=1'b0;
		no_of_erasures=no_of_erasures+1;
		end				
	end
end
end

/******************** Computing erasure polynomial*******/

always @(posedge clock)
begin
	if(erasure_ready==1'b1)
		begin
		for(i=1;i<number_of_coefs;i=i+1)
			begin
			j = i - 1;
			current_erasure_location_polyn[i] = erasure_location_polyn[i];
		    gf_multiplier(erase_position,current_erasure_location_polyn[j],temp_polyn[i]);
			erasure_location_polyn[i]= temp_polyn[i]^prev_erasure_location_polyn[i];
			prev_erasure_location_polyn[i]= erasure_location_polyn[i];
			end
		end
end

/****Sending out the coefficients of erasure locator polynomial--> lambda(x)*****/
always @(posedge clock)
begin
//if(reset==1'b0)
//begin
erasure_coef_ready=1'b0;
if(send_erasure_polyn==1'b1)
	begin
	erasure_coef_ready=1'b0;
	erasure_location_polyn[0]=8'd1;
	erase_coef_addr = erasure_coef_addr;
	temp_reg = erasure_location_polyn[erase_coef_addr];
	erasure_coef_addr = erasure_coef_addr + 1;//8'd1;
	erasure_coef_ready=1'b1;
	end
else if(send_erasure_polyn==1'b0)erasure_coef_ready=1'b0;
end	
//end

assign no_of_erasure_coefs = erasure_reg;
assign erasure_loc_polyn = temp_reg;
assign erasure_polyn_compute_done = erasure_polyn_compute_done_reg;
endmodule

