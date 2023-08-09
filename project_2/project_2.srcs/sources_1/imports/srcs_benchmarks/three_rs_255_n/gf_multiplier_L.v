//define galois field multiplier
module gf_multiplier_L (a,b,L_out,clock,polynomial_compute,GF2_multiply_done,coef_ready_flag,reset);//L, leading_Q, 
						//disable_coef_L_ready,disable_GF2_multiply);

input [7:0] a,b;//L, leading_Q;//
input clock,polynomial_compute,coef_ready_flag,reset;//disable_GF2_multiply;
output [7:0] L_out; //reg L_out;//y
output GF2_multiply_done;//disable_coef_L_ready;

reg[23:0] c;
reg [7:0] y,level2_latch;//a,b,
reg y_done;//test

always @(posedge clock && a or b)//L or leading_Q)//multiplication matrix
begin
if(reset==1'b1) GF2_multiply_done<=1'b0; else begin
GF2_multiply_done=1'b0;
y_done=1'b0;//test
if(polynomial_compute==1'b1 && coef_ready_flag==1'b1)
begin
y_done=1'b0;//TEMPORARY
GF2_multiply_done=1'b0;

//a= L; b=leading_Q;//TEST
/*TEMPORARY
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
/*temporary change
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
L_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^((a[3]^a[7])&b[5])^((a[2]^a[6]^a[7])&b[6])^((a[1]^a[5]^a[6]^a[7])&b[7]);
L_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^((a[3]^a[7])&b[6])^((a[2]^a[6]^a[7])&b[7]);
L_out[2]=(a[2]&b[0])^((a[1]^a[7])&b[1])^((a[0]^a[6])&b[2])^((a[5]^a[7])&b[3])^((a[6]^a[4])&b[4])^((a[5]^a[7]^a[3])&b[5])^((a[2]^a[6]^a[7]^a[4])&b[6])^((a[3]^a[5]^a[6]^a[1])&b[7]);
L_out[3]=(a[3]&b[0])^((a[2]^a[7])&b[1])^((a[1]^a[7]^a[6])&b[2])^((a[0]^a[6]^a[5])&b[3])^((a[5]^a[7]^a[4])&b[4])^((a[6]^a[4]^a[3]^a[7])&b[5])^((a[3]^a[5]^a[6]^a[2])&b[6])^((a[1]^a[2]^a[4]^a[5])&b[7]);
L_out[4]=(a[4]&b[0])^((a[3]^a[7])&b[1])^((a[2]^a[6]^a[7])&b[2])^((a[1]^a[5]^a[6]^a[7])&b[3])^((a[0]^a[4]^a[5]^a[6])&b[4])^((a[3]^a[4]^a[5])&b[5])^((a[2]^a[3]^a[4])&b[6])^((a[1]^a[2]^a[3]^a[7])&b[7]);
L_out[5]=(a[5]&b[0])^(a[4]&b[1])^((a[3]^a[7])&b[2])^((a[2]^a[6]^a[7])&b[3])^((a[1]^a[5]^a[6]^a[7])&b[4])^((a[0]^a[4]^a[5]^a[6])&b[5])^((a[3]^a[4]^a[5])&b[6])^((a[2]^a[3]^a[4])&b[7]);
L_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^((a[3]^a[7])&b[3])^((a[2]^a[6]^a[7])&b[4])^((a[1]^a[5]^a[6]^a[7])&b[5])^((a[0]^a[4]^a[5]^a[6])&b[6])^((a[3]^a[4]^a[5])&b[7]);
L_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^((a[3]^a[7])&b[4])^((a[2]^a[6]^a[7])&b[5])^((a[1]^a[5]^a[6]^a[7])&b[6])^((a[0]^a[4]^a[5]^a[6])&b[7]);

y_done = 1'b1;
if(y_done == 1'b1)GF2_multiply_done=y_done;else GF2_multiply_done=1'b0;
end
else GF2_multiply_done=1'b0;
end
end

/*TEMPORARY
assign L_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^(c[21]&b[5])^(c[3]&b[6])^(c[2]&b[7]);
assign L_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^(c[21]&b[6])^(c[3]&b[7]);
assign L_out[2]=(a[2]&b[0])^(c[15]&b[1])^(c[16]&b[2])^(c[17]&b[3])^(c[18]&b[4])^(c[19]&b[5])^(c[20]&b[6])^(c[22]&b[7]);
assign L_out[3]=(a[3]&b[0])^(c[14]&b[1])^(c[13]&b[2])^(c[12]&b[3])^(c[11]&b[4])^(c[10]&b[5])^(c[9]&b[6])^(c[8]&b[7]);
assign L_out[4]=(a[4]&b[0])^(c[0]&b[1])^(c[3]&b[2])^(c[2]&b[3])^(c[4]&b[4])^(c[5]&b[5])^(c[6]&b[6])^(c[7]&b[7]);
assign L_out[5]=(a[5]&b[0])^(a[4]&b[1])^(c[0]&b[2])^(c[3]&b[3])^(c[2]&b[4])^(c[4]&b[5])^(c[5]&b[6])^(c[6]&b[7]);
assign L_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^(c[0]&b[3])^(c[3]&b[4])^(c[2]&b[5])^(c[4]&b[6])^(c[5]&b[7]);
assign L_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^(c[0]&b[4])^(c[3]&b[5])^(c[2]&b[6])^(c[4]&b[7]);
*/
/*
always @(posedge clock)
begin
GF2_multiply_done=0;
if(y_done==1'b1)
GF2_multiply_done=1;//y_done^level2_latch[0]^level2_latch[1]^level2_latch[2]^level2_latch[3];//^level2_latch[4];
end
*/
endmodule
//endmodule