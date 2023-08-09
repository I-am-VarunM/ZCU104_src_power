//define galois field multiplier
module gf_multiplier_forney (a,b,GF_out,clock,GF_multiply_done,coef_ready_flag,reset);
input [7:0] a,b;
input clock,coef_ready_flag,reset;
output reg [7:0] GF_out;
output reg GF_multiply_done;

always @(posedge clock && a or b)//multiplication matrix
begin
if(reset==1'b1)GF_multiply_done<=1'b0;else begin
GF_multiply_done=1'b0;
if(coef_ready_flag==1'b1)
begin
GF_multiply_done=1'b0;

GF_out[0]=(a[0]&b[0])^(a[7]&b[1])^(a[6]&b[2])^(a[5]&b[3])^(a[4]&b[4])^((a[3]^a[7])&b[5])^((a[2]^a[6]^a[7])&b[6])^((a[1]^a[5]^a[6]^a[7])&b[7]);
GF_out[1]=(a[1]&b[0])^(a[0]&b[1])^(a[7]&b[2])^(a[6]&b[3])^(a[5]&b[4])^(a[4]&b[5])^((a[3]^a[7])&b[6])^((a[2]^a[6]^a[7])&b[7]);
GF_out[2]=(a[2]&b[0])^((a[1]^a[7])&b[1])^((a[0]^a[6])&b[2])^((a[5]^a[7])&b[3])^((a[6]^a[4])&b[4])^((a[5]^a[7]^a[3])&b[5])^((a[2]^a[6]^a[7]^a[4])&b[6])^((a[3]^a[5]^a[6]^a[1])&b[7]);
GF_out[3]=(a[3]&b[0])^((a[2]^a[7])&b[1])^((a[1]^a[7]^a[6])&b[2])^((a[0]^a[6]^a[5])&b[3])^((a[5]^a[7]^a[4])&b[4])^((a[6]^a[4]^a[3]^a[7])&b[5])^((a[3]^a[5]^a[6]^a[2])&b[6])^((a[1]^a[2]^a[4]^a[5])&b[7]);
GF_out[4]=(a[4]&b[0])^((a[3]^a[7])&b[1])^((a[2]^a[6]^a[7])&b[2])^((a[1]^a[5]^a[6]^a[7])&b[3])^((a[0]^a[4]^a[5]^a[6])&b[4])^((a[3]^a[4]^a[5])&b[5])^((a[2]^a[3]^a[4])&b[6])^((a[1]^a[2]^a[3]^a[7])&b[7]);
GF_out[5]=(a[5]&b[0])^(a[4]&b[1])^((a[3]^a[7])&b[2])^((a[2]^a[6]^a[7])&b[3])^((a[1]^a[5]^a[6]^a[7])&b[4])^((a[0]^a[4]^a[5]^a[6])&b[5])^((a[3]^a[4]^a[5])&b[6])^((a[2]^a[3]^a[4])&b[7]);
GF_out[6]=(a[6]&b[0])^(a[5]&b[1])^(a[4]&b[2])^((a[3]^a[7])&b[3])^((a[2]^a[6]^a[7])&b[4])^((a[1]^a[5]^a[6]^a[7])&b[5])^((a[0]^a[4]^a[5]^a[6])&b[6])^((a[3]^a[4]^a[5])&b[7]);
GF_out[7]=(a[7]&b[0])^(a[6]&b[1])^(a[5]&b[2])^(a[4]&b[3])^((a[3]^a[7])&b[4])^((a[2]^a[6]^a[7])&b[5])^((a[1]^a[5]^a[6]^a[7])&b[6])^((a[0]^a[4]^a[5]^a[6])&b[7]);

GF_multiply_done=1'b1;
end
else GF_multiply_done=1'b0;
end
end

endmodule
