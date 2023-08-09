/*Derivatives computation, Error-&-erasures (errata) location and magnitude computation, and error corrector units*/
module chien_search_alg(
						clock,
						reset,
						no_of_parity,
						errata_loc_coefs_0,
						errata_loc_coefs_1,
						errata_magnitude_coefs_0,
						errata_magnitude_coefs_1,
						//send_chien_roots,
						send_loc_errata_coefs_0,
						send_loc_errata_coefs_1,
						send_magnitude_errata_coefs_0,
						send_magnitude_errata_coefs_1,
						errata_loc_coef_ready_0,
						errata_loc_coef_ready_1,
						errata_magnitude_coef_ready_0,
						errata_magnitude_coef_ready_1,
						error_location_0,
						error_location_1,
						derivative_error_location,
						error_magnitude,
						MEA_compute_done_0,
						MEA_compute_done_1,
						locator_degree_0,
						locator_degree_1,
						deactivate_chien_serach,//triggered if codeword is error-free
						corrected_error_count,
						cycle,
						errata_loc_addr_0,
						errata_loc_addr_1,
						errata_magnitude_addr_0,
						errata_magnitude_addr_1,
						alpha_inverse,
						err_loc_derivativative,
						read_alpha_inverse,
						gf_table_ready,
						corrected_cw,
						rdaddress,
						rden_delay_buffer,
						q,
						chien_wraddress,
						chien_rdaddress,
						delayed_chien_rdaddress,
						chien_wren,
						chien_rden,
						decoder_fail_flag,
						corrected_cword_ready,
						chien_regs_initialized_0,
						chien_regs_initialized_1,
						);

									
parameter width = 5;
parameter number_of_coefs = 16;
parameter number_of_even_roots = 8;

input clock, reset,errata_loc_coef_ready_0,errata_magnitude_coef_ready_0;
input errata_loc_coef_ready_1,errata_magnitude_coef_ready_1;
input [7:0] errata_loc_coefs_0, errata_magnitude_coefs_0;
input [7:0] errata_loc_coefs_1, errata_magnitude_coefs_1;
input [width-1:0]no_of_parity;
input [width-1:0]errata_loc_addr_0,errata_magnitude_addr_0;
input [width-1:0]errata_loc_addr_1,errata_magnitude_addr_1;
input [width-1:0] locator_degree_0;
input [width-1:0] locator_degree_1;
input MEA_compute_done_0;
input MEA_compute_done_1;
input deactivate_chien_serach;
input [7:0] q;
input [7:0] alpha_inverse;
input gf_table_ready;

output send_loc_errata_coefs_0,send_magnitude_errata_coefs_0,corrected_cword_ready;//send_chien_roots,
output send_loc_errata_coefs_1,send_magnitude_errata_coefs_1;
output [7:0] error_location_0,error_location_1,error_magnitude;
output [7:0] derivative_error_location;
output [7:0] corrected_error_count;
output [8:0] cycle;

output read_alpha_inverse;
output [7:0] err_loc_derivativative,corrected_cw;
output [7:0] rdaddress,chien_wraddress,chien_rdaddress,delayed_chien_rdaddress;
output decoder_fail_flag,rden_delay_buffer,chien_wren,chien_rden;
output chien_regs_initialized_0,chien_regs_initialized_1;

wire [7:0] q_omega,q_sigma,q_sigma_derivative;

