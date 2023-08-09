/*Error detection unit*/
module syndromes221 (
				reset,
				clock,
				syndrome,
				new_data,
				recd,
				codeword_end_flag,
				send_syndromes,
				syndrome_ready,
				syndr_coef_addr,
				decoder_rd_addr,
				unmodified_syndrome_ready_0,
				unmodified_syndr_coef_addr_0,
				send_unmodified_syndr_polyn_0,
				unmodified_syndr_polyn_0,
				unmodified_syndrome_ready_1,
				unmodified_syndr_coef_addr_1,
				send_unmodified_syndr_polyn_1,
				unmodified_syndr_polyn_1,
				unmodified_syndrome_ready_2,
				unmodified_syndr_coef_addr_2,
				send_unmodified_syndr_polyn_2,
				unmodified_syndr_polyn_2
				);

parameter width = 6;
parameter number_of_coefs = 34;

input  clock,reset, new_data;
input send_syndromes,send_unmodified_syndr_polyn_0,send_unmodified_syndr_polyn_1,send_unmodified_syndr_polyn_2;
input [7:0] recd,decoder_rd_addr;

output reg codeword_end_flag,syndrome_ready;
output reg unmodified_syndrome_ready_0,unmodified_syndrome_ready_1,unmodified_syndrome_ready_2;
output [7:0] syndrome;
output reg unmodified_syndr_polyn_0,unmodified_syndr_polyn_1,unmodified_syndr_polyn_2;
output reg [width-1:0] syndr_coef_addr;
output reg [width-1:0] unmodified_syndr_coef_addr_0,unmodified_syndr_coef_addr_1,unmodified_syndr_coef_addr_2;


reg output_syndrome;
reg[7:0] synd_alpha [1:number_of_coefs];
reg[7:0] data_out [1:number_of_coefs];
reg[7:0] temp_data [1:number_of_coefs];
reg[7:0]syndrom [1:number_of_coefs];
reg[7:0]syndr;
reg[width-1:0]syndrome_addr,unmodified_syndr_addr_0,unmodified_syndr_addr_1,unmodified_syndr_addr_2;

`include "shared_multiply.h"

integer byte_count,count,i,k;

always @(posedge clock)
begin
if(reset==1'b1)//generator polynomial roots for RS(255,223)
begin
synd_alpha[1]<=8'd2;synd_alpha[2]<=8'd4;synd_alpha[3]<=8'd8;synd_alpha[4]<=8'd16;synd_alpha[5]<=8'd32;
synd_alpha[6]<=8'd64;synd_alpha[7]<=8'd128;synd_alpha[8]<=8'd29;synd_alpha[9]<=8'd58;synd_alpha[10]<=8'd116;
synd_alpha[11]<=8'd232;synd_alpha[12]<=8'd205;synd_alpha[13]<=8'd135;synd_alpha[14]<=8'd19;synd_alpha[15]<=8'd38;
synd_alpha[16]<=8'd76;synd_alpha[17]<=8'd152;synd_alpha[18]<=8'd45;synd_alpha[19]<=8'd90;synd_alpha[20]<=8'd180;
synd_alpha[21]<=8'd117;synd_alpha[22]<=8'd234;synd_alpha[23]<=8'd201;synd_alpha[24]<=8'd143;synd_alpha[25]<=8'd3;
synd_alpha[26]<=8'd6;synd_alpha[27]<=8'd12;synd_alpha[28]<=8'd24;synd_alpha[29]<=8'd48;synd_alpha[30]<=8'd96;
synd_alpha[31]<=8'd192;synd_alpha[32]<=8'd157;synd_alpha[33]<=8'd39;synd_alpha[34]<=8'd78;
end
end

always @(posedge clock)
begin
if(reset==1'b1)
	begin
	codeword_end_flag=1'b0;
	end
else
if(reset==1'b0)
begin
	if(new_data==1'b1 && decoder_rd_addr >= 8'd1 &&(byte_count<255))
	begin
	for(i=1;i<=number_of_coefs;i=i+1)//generation of syndrome s(x)
		begin
			gf_multiplier(temp_data[i],synd_alpha[i],data_out[i]);
			temp_data[i]<=data_out[i]^recd[7:0];
		end
	byte_count = byte_count+1;
	end
	if(byte_count >= 255)
	begin
		for(k=1;k<=number_of_coefs;k=k+1)
			syndrom[k]<=temp_data[k];
			codeword_end_flag=1'b1;
	end
end	
end

always @(posedge clock)
begin
if(reset==1'b0)
begin
output_syndrome=1'b0;
if(codeword_end_flag==1'b1)output_syndrome=1'b1;
end
end

/****Sending out the coefficients of syndrome polynomial--> s(x)*****/
always @(posedge clock)
begin
if(reset==1'b0)
begin
syndrome_ready=1'b0;
	if((output_syndrome==1'b1)&&(send_syndromes==1'b1))
		begin
			syndr_coef_addr = syndrome_addr;
			syndr = syndrom[syndr_coef_addr];
			syndrome_addr = syndrome_addr+1;
			syndrome_ready = 1'b1;
		end	
	else if (send_syndromes==1'b0)
		begin
		syndrome_ready = 1'b0;
		end
	if((output_syndrome==1'b1)&&(send_unmodified_syndr_polyn_0==1'b1))
	begin
			unmodified_syndr_coef_addr_0 = unmodified_syndr_addr_0;
			unmodified_syndr_polyn_0 = syndrom[unmodified_syndr_coef_addr_0+1];
			unmodified_syndr_addr_0 = unmodified_syndr_addr_0+1;
			unmodified_syndrome_ready_0 = 1'b1;		
	end
	else if (send_unmodified_syndr_polyn_0==1'b0)begin unmodified_syndrome_ready_0 = 1'b0; end
	
	if((output_syndrome==1'b1)&&(send_unmodified_syndr_polyn_1==1'b1))
	begin
			unmodified_syndr_coef_addr_1 = unmodified_syndr_addr_1;
			unmodified_syndr_polyn_1 = syndrom[unmodified_syndr_coef_addr_1+1];
			unmodified_syndr_addr_1 = unmodified_syndr_addr_1+1;
			unmodified_syndrome_ready_1 = 1'b1;		
	end
	else if (send_unmodified_syndr_polyn_1==1'b0)begin unmodified_syndrome_ready_1 = 1'b0; end
	
	if((output_syndrome==1'b1)&&(send_unmodified_syndr_polyn_2==1'b1))
	begin
			unmodified_syndr_coef_addr_2 = unmodified_syndr_addr_2;
			unmodified_syndr_polyn_2 = syndrom[unmodified_syndr_coef_addr_2+1];
			unmodified_syndr_addr_2 = unmodified_syndr_addr_2+1;
			unmodified_syndrome_ready_2 = 1'b1;		
	end
	else if (send_unmodified_syndr_polyn_2==1'b0)begin unmodified_syndrome_ready_2 = 1'b0; end
end
else
	begin
		syndrome_addr = 1;
		unmodified_syndr_addr_0 = 8'd0;
		unmodified_syndrome_ready_0 = 1'b0;
		unmodified_syndr_addr_1 = 8'd0;
		unmodified_syndrome_ready_1 = 1'b0;
		unmodified_syndr_addr_2 = 8'd0;
		unmodified_syndrome_ready_2 = 1'b0;
	end//the addresses of the syndromes begin from addr 1 to addr 32
end

assign 	syndrome = syndr[7:0];

endmodule
