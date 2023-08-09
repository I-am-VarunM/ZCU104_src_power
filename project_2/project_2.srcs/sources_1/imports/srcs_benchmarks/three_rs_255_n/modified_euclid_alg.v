/*Errata Polynomials Generator*/
module modified_euclid_alg(
						clock,
						reset,
						no_of_parity,
						no_of_erasure_coefs,
						erasure_polyn_compute_done,
						modified_syndr_polyn_compute_done,
						locator_polyn,
						magnitue_polyn,
						erasure_polyn,
						modified_syndr_polyn,
						unmodified_syndr_polyn,
						load_erasure_coef_done,
						load_modified_syndr_coef_done,
						load_unmodified_syndr_coef_done,
						send_erasure_polyn,
						send_syndr_polyn,
						send_unmodified_syndr_polyn,
						erasure_coef_ready,
						syndr_coef_ready,
						unmodified_syndrome_ready,
						MEA_compute_done,
						reg_initialization_complete,
						MEA_iteration,
						reg_init,
						state_case,
						R_degree,leading_R,
						Q_degree,leading_Q,
						L_degree,
						//U,R,Q,L,
						polynomial_compute,
						coef_ready_flag,
						send_magnitude_errata_coefs,send_loc_errata_coefs,
						locator_degree,
						errata_magnitude_coefs,errata_loc_coefs,
						errata_magnitude_coef_ready,errata_loc_coef_ready,
						erase_coef_addr,modified_syndr_coef_addr,unmodified_syndr_coef_addr,	
						errata_loc_addr,errata_magnitude_addr,
						//deactivate_chien_serach,
						erasures_absent,
						chien_regs_initialized,
						wren,rden,wraddress_shifted,wraddress,rdaddress,
						wren_polyn,rden_polyn,
						rdaddress_Q,rdaddress_R,rdaddress_L,rdaddress_U,
						L_dpram_addr,U_dpram_addr,Q_dpram_addr,R_dpram_addr
						//m_counter,test_Q,test_R,test_L,test_U
						);
						
parameter width = 5;
parameter number_of_coefs = 16;
							
input clock,reset,erasure_polyn_compute_done,modified_syndr_polyn_compute_done;
input erasure_coef_ready,syndr_coef_ready,unmodified_syndrome_ready;
input send_magnitude_errata_coefs,send_loc_errata_coefs;
input erasures_absent;//when the recieved codeword has no erasure flags asserted
input chien_regs_initialized;
input[width-1:0] no_of_erasure_coefs,no_of_parity;
input [width-1:0] erase_coef_addr,modified_syndr_coef_addr,unmodified_syndr_coef_addr;	
input[7:0] modified_syndr_polyn,erasure_polyn,unmodified_syndr_polyn;

output [7:0] magnitue_polyn,locator_polyn;
output [7:0] leading_Q,leading_R;
output reg [7:0] errata_magnitude_coefs,errata_loc_coefs;
output [2:0] state_case;
output [width-1:0] R_degree,Q_degree,L_degree;
output [width-1:0] locator_degree; reg [width-1:0] locator_degree;
output reg [width-1:0] errata_loc_addr,errata_magnitude_addr;
output reg errata_magnitude_coef_ready,errata_loc_coef_ready;//load_chien_regs,
output reg load_erasure_coef_done,load_modified_syndr_coef_done,load_unmodified_syndr_coef_done;
output reg send_erasure_polyn,send_syndr_polyn,send_unmodified_syndr_polyn;
output reg reg_initialization_complete,MEA_iteration,reg_init,MEA_compute_done;
output reg polynomial_compute,coef_ready_flag;
output reg wren,rden;
output reg [width-1:0] wraddress_shifted,wraddress,rdaddress;
output reg wren_polyn,rden_polyn;
output reg [width-1:0] L_dpram_addr,U_dpram_addr,Q_dpram_addr,R_dpram_addr;
output reg [width-1:0] rdaddress_Q,rdaddress_R,rdaddress_L,rdaddress_U;

wire [7:0] R_out,Q_out,L_out,U_out;
wire [7:0] R_polyn_out,Q_polyn_out,L_polyn_out,U_polyn_out;

