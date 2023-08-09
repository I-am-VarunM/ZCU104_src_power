`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 09:25:49 PM
// Design Name: 
// Module Name: Simulated_Load_IP_Core
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



module Simulated_Load_IP_Core(
    input  [31:0] en,
    input clk,
    output [31:0] out_load
    );
    

    parameter NUM_OF_COARSE_MODULES = 9;
    parameter NUM_OF_FINE_MODULES = 9;
    parameter SIZE_PER_COARSE_MODULE = 1000;
    parameter SIZE_PER_FINE_MODULE = 100;
    localparam NUM_OF_MODULES = NUM_OF_COARSE_MODULES + NUM_OF_FINE_MODULES;
    
    //wire [NUM_OF_MODULES:0] output_xor;
    reg [NUM_OF_MODULES:0] output_xor;
    //reg[NUM_OF_COARSE_MODULES:0] out_load = 0;
    
    wire rst = 1;
    wire [31:0]out;
    switch_elements u0(en, clk, rst, out);
    assign out_load = out;
    
    //assign out_load = output_xor[NUM_OF_MODULES];

endmodule

