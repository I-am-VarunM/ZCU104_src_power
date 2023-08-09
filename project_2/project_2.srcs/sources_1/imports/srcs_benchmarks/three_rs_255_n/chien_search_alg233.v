/*Derivatives computation, Error-&-erasures (errata) location and magnitude computation, and error corrector units*/
module chien_search_alg233(
						clock,
						reset,
						no_of_parity,
						errata_loc_coefs_0,
						errata_loc_coefs_1,
						errata_loc_coefs_2,
						errata_magnitude_coefs_0,
						errata_magnitude_coefs_1,
						errata_magnitude_coefs_2,
						send_loc_errata_coefs_0,
						send_loc_errata_coefs_1,
						send_loc_errata_coefs_2,
						send_magnitude_errata_coefs_0,
						send_magnitude_errata_coefs_1,
						send_magnitude_errata_coefs_2,
						errata_loc_coef_ready_0,
						errata_loc_coef_ready_1,
						errata_loc_coef_ready_2,
						errata_magnitude_coef_ready_0,
						errata_magnitude_coef_ready_1,
						errata_magnitude_coef_ready_2,
						error_location_0,
						error_location_1,
						error_location_2,
						derivative_error_location,
						error_magnitude,
						MEA_compute_done_0,
						MEA_compute_done_1,
						MEA_compute_done_2,
						locator_degree_0,
						locator_degree_1,
						locator_degree_2,
						deactivate_chien_serach,//triggered if codeword is error-free
						corrected_error_count,
						cycle,
						errata_loc_addr_0,
						errata_loc_addr_1,
						errata_loc_addr_2,
						errata_magnitude_addr_0,
						errata_magnitude_addr_1,
						errata_magnitude_addr_2,
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
						chien_rden_0,
						chien_rden_1,
						chien_rden_2,
						chien_rden_omega,
						decoder_fail_flag,
						corrected_cword_ready,
						chien_regs_initialized_0,
						chien_regs_initialized_1,
						chien_regs_initialized_2,
						chien_wraddress_omega,
						chien_rdaddress_omega,
						chien_wren_omega
						);

									
parameter width = 5;
parameter number_of_coefs = 22;
parameter number_of_even_roots = 11;

input clock, reset;
input errata_loc_coef_ready_0,errata_magnitude_coef_ready_0;
input errata_loc_coef_ready_1,errata_magnitude_coef_ready_1;
input errata_loc_coef_ready_2,errata_magnitude_coef_ready_2;
input [7:0] errata_loc_coefs_0, errata_magnitude_coefs_0;
input [7:0] errata_loc_coefs_1, errata_magnitude_coefs_1;
input [7:0] errata_loc_coefs_2, errata_magnitude_coefs_2;
input [width-1:0]no_of_parity;
input [width-1:0]errata_loc_addr_0,errata_magnitude_addr_0;
input [width-1:0]errata_loc_addr_1,errata_magnitude_addr_1;
input [width-1:0]errata_loc_addr_2,errata_magnitude_addr_2;
input [width-1:0] locator_degree_0;
input [width-1:0] locator_degree_1;
input [width-1:0] locator_degree_2;
input MEA_compute_done_0;
input MEA_compute_done_1;
input MEA_compute_done_2;
input deactivate_chien_serach;
input [7:0] q;
input [7:0] alpha_inverse;
input gf_table_ready;

output corrected_cword_ready;
output reg send_loc_errata_coefs_0,send_magnitude_errata_coefs_0;//send_chien_roots,
output reg send_loc_errata_coefs_1,send_magnitude_errata_coefs_1;
output reg send_loc_errata_coefs_2,send_magnitude_errata_coefs_2;
output [7:0] error_location_0,error_location_1,error_location_2,error_magnitude;
output [7:0] derivative_error_location;
output [7:0] corrected_error_count;
output [8:0] cycle;