`include "shared_multiply.h"

reg [7:0] erasure_polyn_U,mod_syndr_polyn_Q,magnitude_polyn_R,locator_polyn_L;
reg [7:0] leading_coef_R, leading_coef_Q;
reg [2:0] state,dpram_read_delay;
reg [width-1:0] degree_L,degree_R,degree_Q,degree_shift,shifted_coef;
reg [width-1:0] multiplier_counter,no_of_mea_iterations,clear_mem;
reg [width-1:0] errata_loc_addr_to_chien,errata_magnitude_addr_to_chien;
reg max_mea_iterations_reached;//,error_free_cw,error_free_codeword
reg syndr_and_erasure_polyn_output,magnitude_and_locator_polyn_output;
reg [7:0] in_R,in_Q,in_L,in_U;
reg swap_signal;
reg [7:0] U_least_coef;//,zero_coef;
reg [width-1:0] U_least_coef_addr;//;
integer i,j,k,l;

Q_buffer		buffer0(
							.wraddress		(wraddress_shifted),
							.wren			(wren),
							.data			(in_Q),
							.rden			(rden),
							.rdaddress		(rdaddress),
							.clock			(clock),
							.q				(Q_out)
							);

R_buffer		buffer1(
							.wraddress		(wraddress),
							.wren			(wren),
							.data			(in_R),
							.rden			(rden),
							.rdaddress		(rdaddress),
							.clock			(clock),
							.q				(R_out)  
							);
							
L_buffer		buffer2(
							.wraddress		(wraddress),
							.wren			(wren),
							.data			(in_L),
							.rden			(rden),
							.rdaddress		(rdaddress),
							.clock			(clock),
							.q				(L_out)  
							);														
U_buffer		buffer3(
							.wraddress		(wraddress_shifted),
							.wren			(wren),
							.data			(in_U),
							.rden			(rden),
							.rdaddress		(rdaddress),
							.clock			(clock),
							.q				(U_out)  
							);											
Q_Polynomial		Dpram0(
							.wraddress		(Q_dpram_addr),
							.wren			(wren_polyn),
							.data			(mod_syndr_polyn_Q),
							.rden			(rden_polyn),
							.rdaddress		(rdaddress_Q),
							.clock			(clock),
							.q				(Q_polyn_out)
							);

R_Polynomial		Dpram1(
							.wraddress		(R_dpram_addr),
							.wren			(wren_polyn),
							.data			(magnitude_polyn_R),
							.rden			(rden_polyn),
							.rdaddress		(rdaddress_R),
							.clock			(clock),
							.q				(R_polyn_out)  
							);
							
L_Polynomial		Dpram2(
							.wraddress		(L_dpram_addr),
							.wren			(wren_polyn),
							.data			(locator_polyn_L),
							.rden			(rden_polyn),
							.rdaddress		(rdaddress_L),
							.clock			(clock),
							.q				(L_polyn_out)  
							);														
U_Polynomial		Dpram3(
							.wraddress		(U_dpram_addr),
							.wren			(wren_polyn),
							.data			(erasure_polyn_U),
							.rden			(rden_polyn),
							.rdaddress		(rdaddress_U),
							.clock			(clock),
							.q				(U_polyn_out)  
							);					
/*****Handshaking for the transfer the coefficints of erasure polynomial****/
always @(posedge clock)
begin
if(reset==1'b1)load_erasure_coef_done=1'b0;
else begin
	if((erasure_polyn_compute_done==1'b1)&&(erase_coef_addr < no_of_erasure_coefs))
		begin
		send_erasure_polyn=1'b1;
		end
	else if(erase_coef_addr >= no_of_erasure_coefs)
		begin
		send_erasure_polyn=1'b0;
		end
	if(erase_coef_addr > no_of_erasure_coefs)load_erasure_coef_done=1'b1;
	end
end

/*****Handshaking for the transfer coefficients of either:***********************/
/*1. Modified syndrome polynomial if there are erasures
  2. Unmodified (Default)syndrome polynomial if there are no erasures
*/

always @(posedge clock)
begin
if(reset==1'b1)
	begin
	load_modified_syndr_coef_done = 1'b0;
	load_unmodified_syndr_coef_done=1'b0;
	end
else
begin
if((modified_syndr_polyn_compute_done==1'b1)&&( modified_syndr_coef_addr< no_of_parity))
	begin
	send_syndr_polyn=1'b1;
	end
else if((modified_syndr_polyn_compute_done==1'b1)&&(modified_syndr_coef_addr >= no_of_parity))
	begin
	send_syndr_polyn=1'b0;
	load_modified_syndr_coef_done = 1'b1;
	end
if((erasures_absent==1'b1)&&(unmodified_syndr_coef_addr < no_of_parity))
	begin
	send_unmodified_syndr_polyn=1'b1;
	end
else if((erasures_absent==1'b1)&&(unmodified_syndr_coef_addr >= no_of_parity))
	begin
	send_unmodified_syndr_polyn=1'b0;
	load_unmodified_syndr_coef_done = 1'b1;
	end

end
end


always @(posedge clock)
begin
if(reset==1'b1)
	begin
	reg_init =1'b0;
	//deactivate_chien_serach =1'b0;
	MEA_iteration = 1'b0;
	end
else
begin
	if(reg_initialization_complete == 1'b1)
		begin
		MEA_iteration = 1'b1;
		reg_init =1'b1;
		polynomial_compute = 1'b1;
		end
	else if(MEA_compute_done==1'b1)
		begin
		reg_init =1'b1;
		MEA_iteration = 1'b0;
		polynomial_compute = 1'b0;
		end
	//else if(error_free_cw==1'b1)deactivate_chien_serach=1'b1;
end
end

/*Generation of the key polynomials using Modified Euclidean Algorithm (MEA):
			1. Errors-&-erasures location polynomial --> errata_loc_coefs
			2. Errors-&-erasures magnitude polynomial --> errata_magnitude_coefs
 Computation registers U, Q, R and L are initialized as follows:
	U(x) = erasure polynomial(if erasures present) OR 1 (if erasures absent);
	Q(x) = modified syndrome polynoial (if erasures present) OR unmodified syndrome polynomial (if erasures absent);
	R(x) = x^(number of parity)
	L(x) = 0; 
*/
always @( posedge clock)
begin
if(reset==1'b1)
	begin
	coef_ready_flag <= 1'b0;
	multiplier_counter<=0;
	//error_free_codeword=1'b0;
	//error_free_cw=1'b0;
	max_mea_iterations_reached=1'b0;
	syndr_and_erasure_polyn_output <= 1'b0;
	magnitude_and_locator_polyn_output <= 1'b0;
	wren = 1'b0;
	rden = 1'b0;
	wraddress_shifted = 0;
	wraddress = 0;
	rdaddress =0;
	swap_signal = 0;
	U_least_coef <= 1;
	U_least_coef_addr <= 0;
	magnitude_polyn_R = 8'd0;
	wren_polyn = 1'b1;
	rden_polyn = 1'b0;
	MEA_compute_done=1'b0;
	errata_magnitude_coef_ready =1'b0;
	errata_loc_coef_ready =1'b0;
	end
else begin
if(erasure_coef_ready==1'b1)//loading the coefficients of erasures polynomial
begin
	U_dpram_addr = erase_coef_addr;
	erasure_polyn_U = erasure_polyn;
end

if(syndr_coef_ready==1'b1 && modified_syndr_coef_addr < no_of_parity)//loading the coefficients of modified syndrome polynomial
begin	
	if(modified_syndr_coef_addr == no_of_parity-1 || modified_syndr_coef_addr == no_of_parity)
		begin R_dpram_addr = no_of_parity; magnitude_polyn_R = 8'd1;end
	else magnitude_polyn_R = 8'd0;
	Q_dpram_addr = modified_syndr_coef_addr;
	mod_syndr_polyn_Q = modified_syndr_polyn;
end
else if(unmodified_syndrome_ready==1'b1)//loading syndromes if the codeword has no erasures
begin
	if(unmodified_syndr_coef_addr == no_of_parity-1 || unmodified_syndr_coef_addr == no_of_parity)
		begin R_dpram_addr = no_of_parity; magnitude_polyn_R = 8'd1;end
	else magnitude_polyn_R = 8'd0;
	U_dpram_addr = U_least_coef_addr;
	erasure_polyn_U = U_least_coef;
	Q_dpram_addr = unmodified_syndr_coef_addr;
	mod_syndr_polyn_Q = unmodified_syndr_polyn;
end

if(((load_modified_syndr_coef_done==1'b1 && load_erasure_coef_done==1'b1)||(load_unmodified_syndr_coef_done==1'b1))&&(reg_init ==1'b0))
begin	
		degree_R<=no_of_parity;
		degree_Q<=no_of_parity-8'd1;
		degree_L<= 0;
		no_of_mea_iterations<=no_of_erasure_coefs;
		reg_initialization_complete <= 1'b1;
		rden_polyn <= 1'b1;
		wren_polyn = 1'b0;
		
end
else begin  reg_initialization_complete <= 1'b0; end

if(chien_regs_initialized==1'b1)
	begin
	magnitude_and_locator_polyn_output <= 1'b0;
	syndr_and_erasure_polyn_output <= 1'b0;
	end

/*Modified Euclidean Algorithm (MEA) is an iterative algorithm. States 0-6 are performed 
until the stop condition (degree_R<degree_L ) is met, then the algorithm extis at State 3 outputting:
			1. errata_loc_coefs = L(x)
			2. errata_magnitude_coefs = R(x)
			3. Locator deree = degree of L(x) -->expected number of erroneous bytes in the codeword
The maximum number of iterations  = number of parity bytes. If max iterations is reached and 
stop condition isn't met, exit at State 3 anyway.
*/	

if (MEA_iteration == 1'b1)
	begin
		case(state)
		0:	begin
				rdaddress_Q <= degree_Q;
				rdaddress_R <= degree_R;
				rdaddress_L <= degree_L;
				rdaddress_U <= degree_R;//ADDED
				L_dpram_addr <= {width{1'b1}};
				U_dpram_addr <= {width{1'b1}};
				Q_dpram_addr <= {width{1'b1}};
				R_dpram_addr <= {width{1'b1}};			
				state <=1;
			end

		1:	begin
					if(L_polyn_out==8'd0 && degree_L!=0)
						begin 
							rdaddress_L <= rdaddress_L - 1; //8'd Update degree of L(x)
							degree_L <= rdaddress_L;
							wraddress_shifted = clear_mem ;
							in_U = 8'd0;
							in_Q = 8'd0;
							clear_mem = clear_mem + 1;
							state <=1;
			 			end 
					else begin
						state<=2;
						wren = 0;
						wraddress_shifted = 0;
					end
			end

		2:	begin
					if(Q_polyn_out==8'd0 && degree_Q!=1)//8'd
			 			begin 
							rdaddress_Q <= rdaddress_Q - 1;
							degree_Q <= rdaddress_Q; 
				 			state<=2;
			 			end 
					else begin
						state <= 3;
						leading_coef_Q <= Q_polyn_out;
					end
			end
		3:	begin
					if(R_polyn_out==8'd0 && degree_R!=0)//8'd
			 			begin
							rdaddress_R <= rdaddress_R - 1;
							degree_R <= rdaddress_R;
			   				state <=3;
			 			end 
					else begin
						state<=4;
						leading_coef_R <= R_polyn_out;
					end 
			end
		4:						 
			if(degree_R<degree_L || max_mea_iterations_reached ==1'b1)//stop_signal==1'b1 therefore output the magnitude and locator polynomial
				begin
					rdaddress_R <= 0;
					rdaddress_L <= 0;
					magnitude_and_locator_polyn_output <= 1'b1;
					MEA_compute_done<=1'b1;
					locator_degree <= degree_L;
				end 
			else if(no_of_erasure_coefs > degree_Q)//erasure generator has captured all errors
				begin
					rdaddress_U <= 0;
					rdaddress_Q <= 0;
					syndr_and_erasure_polyn_output <= 1'b1;
					MEA_compute_done<=1'b1;
					locator_degree <= no_of_erasure_coefs;
				end
			//else if(error_free_codeword==1'b1) error_free_cw =1'b1;//codeword contains no errors
			else state<=5;
					
		5:	
			if(degree_R>=degree_L)//stop_signal==1'b0
				begin
					MEA_compute_done= 1'b0;	
					if(degree_R < degree_Q)//swap before computation
						begin
							swap_signal = 1;
							degree_shift = degree_Q - degree_R;
						end 			
					else if(degree_R >= degree_Q)//no swap just go ahead with computation of L(X) and R(X);  Q(x) and U(X) remain same
 						begin
							swap_signal = 0;
							degree_shift = degree_R - degree_Q;
						end	
					state<=6;
 				end//end of degree_R>=degree_L loop	
		
		6:				
			if (polynomial_compute == 1'b1)
				begin
					rdaddress_Q <= multiplier_counter;
					rdaddress_U <= multiplier_counter;
					rdaddress_R <= multiplier_counter;
					rdaddress_L <= multiplier_counter;
					if (multiplier_counter >= 1)
						begin
							wren <= 1'b1; //write enable multiply buffers
							wren_polyn = 1'b1;//write enable coef mems
						end
					if (multiplier_counter >=2)
						begin
							if(swap_signal == 1'b1)
								begin
									gf_multiplier(leading_coef_R,Q_polyn_out,in_R);					
									gf_multiplier(leading_coef_R,U_polyn_out,in_L);																			
									gf_multiplier(leading_coef_Q,R_polyn_out,in_Q);					
									gf_multiplier(leading_coef_Q,L_polyn_out,in_U);	
								
									Q_dpram_addr <= multiplier_counter - 2;
									U_dpram_addr <= multiplier_counter - 2;
									mod_syndr_polyn_Q <= R_polyn_out;
									erasure_polyn_U <= L_polyn_out;
								end
								else begin
									gf_multiplier(leading_coef_Q,R_polyn_out,in_R);					
									gf_multiplier(leading_coef_Q,L_polyn_out,in_L);					
									gf_multiplier(leading_coef_R,Q_polyn_out,in_Q);					
									gf_multiplier(leading_coef_R,U_polyn_out,in_U);					
								end
							wraddress_shifted <= degree_shift + (multiplier_counter-2);
							wraddress <= multiplier_counter-2;
							rden <= 1'b1;//rd enable mult buffers
						end 
					multiplier_counter = multiplier_counter + 1;
					if (multiplier_counter >=4)//gf_mult o/p available
						begin
							rdaddress <= multiplier_counter - 4;	//rd multipl buffers
						end
					if (multiplier_counter >= 6)
						begin
							R_dpram_addr <= multiplier_counter - 6;
							L_dpram_addr <= multiplier_counter - 6;
							magnitude_polyn_R <= Q_out^R_out;
							locator_polyn_L <= L_out^U_out;
						end
					if (multiplier_counter == number_of_coefs + 7) state<=7;//6'd39

					end//end of polynomial_compute = 1'b1	
		7:
						begin
							no_of_mea_iterations <= no_of_mea_iterations + 1;
							if(no_of_mea_iterations>no_of_parity)
								begin 
									state<=4;
									max_mea_iterations_reached =1'b1;
								end
							degree_Q <= no_of_parity;
							degree_R <= no_of_parity;
							degree_L <= no_of_parity;
							rden = 1'b0;
							wren_polyn = 1'b0;
							wraddress_shifted = 0;
							wraddress = 0;
							multiplier_counter =6'd0;
							swap_signal <= 0;
							state<=0;
						end		

		endcase

	end//MEA_iteration = 1'b1
	
/****Sending out the coefficients of errata (errors-&-erasure) magnitude polynomial -->omega(x)*****/

if(send_magnitude_errata_coefs==1'b1)
	begin
		if(magnitude_and_locator_polyn_output == 1'b1)
			begin
				rdaddress_R <= errata_magnitude_addr_to_chien +1;
				errata_magnitude_coefs <= R_polyn_out;
				
				if(rdaddress_R>=1)errata_magnitude_addr = errata_magnitude_addr_to_chien-1;
				errata_magnitude_addr_to_chien = errata_magnitude_addr_to_chien + 1;
				errata_magnitude_coef_ready=1'b1;
			end
		else if (syndr_and_erasure_polyn_output == 1'b1)
			begin
				rdaddress_Q <= errata_magnitude_addr_to_chien +1;
				errata_magnitude_coefs <= Q_polyn_out;
				
				if(rdaddress_Q>=1)errata_magnitude_addr = errata_magnitude_addr_to_chien-1;
				errata_magnitude_addr_to_chien = errata_magnitude_addr_to_chien + 1;
				errata_magnitude_coef_ready=1'b1;
			end
	end
	else if(send_magnitude_errata_coefs==1'b0)errata_magnitude_coef_ready=1'b0;

/****Sending out the coefficients of errata (errors-&-erasure) locator polynomial--> psi(x)*****/

if(send_loc_errata_coefs==1'b1)
	begin
		if(magnitude_and_locator_polyn_output == 1'b1)
			begin
			rdaddress_L <= errata_loc_addr_to_chien+1;
			errata_loc_coefs <= L_polyn_out;
			
			if(rdaddress_L>=1)errata_loc_addr = errata_loc_addr_to_chien-1;
			errata_loc_addr_to_chien = errata_loc_addr_to_chien + 1;
			errata_loc_coef_ready=1'b1;
			end
		else if(syndr_and_erasure_polyn_output == 1'b1)
			begin
			rdaddress_U <= errata_loc_addr_to_chien+1;
			errata_loc_coefs <= U_polyn_out;
			
			if(rdaddress_U >= 1)errata_loc_addr = errata_loc_addr_to_chien-1;
			errata_loc_addr_to_chien = errata_loc_addr_to_chien + 1;
			errata_loc_coef_ready=1'b1;			
			end
	end
	else if(send_loc_errata_coefs==1'b0)errata_loc_coef_ready=1'b0;
end
end

//assign locator_degree = locator_degree;
assign magnitue_polyn = magnitude_polyn_R;
assign locator_polyn = locator_polyn_L;
assign state_case = state;
assign R_degree = degree_R;
assign Q_degree = degree_Q;	
assign L_degree = degree_L;
endmodule
