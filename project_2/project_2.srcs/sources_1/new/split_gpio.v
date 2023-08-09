`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2020 02:02:28 PM
// Design Name: 
// Module Name: split_gpio
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


module split_gpio(
    input [1:0] in_en,
    output out0,
    output out1
    );

    assign out0 = in_en[0];
    assign out1 = in_en[1];
    
endmodule
