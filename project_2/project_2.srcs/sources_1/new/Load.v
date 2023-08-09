`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2019 06:09:41 PM
// Design Name: 
// Module Name: Load
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


module Load(
    input en,
    input clk,
    output out_load
    );

    parameter NUM_OF_MODULES = 9;
    parameter RO_SIZE = 1;
    
    wire [NUM_OF_MODULES:0] outputs_ro;
    //reg [NUM_OF_MODULES:0] outputs_ro_reg;
    reg[NUM_OF_MODULES:0] output_xor = 0;
    wire rst = ~en;
    
    genvar i;
    generate
        for (i = 0; i< NUM_OF_MODULES; i=i+1) begin
            RO #(RO_SIZE) RO_inst(.en(en), .out_ro(outputs_ro[i]));
            //outputs_ro_reg[i] = outputs_ro[i];
        end
    endgenerate
    
    generate
        for (i=1; i<NUM_OF_MODULES; i=i+1) begin 
            always @(posedge clk or posedge rst) begin
                if(rst)
                        output_xor[i] <= 0;
                else
                    output_xor[i] <= outputs_ro[i-1] ^ output_xor[i-1];
            end
        end
        always @(posedge clk or posedge rst) begin
            if(rst)
                output_xor[0] <= 0;
            else
                output_xor[0] <= outputs_ro[NUM_OF_MODULES-1] ^ output_xor[NUM_OF_MODULES-1];
        end
    endgenerate
    
    assign out_load = output_xor[NUM_OF_MODULES];

endmodule