`include "shared_multiply.h"

reg [7:0] temp_error_loc_0 [0:number_of_coefs];
reg [7:0] temp_error_loc_1 [0:number_of_coefs];
reg [7:0] temp_error_magnitude_0 [0:number_of_coefs];
reg [7:0] temp_error_magnitude_1 [0:number_of_coefs];
reg [7:0] chien_roots [0:number_of_even_roots];
reg [7:0] alpha_1_mult_sigma_deriv_0,alpha_1_mult_sigma_deriv_1,alpha_1_mult_odd_omega;//sigma_even, sigma_odd,temp_omega,
reg [7:0] sigma_0,sigma_1,sigma_derivative_0,sigma_derivative_1;
reg [7:0] even_omega,odd_omega,omega,chien_odd_reg;//,temp_sum_of_omega,temp_sum_of_sigma_derivative,temp_sum_of_sigma,alpha_1_reg,test1,test2;
reg [7:0] even_sum_of_sigma_0, sum_of_sigma_derivative_0,sum_of_omega;
reg [7:0] even_sum_of_sigma_1, sum_of_sigma_derivative_1;
//reg [7:0] root_temp_addr, errata_temp_addr;
reg start_chien_alg,chien_search_done,chien_regs_initialized;
reg [8:0]clock_cycle,symbol_cycle,addr,delay_addr;
reg [width-1:0] error_counter;
reg [7:0] cw_error;
reg zero_sigma_derv;
reg corrected_cw_ready;

integer j,k,m;
omega_buffer		buffer0(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(omega),
							.rden			(chien_rden),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_omega)  
							);

sigma_buffer		buffer1_0(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_0),
							.rden			(chien_rden),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_0) 
							);

sigma_buffer_1		buffer1_1(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_1),
							.rden			(chien_rden),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_1) 
							);
							
derivative_buffer	buffer3_0(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_derivative_0),
							.rden			(chien_rden),
							.rdaddress		(delayed_chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_derivative_0) 
							);
							
derivative_buffer_1		buffer3_1(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_derivative_1),
							.rden			(chien_rden),
							.rdaddress		(delayed_chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_derivative_1) 
							);


/**handshaking requesting for the coefficients of errata magnitude & errata locator polynomial**/
always @(posedge clock)
begin
if (reset==1)
begin
send_magnitude_errata_coefs_0=1'b0;
send_loc_errata_coefs_0=1'b0;
chien_regs_initialized_0 = 1'b0;

send_magnitude_errata_coefs_1=1'b0;
send_loc_errata_coefs_1=1'b0;
chien_regs_initialized_1 = 1'b0;

end 
else begin
		if(MEA_compute_done_0==1'b1 && errata_loc_addr_0 <= locator_degree_0)//load_chien_regs
			begin
				send_magnitude_errata_coefs_0 = 1'b1;
				send_loc_errata_coefs_0 = 1'b1;
			end
		else if (errata_loc_addr_0 > locator_degree_0)
			begin
				chien_regs_initialized_0 = 1'b1; 
				send_magnitude_errata_coefs_0 = 1'b0;
				send_loc_errata_coefs_0 = 1'b0;
			end
		
		if(MEA_compute_done_1==1'b1 && errata_loc_addr_1 <= locator_degree_1)//load_chien_regs
			begin
				send_magnitude_errata_coefs_1 = 1'b1;
				send_loc_errata_coefs_1 = 1'b1;
			end
		else if (errata_loc_addr_1 > locator_degree_1)
			begin
				chien_regs_initialized_1 = 1'b1; 
				send_magnitude_errata_coefs_1 = 1'b0;
				send_loc_errata_coefs_1 = 1'b0;
			end
		end
end

/******Loading the roots and coefs of the errata polynomials********/
always @(posedge clock)
begin
if (reset==1'b1)
begin 
	chien_search_done=1'b0;
	read_alpha_inverse =1'b0;
	corrected_cw_ready =1'b0;
	rdaddress = 8'd0;
	rden_delay_buffer = 1'b0;
	zero_sigma_derv = 1'b0;
	decoder_fail_flag = 1'b0;
	
	/*generator polynomial roots with even power  */
	chien_roots[0]= 1;chien_roots[1]= 4;chien_roots[2]= 16;chien_roots[3]= 64;chien_roots[4]= 29;
	chien_roots[5]= 116;chien_roots[6]= 205;chien_roots[7]= 19;chien_roots[8]= 76;
end
else begin
	if(errata_loc_coef_ready_0==1'b1)//loading errors-&-erasure locator polynomial
		begin
		temp_error_loc_0[errata_loc_addr_0]= errata_loc_coefs_0;
		end
	if(errata_magnitude_coef_ready_0==1'b1)//loading error-&-erasure magnitude polynomial
		begin
		temp_error_magnitude_0[errata_magnitude_addr_0]= errata_magnitude_coefs_0;
		end	
	
	if(errata_loc_coef_ready_1==1'b1)//loading errors-&-erasure locator polynomial
		begin
		temp_error_loc_1[errata_loc_addr_1]= errata_loc_coefs_1;
		end
	if(errata_magnitude_coef_ready_1==1'b1)//loading error-&-erasure magnitude polynomial
		begin
		temp_error_magnitude_1[errata_magnitude_addr_1]=errata_magnitude_coefs_1;
		end	
/************************** chien search algorithm**************************/
/*1.Determine the roots of the errata locator polynomial (codeword error locations)
  2. Determine and evaluate the derivative of errata locator polynomial
  3. Evaluate the errata magnitude polynomial
****************************************************************************/	
	if(chien_regs_initialized_0 == 1'b1 && chien_regs_initialized_1 == 1'b1)//start_chien_alg==1'b1
		begin
			if(chien_search_done==1'b0)
				begin 
					if(clock_cycle==1'd0)
						chien_odd_reg = 8'd1;
					else if(clock_cycle==1'd1)
						chien_odd_reg = 8'd2;
					else 
						gf_multiplier(chien_odd_reg,8'd2,chien_odd_reg);
		
					even_sum_of_sigma_0 = (temp_error_loc_0[0]^temp_error_loc_0[2])^(temp_error_loc_0[4]^temp_error_loc_0[6])^(temp_error_loc_0[8]^temp_error_loc_0[10])^(temp_error_loc_0[12]^temp_error_loc_0[14])^temp_error_loc_0[16];
					even_sum_of_sigma_1 = (temp_error_loc_1[0]^temp_error_loc_1[2])^(temp_error_loc_1[4]^temp_error_loc_1[6])^(temp_error_loc_1[8]^temp_error_loc_1[10])^(temp_error_loc_1[12]^temp_error_loc_1[14])^temp_error_loc_1[16];
					sigma_derivative_0 = (temp_error_loc_0[1]^temp_error_loc_0[3])^(temp_error_loc_0[5]^temp_error_loc_0[7])^(temp_error_loc_0[9]^temp_error_loc_0[11])^(temp_error_loc_0[13]^temp_error_loc_0[15]);
					sigma_derivative_1 = (temp_error_loc_1[1]^temp_error_loc_1[3])^(temp_error_loc_1[5]^temp_error_loc_1[7])^(temp_error_loc_1[9]^temp_error_loc_1[11])^(temp_error_loc_1[13]^temp_error_loc_1[15]);
					//even_omega = (temp_error_magnitude[0]^temp_error_magnitude[2])^(temp_error_magnitude[4]^temp_error_magnitude[6])^(temp_error_magnitude[8]^temp_error_magnitude[10])^(temp_error_magnitude[12]^temp_error_magnitude[14])^temp_error_magnitude[16];
					//odd_omega = (temp_error_magnitude[1]^temp_error_magnitude[3])^(temp_error_magnitude[5]^temp_error_magnitude[7])^(temp_error_magnitude[9]^temp_error_magnitude[11])^(temp_error_magnitude[13]^temp_error_magnitude[15]);

					for(j = 0;j <= number_of_even_roots;j = j + 1)
						begin
							k = j * 2;
							m = k + 1;
							gf_multiplier(chien_roots[j],temp_error_loc_0[k],temp_error_loc_0[k]);
							gf_multiplier(chien_roots[j],temp_error_loc_1[k],temp_error_loc_1[k]);
							//gf_multiplier(chien_roots[j],temp_error_magnitude[k],temp_error_magnitude[k]);
							if(j<number_of_even_roots)
								begin
									gf_multiplier(chien_roots[j],temp_error_loc_0[m],temp_error_loc_0[m]);
									gf_multiplier(chien_roots[j],temp_error_loc_1[m],temp_error_loc_1[m]);
									//gf_multiplier(chien_roots[j],temp_error_magnitude[m],temp_error_magnitude[m]);
								end
						end
				
					gf_multiplier(sigma_derivative_0,chien_odd_reg,alpha_1_mult_sigma_deriv_0);
					gf_multiplier(sigma_derivative_1,chien_odd_reg,alpha_1_mult_sigma_deriv_1);
					//gf_multiplier(odd_omega,chien_odd_reg,alpha_1_mult_odd_omega);
		 		end
			sigma_0 = alpha_1_mult_sigma_deriv_0 ^ even_sum_of_sigma_0;
			sigma_1 = alpha_1_mult_sigma_deriv_1 ^ even_sum_of_sigma_1;			
			//omega = alpha_1_mult_odd_omega ^ even_omega;
			chien_wren = 1'b1;
			chien_wraddress = clock_cycle;
			clock_cycle = clock_cycle + 1;

/*****************************Forney algorithm and Error corrector***************************/
/*1. Determine the error values in each erroneous codeword byte
  2. Correct the erroneous bytes
 */
			if (chien_search_done==1'b0 && clock_cycle >= 8'd2)
				begin
					chien_rden = 1'b1;
					rden_delay_buffer = 1'b1;
					read_alpha_inverse = 1'b1;
					delayed_chien_rdaddress = clock_cycle - 2;
					if(clock_cycle >= 8'd4)
						begin
							chien_rdaddress = clock_cycle-4;
							rdaddress = clock_cycle - 4;// Data in the FIFO starts from addr 1 to addr 255
						end
					err_loc_derivativative = q_sigma_derivative;
				/*	if(gf_table_ready==1'b1)
						begin
							gf_multiplier(alpha_inverse,q_omega,cw_error);
								if(q_sigma==8'd0)
				  					begin
										error_counter = error_counter + 1;//6'd1;//keeping track located errors
										if (rdaddress>8'd2)corrected_cw_ready = 1'b1;
										corrected_cw = q ^ cw_error;
				 					end
								else if(q_sigma!=8'd0)
				  					begin 
										if (rdaddress>8'd2)corrected_cw_ready =1'b1;
										corrected_cw = q;
				  					end
						end
			*/	end
		/*	if(clock_cycle>=9'd259)
				begin
					chien_search_done=1'b1; rden_delay_buffer = 1'b0; rdaddress = 8'd0;//rden
					if(locator_degree!= error_counter)
						decoder_fail_flag = 1'b1;//there are more errors than can be handled by the decoder
		 			else 
						decoder_fail_flag = 1'b0;
				end
	*/
		end//end of start_chien_alg
	
/** If the syndrome==0, the codeword is error free therefore Chien search algorithm is noe executed**/
/** Codeword in the FIFO is correct as is **/	
		else if (deactivate_chien_serach==1'b1)//cw is error free
			begin
				rden_delay_buffer = 1'b1;//rden
				rdaddress = symbol_cycle;
				symbol_cycle = symbol_cycle + 1;
				corrected_cw = q;
			end
	end
end

assign error_location_0 = q_sigma_0;
assign error_location_1 = q_sigma_1;
assign derivative_error_location = alpha_inverse;//sigma_derivative;
assign error_magnitude = q_omega;
assign corrected_cword_ready = gf_table_ready;//corrected_cw_ready;
assign corrected_error_count = error_counter;
assign cycle = clock_cycle;
assign chien_regs_initialized = chien_regs_initialized;

endmodule
	