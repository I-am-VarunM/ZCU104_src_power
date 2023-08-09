module erasure_position(
						erase_flag,
						erase_position,
						new_data,
						reset,
						clock,
						alpha_254,
						erasure_loc_polyn,
						erasure_loc_polyn_1,
						erasure_addr,
						erasure_ready,init_erase_reg,
						send_erasure_positions,temp
						);
input erase_flag,reset,new_data;
input [7:0] alpha_254;
input init_erase_reg,clock,send_erasure_positions;
output [7:0] erase_position,erasure_loc_polyn,erasure_loc_polyn_1,erasure_addr,temp;
output erasure_ready;

reg [7:0] inverse_alpha_one,temp_reg,init_erasure;
reg [7:0] current_erasure,temp_init_erasure,temp_current_erasure,erase_pos;
reg[7:0] erasures[0:31];
reg ready;

//reg temp;

integer count;

`include "shared_multiply.h"


always @(posedge clock)
begin
if(init_erase_reg == 1'b1)
	begin
	inverse_alpha_one[7:0] = alpha_254;
	current_erasure = 8'b10001110;
	end	
	
else
begin				
	if (new_data==1'b1)
	begin
		ready=1'b0;
		gf_multiplier(inverse_alpha_one,current_erasure,temp_current_erasure);
		current_erasure=temp_current_erasure;
		erase_pos = (erase_flag == 1)? current_erasure : 8'd0;
		if(erase_pos!=8'd0)
			erasures[count]=current_erasure;
		count=count+1;	
		ready=1'b1;
		
	end
end

end


always @(posedge clock)
begin
erasure_ready=1'b0;
if(send_erasure_positions==1'b1)
	begin
		temp_reg=erasures[erasure_addr];
		erasure_ready=1'b1;

		//count=count+1;
		//erase_pos = (erase_flag == 1)? current_erasure : 8'd0;
		
		//if(erase_pos!=8'd0)
		//begin
		//erasures[7:0]=current_erasure;
		//temp_reg=current_erasure;
		//start_erasure_polyn_compute=1'b1;
		//end	
	end


end
assign temp = init_erase_reg;
assign erase_position = alpha_254;

//inverse_alpha_one[7:0];//current_erasure;//temp_current_erasure;//;//temp_reg;current_erasure;erasures[0];

endmodule