`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2019 06:49:05 PM
// Design Name: 
// Module Name: RO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
(* DONT_TOUCH = "true" *)
(* ALLOW_COMBINATORIAL_LOOPS = "true" *)
module RO(
    input en,
    output out_ro
    );
    
    //parameter NO_STAGES=3;      // No of inverter stage
    parameter INV_DELAY_ns=2;       // Delay of single inverter in ns
    
   /* wire w0,w1,w2,w3,w4,w5;
    
    and(w0, en,w5);
    not #INV_DELAY_ns(w1,w0);
    not #INV_DELAY_ns(w2,w1);
    not #INV_DELAY_ns(w3,w2);
    not #INV_DELAY_ns(w4,w3);
    not #INV_DELAY_ns(w5,w4);
    assign outclk = w5;*/
    
    //module ringOsc(outclk);
    parameter SIZE = 9; 
    //output outclk;
    wire [SIZE : 0] w;
    and #INV_DELAY_ns andGate(w[0], en,w[SIZE]);
    genvar i;
    generate
        for (i=0; i<SIZE; i=i+1) begin : notGates
            not #INV_DELAY_ns notGate(w[i+1], w[i]);
        end
    endgenerate

    assign out_ro = w[SIZE];

//endmodule
    
endmodule