output reg read_alpha_inverse;
output reg [7:0] err_loc_derivativative,corrected_cw;
output reg [7:0] rdaddress,chien_wraddress,chien_rdaddress,chien_wraddress_omega,chien_rdaddress_omega;
output reg [7:0] delayed_chien_rdaddress;
output reg decoder_fail_flag,rden_delay_buffer,chien_wren,chien_wren_omega;
output reg chien_rden_0,chien_rden_1,chien_rden_2,chien_rden_omega;
output reg chien_regs_initialized_0,chien_regs_initialized_1,chien_regs_initialized_2;

wire [7:0] q_sigma_0,q_sigma_1,q_sigma_2;
wire [7:0] q_sigma_derivative_0,q_sigma_derivative_1,q_sigma_derivative_2;
wire [7:0] q_omega;
reg [7:0] q_sigma;
`include "shared_multiply.h"

reg [7:0] temp_error_loc_0 [0:number_of_coefs];
reg [7:0] temp_error_loc_1 [0:number_of_coefs];
reg [7:0] temp_error_loc_2 [0:number_of_coefs];
reg [7:0] temp_error_magnitude_0[0:number_of_coefs];
reg [7:0] temp_error_magnitude_1 [0:number_of_coefs];
reg [7:0] temp_error_magnitude_2 [0:number_of_coefs];
reg [7:0] chien_roots [0:number_of_even_roots];
reg [7:0] alpha_1_mult_sigma_deriv_0,alpha_1_mult_sigma_deriv_1,alpha_1_mult_sigma_deriv_2;
reg [7:0] alpha_1_mult_odd_omega;
reg [7:0] sigma_0,sigma_1,sigma_2,sigma_derivative_0,sigma_derivative_1,sigma_derivative_2;
reg [7:0] even_omega,odd_omega,omega,chien_odd_reg,chien_odd_reg_out;
reg [7:0] even_sum_of_sigma_0, sum_of_sigma_derivative_0,sum_of_omega;
reg [7:0] even_sum_of_sigma_1, sum_of_sigma_derivative_1;
reg [7:0] even_sum_of_sigma_2, sum_of_sigma_derivative_2;

reg start_chien_alg,start_forney_and_err_corrector,chien_search_done;
wire chien_regs_initialized;
reg [8:0]chien_clock_cycle,symbol_cycle,addr,delay_addr,decoder_output_cycle,output_cycle;
reg [width-1:0] error_counter_0,error_counter_1,error_counter_2;
reg [7:0] cw_error;
reg zero_sigma_derv;
reg corrected_cw_ready;

integer j,k,m;
omega_buffer		buffer0(
							.wraddress		(chien_wraddress_omega),
							.wren			(chien_wren_omega),
							.data			(omega),
							.rden			(chien_rden_omega),
							.rdaddress		(chien_rdaddress_omega),
							.clock			(clock),
							.q				(q_omega)  
							);

sigma_buffer		buffer1_0(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_0),
							.rden			(chien_rden_0),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_0) 
							);

sigma_buffer_1		buffer1_1(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_1),
							.rden			(chien_rden_1),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_1) 
							);

sigma_buffer_2		buffer1_2(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_2),
							.rden			(chien_rden_2),
							.rdaddress		(chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_2) 
							);
							
derivative_buffer	buffer3_0(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_derivative_0),
							.rden			(chien_rden_0),
							.rdaddress		(delayed_chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_derivative_0) 
							);
							
derivative_buffer_1		buffer3_1(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_derivative_1),
							.rden			(chien_rden_1),
							.rdaddress		(delayed_chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_derivative_1) 
							);

derivative_buffer_2		buffer3_2(
							.wraddress		(chien_wraddress),
							.wren			(chien_wren),
							.data			(sigma_derivative_2),
							.rden			(chien_rden_2),
							.rdaddress		(delayed_chien_rdaddress),
							.clock			(clock),
							.q				(q_sigma_derivative_2) 
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

send_magnitude_errata_coefs_2=1'b0;
send_loc_errata_coefs_2=1'b0;
chien_regs_initialized_2 = 1'b0;
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
		
		if(MEA_compute_done_2==1'b1 && errata_loc_addr_2 <= locator_degree_2)//load_chien_regs
			begin
				send_magnitude_errata_coefs_2 = 1'b1;
				send_loc_errata_coefs_2 = 1'b1;
			end
		else if (errata_loc_addr_2 > locator_degree_2)
			begin
				chien_regs_initialized_2 = 1'b1; 
				send_magnitude_errata_coefs_2 = 1'b0;
				send_loc_errata_coefs_2 = 1'b0;
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
	start_forney_and_err_corrector = 1'b0;
	chien_clock_cycle = 0;
	symbol_cycle = 0;
	
	/*generator polynomial roots with even power  */
	chien_roots[0]= 1;chien_roots[1]= 4;chien_roots[2]= 16;chien_roots[3]= 64;chien_roots[4]= 29;
	chien_roots[5]= 116;chien_roots[6]= 205;chien_roots[7]= 19;chien_roots[8]= 76;chien_roots[9]= 45;
	chien_roots[10]= 180;chien_roots[11]= 234;
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
	
	if(errata_loc_coef_ready_2==1'b1)//loading errors-&-erasure locator polynomial
		begin
		temp_error_loc_2[errata_loc_addr_2]= errata_loc_coefs_2;
		end
	if(errata_magnitude_coef_ready_2==1'b1)//loading error-&-erasure magnitude polynomial
		begin
		temp_error_magnitude_2[errata_magnitude_addr_2]=errata_magnitude_coefs_2;
		end	
/************************** chien search algorithm**************************/
/*1.Determine the roots of the errata locator polynomial (codeword error locations)
  2. Determine and evaluate the derivative of errata locator polynomial
  3. Evaluate the errata magnitude polynomial
****************************************************************************/	
	if(chien_regs_initialized_0 == 1'b1 && chien_regs_initialized_1 == 1'b1 && chien_regs_initialized_2 == 1'b1)//start_chien_alg==1'b1
		begin
			if(chien_clock_cycle==1'd0)
				chien_odd_reg = 8'd1;
			else if(chien_clock_cycle==1'd1)
				chien_odd_reg = 8'd2;
			else 
				gf_multiplier(chien_odd_reg,8'd2,chien_odd_reg);
			if(decoder_output_cycle==1'd0)
				chien_odd_reg_out = 8'd1;
			else if(decoder_output_cycle==1'd1)
				chien_odd_reg_out = 8'd2;
			else 
				gf_multiplier(chien_odd_reg_out,8'd2,chien_odd_reg_out);
				
			if (chien_clock_cycle <= 255 && corrected_cw_ready==1'b0)
				begin 
					even_sum_of_sigma_0 = (temp_error_loc_0[0]^temp_error_loc_0[2])^(temp_error_loc_0[4]^temp_error_loc_0[6])^(temp_error_loc_0[8]^temp_error_loc_0[10])^(temp_error_loc_0[12]^temp_error_loc_0[14])^(temp_error_loc_0[16]^temp_error_loc_0[18])^(temp_error_loc_0[20]^temp_error_loc_0[22]);
					even_sum_of_sigma_1 = (temp_error_loc_1[0]^temp_error_loc_1[2])^(temp_error_loc_1[4]^temp_error_loc_1[6])^(temp_error_loc_1[8]^temp_error_loc_1[10])^(temp_error_loc_1[12]^temp_error_loc_1[14])^(temp_error_loc_1[16]^temp_error_loc_1[18])^(temp_error_loc_1[20]^temp_error_loc_1[22]);
					even_sum_of_sigma_2 = (temp_error_loc_2[0]^temp_error_loc_2[2])^(temp_error_loc_2[4]^temp_error_loc_2[6])^(temp_error_loc_2[8]^temp_error_loc_2[10])^(temp_error_loc_2[12]^temp_error_loc_2[14])^(temp_error_loc_2[16]^temp_error_loc_2[18])^(temp_error_loc_2[20]^temp_error_loc_2[22]);
					sigma_derivative_0 = (temp_error_loc_0[1]^temp_error_loc_0[3])^(temp_error_loc_0[5]^temp_error_loc_0[7])^(temp_error_loc_0[9]^temp_error_loc_0[11])^(temp_error_loc_0[13]^temp_error_loc_0[15])^(temp_error_loc_0[17]^temp_error_loc_0[19])^temp_error_loc_0[21];
					sigma_derivative_1 = (temp_error_loc_1[1]^temp_error_loc_1[3])^(temp_error_loc_1[5]^temp_error_loc_1[7])^(temp_error_loc_1[9]^temp_error_loc_1[11])^(temp_error_loc_1[13]^temp_error_loc_1[15])^(temp_error_loc_1[17]^temp_error_loc_1[19])^temp_error_loc_1[21];
					sigma_derivative_2 = (temp_error_loc_2[1]^temp_error_loc_2[3])^(temp_error_loc_2[5]^temp_error_loc_2[7])^(temp_error_loc_2[9]^temp_error_loc_2[11])^(temp_error_loc_2[13]^temp_error_loc_2[15])^(temp_error_loc_2[17]^temp_error_loc_2[19])^temp_error_loc_2[21];

					for(j = 0;j <= number_of_even_roots;j = j + 1)
						begin
							k = j * 2;
							m = k + 1;
							gf_multiplier(chien_roots[j],temp_error_loc_0[k],temp_error_loc_0[k]);
							gf_multiplier(chien_roots[j],temp_error_loc_1[k],temp_error_loc_1[k]);
							gf_multiplier(chien_roots[j],temp_error_loc_2[k],temp_error_loc_2[k]);
							if(j<number_of_even_roots)
								begin
									gf_multiplier(chien_roots[j],temp_error_loc_0[m],temp_error_loc_0[m]);
									gf_multiplier(chien_roots[j],temp_error_loc_1[m],temp_error_loc_1[m]);
									gf_multiplier(chien_roots[j],temp_error_loc_2[m],temp_error_loc_2[m]);
								end
						end
				
					gf_multiplier(sigma_derivative_0,chien_odd_reg,alpha_1_mult_sigma_deriv_0);
					gf_multiplier(sigma_derivative_1,chien_odd_reg,alpha_1_mult_sigma_deriv_1);
					gf_multiplier(sigma_derivative_2,chien_odd_reg,alpha_1_mult_sigma_deriv_2);

					sigma_0 = alpha_1_mult_sigma_deriv_0 ^ even_sum_of_sigma_0;
					sigma_1 = alpha_1_mult_sigma_deriv_1 ^ even_sum_of_sigma_1;			
					sigma_2 = alpha_1_mult_sigma_deriv_2 ^ even_sum_of_sigma_2;			
					if(sigma_0 == 8'd0) error_counter_0 = error_counter_0 + 1;
					if(sigma_1 == 8'd0) error_counter_1 = error_counter_1 + 1;
					if(sigma_2 == 8'd0) error_counter_2 = error_counter_2 + 1;
					chien_wren = 1'b1;
					chien_wraddress = chien_clock_cycle;
					chien_clock_cycle = chien_clock_cycle + 1;
				end
/*****************************Forney algorithm and Error corrector***************************/
/*1. Determine the error values in each erroneous codeword byte
  2. Correct the erroneous bytes
 */
				else//if (chien_clock_cycle >= 255)
					begin
						if(error_counter_0 != locator_degree_0 && error_counter_1 != locator_degree_1 && error_counter_2 != locator_degree_2)
							decoder_fail_flag = 1'b1;//there are more errors than can be handled by the decoders
						else 
							begin
								decoder_fail_flag = 1'b0;
								chien_clock_cycle = 9'd257;//chien_clock_cycle + 1;
							end
						if (decoder_fail_flag == 1'b0 && chien_clock_cycle == 257)
							begin
								chien_wren = 1'b0;
								if (error_counter_0 == locator_degree_0)
									begin
										chien_rden_0 = 1'b1;
										q_sigma = q_sigma_0;
										even_omega = (temp_error_magnitude_0[0]^temp_error_magnitude_0[2])^(temp_error_magnitude_0[4]^temp_error_magnitude_0[6])^(temp_error_magnitude_0[8]^temp_error_magnitude_0[10])^(temp_error_magnitude_0[12]^temp_error_magnitude_0[14])^(temp_error_magnitude_0[16]^temp_error_magnitude_0[18])^(temp_error_magnitude_0[20]^temp_error_magnitude_0[22]);
										odd_omega = (temp_error_magnitude_0[1]^temp_error_magnitude_0[3])^(temp_error_magnitude_0[5]^temp_error_magnitude_0[7])^(temp_error_magnitude_0[9]^temp_error_magnitude_0[11])^(temp_error_magnitude_0[13]^temp_error_magnitude_0[15])^(temp_error_magnitude_0[17]^temp_error_magnitude_0[19])^temp_error_magnitude_0[21];
					
										for(j = 0;j <= number_of_even_roots;j = j + 1)
											begin
												k = j * 2;
												m = k + 1;
												gf_multiplier(chien_roots[j],temp_error_magnitude_0[k],temp_error_magnitude_0[k]);
												if(j<number_of_even_roots)
													begin
														gf_multiplier(chien_roots[j],temp_error_magnitude_0[m],temp_error_magnitude_0[m]);
													end
											end
									end
								else if (error_counter_1 == locator_degree_1)
										begin
											chien_rden_1 = 1'b1;
											q_sigma = q_sigma_1;
											even_omega = (temp_error_magnitude_1[0]^temp_error_magnitude_1[2])^(temp_error_magnitude_1[4]^temp_error_magnitude_1[6])^(temp_error_magnitude_1[8]^temp_error_magnitude_1[10])^(temp_error_magnitude_1[12]^temp_error_magnitude_1[14])^(temp_error_magnitude_1[16]^temp_error_magnitude_1[18])^(temp_error_magnitude_1[20]^temp_error_magnitude_1[22]);
											odd_omega = (temp_error_magnitude_1[1]^temp_error_magnitude_1[3])^(temp_error_magnitude_1[5]^temp_error_magnitude_1[7])^(temp_error_magnitude_1[9]^temp_error_magnitude_1[11])^(temp_error_magnitude_1[13]^temp_error_magnitude_1[15])^(temp_error_magnitude_1[17]^temp_error_magnitude_1[19])^temp_error_magnitude_1[21];
					
											for(j = 0;j <= number_of_even_roots;j = j + 1)
												begin
													k = j * 2;
													m = k + 1;
													gf_multiplier(chien_roots[j],temp_error_magnitude_1[k],temp_error_magnitude_1[k]);
													if(j<number_of_even_roots)
														begin
															gf_multiplier(chien_roots[j],temp_error_magnitude_1[m],temp_error_magnitude_1[m]);
														end
												end
										end
									else //if (error_counter_2 == locator_degree_2)
										begin
											chien_rden_2 = 1'b1;
											q_sigma = q_sigma_2;
											even_omega = (temp_error_magnitude_2[0]^temp_error_magnitude_2[2])^(temp_error_magnitude_2[4]^temp_error_magnitude_2[6])^(temp_error_magnitude_2[8]^temp_error_magnitude_2[10])^(temp_error_magnitude_2[12]^temp_error_magnitude_2[14])^(temp_error_magnitude_2[16]^temp_error_magnitude_2[18])^(temp_error_magnitude_2[20]^temp_error_magnitude_2[22]);
											odd_omega = (temp_error_magnitude_2[1]^temp_error_magnitude_2[3])^(temp_error_magnitude_2[5]^temp_error_magnitude_2[7])^(temp_error_magnitude_2[9]^temp_error_magnitude_2[11])^(temp_error_magnitude_2[13]^temp_error_magnitude_2[15])^(temp_error_magnitude_2[17]^temp_error_magnitude_2[19])^temp_error_magnitude_2[21];
					
											for(j = 0;j <= number_of_even_roots;j = j + 1)
												begin
													k = j * 2;
													m = k + 1;
													gf_multiplier(chien_roots[j],temp_error_magnitude_2[k],temp_error_magnitude_2[k]);
													if(j<number_of_even_roots)
														begin
															gf_multiplier(chien_roots[j],temp_error_magnitude_2[m],temp_error_magnitude_2[m]);
														end
												end
										end	
				
									gf_multiplier(odd_omega,chien_odd_reg_out,alpha_1_mult_odd_omega);
									omega = alpha_1_mult_odd_omega ^ even_omega;
					
									chien_wren_omega = 1'b1;
									chien_wraddress_omega = decoder_output_cycle;
									decoder_output_cycle = decoder_output_cycle + 1;
							end //end of decoder_fail_flag == 1'b0 && chien_clock_cycle > 255
				
						if (chien_search_done==1'b0 && decoder_output_cycle >= 8'd2)
							begin
								chien_rden_omega = 1'b1;
								rden_delay_buffer = 1'b1;
								read_alpha_inverse = 1'b1;
								delayed_chien_rdaddress = decoder_output_cycle-2;//clock_cycle - 2;
								if(decoder_output_cycle >= 8'd4)
									begin
										output_cycle = decoder_output_cycle-4;
										chien_rdaddress_omega = output_cycle;//omega
										chien_rdaddress = output_cycle;//sigma
										rdaddress = output_cycle;//Data in the FIFO starts from addr 1 to addr 255
									end
									
								if (error_counter_0 == locator_degree_0)
									err_loc_derivativative = q_sigma_derivative_0;
								else if(error_counter_1 == locator_degree_1)
									err_loc_derivativative = q_sigma_derivative_1;
								else //if(error_counter_2 == locator_degree_2)	
									err_loc_derivativative = q_sigma_derivative_2;
									
								if (output_cycle>8'd6)
									corrected_cw_ready = 1'b1;
								if(gf_table_ready==1'b1)
									begin
										gf_multiplier(alpha_inverse,q_omega,cw_error);
											if(q_sigma==8'd0)
												corrected_cw = q ^ cw_error;
											else if(q_sigma!=8'd0)
												corrected_cw = q;
									end
							end
						if (decoder_output_cycle > 9'd260)
							chien_search_done=1'b1;
					end//end else
			end//end of start_chien_alg
	
/** If the syndrome==0, the codeword is error free therefore Chien search algorithm is noe executed**/
/** Codeword in the FIFO is correct as is **/	
		if (deactivate_chien_serach==1'b1 || decoder_fail_flag == 1'b1)//cw is error free or decoder failed
			begin
				rden_delay_buffer = 1'b1;//rden
				rdaddress = symbol_cycle;
				symbol_cycle = symbol_cycle + 1;
				corrected_cw = q;
				if(symbol_cycle > 256)rden_delay_buffer = 1'b0;
			end
		
	end
end

assign error_location_0 = sigma_0;//q_sigma_0;
assign error_location_1 = sigma_1;//sigma_2;q_sigma_1;
assign error_location_2 = sigma_2;//q_sigma_0;
assign derivative_error_location = alpha_inverse;//sigma_derivative;
assign error_magnitude = q_omega;
assign corrected_cword_ready = gf_table_ready;//corrected_cw_ready;
assign corrected_error_count = error_counter_0;
assign cycle = decoder_output_cycle;//clock_cycle;
assign chien_regs_initialized = chien_regs_initialized_0;

endmodule
	