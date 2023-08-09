//define galois field multiplier
module gf_multiplier_R (a,b,R_out,clock,polynomial_compute,GF1_multiply_done,coef_ready_flag,reset);//R, leading_Q, 
						//disable_coef_R_ready,disable_GF1_multiply);

input [7:0] a,b;//R, leading_Q;//
input clock,polynomial_compute,coef_ready_flag,reset;//disable_GF1_multiply;
//inout coef_ready_flag;
output [7:0] R_out;//reg R_out;//y
output GF1_multiply_done;//disable_coef_R_ready;

reg[23:0] c;
reg [7:0] y,level2_latch;//a,b,
reg y_done;

always @(posedge clock && a or b)//R or leading_Q)//multiplication matrix
begin
if(reset==1'b1)GF1_multiply_done<=1'b0;
else begin
GF1_multiply_done=1'b0;
y_done=1'b0;
if(polynomial_compute==1'b1 && coef_ready_flag==1'b1)
begin
y_done=1'b0;//TEMPORARY
//coef_ready_flag=1'b0;
GF1_multiply_done=1'b0;
//disable_coef_R_ready=1'b0;

//a= R; b=leading_Q;///TEST
//disable_coef_R_ready=1'b1;
/*
c[0]=a[3]^a[7];
c[1]=a[1]^a[2];
c[2]=a[1]^a[5]^a[6]^a[7];
c[3]=a[2]^a[6]^a[7];
c[4]=a[0]^a[4]^a[5]^a[6];
c[5]=a[3]^a[4]^a[5];
c[6]=a[2]^a[3]^a[4];

c[14]=a[2]^a[7];
c[15]=a[1]^a[7];
c[16]=a[0]^a[6];
c[17]=a[5]^a[7];
c[18]=a[6]^a[4];
c[21]=a[3]^a[7];

c[23]=a[3]^a[5]^a[6];
*/

/*
c[19]=c[17]^a[3];
c[20]=c[3]^a[4];
c[22]=c[23]^a[1];
c[13]=c[15]^a[6];
c[12]=c[16]^a[5];
c[11]=c[17]^a[4];
c[10]=c[18]^c[0];
c[9]=c[23]^a[2];
c[8]=c[1]^a[4]^a[5];
c[7]=c[1]^c[21];
*/
/*TEMPORARY
c[19]=a[5]^a[7]^a[3];//c[19]=c[17]^a[3];
c[20]=a[2]^a[6]^a[7]^a[4];//c[20]=c[3]^a[4];
c[22]=a[3]^a[5]^a[6]^a[1];//c[22]=c[23]^a[1];
c[13]=a[1]^a[7]^a[6];//c[13]=c[15]^a[6];
c[12]=a[0]^a[6]^a[5];//c[12]=c[16]^a[5];
c[11]=a[5]^a[7]^a[4];//c[11]=c[17]^a[4];
c[10]=a[6]^a[4]^a[3]^a[7];//c[10]=c[18]^c[0];
c[9]=a[3]^a[5]^a[6]^a[2];//c[9]=c[23]^a[2];
c[8]=a[1]^a[2]^a[4]^a[5];//c[8]=c[1]^a[4]^a[5];
c[7]=a[1]^a[2]^a[3]^a[7];//c[7]=c[1]^c[21];
*/
/*
R_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^(c[21]&b[5])^(c[3]&b[6])^(c[2]&b[7]);
R_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^(c[21]&b[6])^(c[3]&b[7]);
R_out[2]=(a[2]&b[0])^(c[15]&b[1])^(c[16]&b[2])^(c[17]&b[3])^(c[18]&b[4])^(c[19]&b[5])^(c[20]&b[6])^(c[22]&b[7]);
R_out[3]=(a[3]&b[0])^(c[14]&b[1])^(c[13]&b[2])^(c[12]&b[3])^(c[11]&b[4])^(c[10]&b[5])^(c[9]&b[6])^(c[8]&b[7]);
R_out[4]=(a[4]&b[0])^(c[0]&b[1])^(c[3]&b[2])^(c[2]&b[3])^(c[4]&b[4])^(c[5]&b[5])^(c[6]&b[6])^(c[7]&b[7]);
R_out[5]=(a[5]&b[0])^(a[4]&b[1])^(c[0]&b[2])^(c[3]&b[3])^(c[2]&b[4])^(c[4]&b[5])^(c[5]&b[6])^(c[6]&b[7]);
R_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^(c[0]&b[3])^(c[3]&b[4])^(c[2]&b[5])^(c[4]&b[6])^(c[5]&b[7]);
R_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^(c[0]&b[4])^(c[3]&b[5])^(c[2]&b[6])^(c[4]&b[7]);
*/
//R_out = y;
R_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^((a[3]^a[7])&b[5])^((a[2]^a[6]^a[7])&b[6])^((a[1]^a[5]^a[6]^a[7])&b[7]);
R_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^((a[3]^a[7])&b[6])^((a[2]^a[6]^a[7])&b[7]);
R_out[2]=(a[2]&b[0])^((a[1]^a[7])&b[1])^((a[0]^a[6])&b[2])^((a[5]^a[7])&b[3])^((a[6]^a[4])&b[4])^((a[5]^a[7]^a[3])&b[5])^((a[2]^a[6]^a[7]^a[4])&b[6])^((a[3]^a[5]^a[6]^a[1])&b[7]);
R_out[3]=(a[3]&b[0])^((a[2]^a[7])&b[1])^((a[1]^a[7]^a[6])&b[2])^((a[0]^a[6]^a[5])&b[3])^((a[5]^a[7]^a[4])&b[4])^((a[6]^a[4]^a[3]^a[7])&b[5])^((a[3]^a[5]^a[6]^a[2])&b[6])^((a[1]^a[2]^a[4]^a[5])&b[7]);
R_out[4]=(a[4]&b[0])^((a[3]^a[7])&b[1])^((a[2]^a[6]^a[7])&b[2])^((a[1]^a[5]^a[6]^a[7])&b[3])^((a[0]^a[4]^a[5]^a[6])&b[4])^((a[3]^a[4]^a[5])&b[5])^((a[2]^a[3]^a[4])&b[6])^((a[1]^a[2]^a[3]^a[7])&b[7]);
R_out[5]=(a[5]&b[0])^(a[4]&b[1])^((a[3]^a[7])&b[2])^((a[2]^a[6]^a[7])&b[3])^((a[1]^a[5]^a[6]^a[7])&b[4])^((a[0]^a[4]^a[5]^a[6])&b[5])^((a[3]^a[4]^a[5])&b[6])^((a[2]^a[3]^a[4])&b[7]);
R_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^((a[3]^a[7])&b[3])^((a[2]^a[6]^a[7])&b[4])^((a[1]^a[5]^a[6]^a[7])&b[5])^((a[0]^a[4]^a[5]^a[6])&b[6])^((a[3]^a[4]^a[5])&b[7]);
R_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^((a[3]^a[7])&b[4])^((a[2]^a[6]^a[7])&b[5])^((a[1]^a[5]^a[6]^a[7])&b[6])^((a[0]^a[4]^a[5]^a[6])&b[7]);

y_done=1'b1;

GF1_multiply_done=1'b1;//y_done;//
/*
if(y_done==1'b1)
GF1_multiply_done=y_done^level2_latch[0]^level2_latch[1]^level2_latch[2]^level2_latch[3];//^level2_latch[4];
*/
end
else GF1_multiply_done=1'b0;
//if(disable_GF1_multiply==1'b1)GF1_multiply_done=1'b0;

end
end

/*TEMPORARY
assign R_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^(c[21]&b[5])^(c[3]&b[6])^(c[2]&b[7]);
assign R_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^(c[21]&b[6])^(c[3]&b[7]);
assign R_out[2]=(a[2]&b[0])^(c[15]&b[1])^(c[16]&b[2])^(c[17]&b[3])^(c[18]&b[4])^(c[19]&b[5])^(c[20]&b[6])^(c[22]&b[7]);
assign R_out[3]=(a[3]&b[0])^(c[14]&b[1])^(c[13]&b[2])^(c[12]&b[3])^(c[11]&b[4])^(c[10]&b[5])^(c[9]&b[6])^(c[8]&b[7]);
assign R_out[4]=(a[4]&b[0])^(c[0]&b[1])^(c[3]&b[2])^(c[2]&b[3])^(c[4]&b[4])^(c[5]&b[5])^(c[6]&b[6])^(c[7]&b[7]);
assign R_out[5]=(a[5]&b[0])^(a[4]&b[1])^(c[0]&b[2])^(c[3]&b[3])^(c[2]&b[4])^(c[4]&b[5])^(c[5]&b[6])^(c[6]&b[7]);
assign R_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^(c[0]&b[3])^(c[3]&b[4])^(c[2]&b[5])^(c[4]&b[6])^(c[5]&b[7]);
assign R_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^(c[0]&b[4])^(c[3]&b[5])^(c[2]&b[6])^(c[4]&b[7]);
*/
/*
always @(posedge clock)
begin
GF1_multiply_done=0;
if(y_done==1'b1)
GF1_multiply_done=1;//y_done^level2_latch[0]^level2_latch[1]^level2_latch[2]^level2_latch[3];//^level2_latch[4];
end
*/
endmodule
//endmodule