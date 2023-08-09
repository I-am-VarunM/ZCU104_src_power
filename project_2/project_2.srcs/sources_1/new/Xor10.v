`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2019 03:54:07 PM
// Design Name: 
// Module Name: Xor10
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


module Xor10(
    input In0,
    input In1,
    input In2,
    input In3,
    input In4,
    input In5,
    input In6,
    input In7,
    input In8,
    input In9,
    input clk,
    output out0
    );
    
    reg out0;
    
    always @ (posedge clk) begin
        out0 <= In0 ^ In1 ^ In2 ^ In3 ^ In4 ^ In5 ^ In6 ^ In7 ^ In8 ^ In9;
    end
endmodule