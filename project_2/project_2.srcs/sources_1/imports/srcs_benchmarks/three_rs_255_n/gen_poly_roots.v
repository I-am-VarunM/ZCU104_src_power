module gen_poly_roots(
			load_gen_poly_roots,
			gf_table_ready,
			alpha,
			clock,
			address,
			read_alpha,
			read_alpha_inverse,
			//start_syndrome,
			root,
			load_roots_done,
			reset,
			synd_addr,
			chien_loc_addr,
			no_of_parity,
			send_roots,
			send_chien_loc_roots,
			roots_ready,
			chien_loc_roots_ready,
			send_roots_done,
			send_chien_loc_roots_done
			//flag
			);

output reg load_roots_done,roots_ready,send_roots_done;
output reg chien_loc_roots_ready,send_chien_loc_roots_done;
output reg [7:0]address;
output [7:0] root;//,test_root;
output reg read_alpha_inverse,read_alpha;//start_syndrome,flag;

input[7:0] synd_addr,chien_loc_addr;
input [7:0] no_of_parity;
input send_roots,send_chien_loc_roots,reset;
input [7:0] alpha;
input  clock,gf_table_ready,load_gen_poly_roots;
wire [7:0] alpha;

reg[7:0] poly_roots[1:32];
reg[7:0] temp_address,temp_address_2,temp_address_3;
//reg flag;
reg [7:0]synd_root;
//reg next_root;

always @(posedge clock)
begin
//if(reset==1'b0)
//begin
load_roots_done<=1'b0;
//if(load_gen_poly_roots==1'b1)
	//begin
		if ((load_gen_poly_roots==1'b1)&&(temp_address < no_of_parity)||(temp_address ==8'd0))
			begin
			load_roots_done=1'b0;
			//flag=1'b0;
			read_alpha_inverse=1'b0;
			read_alpha=1'b0;
			temp_address=temp_address+1;
			address=temp_address;
			read_alpha=1'b1;
			end
		else 
			begin
			//flag=1'b1;
			load_roots_done=1'b1;
			read_alpha=1'b0;
			//temp_address[7:0]=8'b0;
						
			end
		
		
end
//end
always @(posedge clock)
begin
//if(reset==1'b0)
//begin
	if(gf_table_ready==1'b1)
	begin
	//poly_roots[13]<=alpha;
	//temp_address_3=temp_address_3+1;
	poly_roots[address-1]=alpha;
	end
end
//end

always @(posedge clock)
begin
//if(reset==1'b0)
//begin
send_roots_done<=1'b0;
if((send_roots==1'b1)&&(synd_addr < no_of_parity)||(synd_addr ==8'd0))
	begin
		roots_ready=1'b0;
		send_roots_done=1'b0;
		//temp_address_2=synd_addr;
		synd_root=poly_roots[synd_addr];//[temp_address_2];
		roots_ready=1'b1;
		end
	else
		send_roots_done=1'b1;
		//temp_address_2[7:0]=8'b0;
	end
//end

always @(posedge clock)
begin
//if(reset==1'b0)
//begin
if((send_chien_loc_roots==1'b1)&&(chien_loc_addr <= (no_of_parity/8'd2)))
		begin
		chien_loc_roots_ready=1'b0;
		send_chien_loc_roots_done=1'b0;
		temp_address_3=chien_loc_addr;
		chien_loc_roots_ready=1'b1;
		end
	else
		send_chien_loc_roots_done=1'b1;
end
//end
assign root = synd_root;//poly_roots[temp_address_2];//synd_root;
endmodule

