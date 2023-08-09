`timescale 1ns / 1ps
`include "parameters.v"

module register_file(clk, reset, out, in, address, wen, value_register_in, value_register_out, value_wen, ready_bit);

/* Register file:
* 0 Control Register
* 1 Interrupt Register A * 2 Interrupt Register B
* 2 Direction Register A * 4 Direction Register B
* 3 Value Register A * 6 Value Register B
* 4 Interrupt Type Register  
* 5 is fifo head, but not part of register file */

input clk;
input reset;
output [`REG_WIDTH-1:0] out;
wire [`REG_WIDTH-1:0] out;	
input [`REG_WIDTH-1:0] in;
input [`ADDRESS_WIDTH-1:0] address;
input wen;

/* specialised direct connections so other parts of the circuit can
* directly access the value register */
input [`REG_WIDTH-1:0] value_register_in;
input value_wen;
output [`REG_WIDTH-1:0] value_register_out;
wire [`REG_WIDTH-1:0] value_register_out;

/* special bit that is set in register when all the data is in from the
* control register to setup the device operation */
output ready_bit;
wire ready_bit;

/* register file */
reg [`REG_WIDTH-1:0] registers [`REG_SIZE-1:0];

/* always send out address 3 */
assign value_register_out = registers[3];
/* link to the ready bit in the control register */
assign ready_bit = registers[0][8];
/* the output of the register file */
assign out = registers[address];

always @(posedge clk or posedge reset) 
begin 
	if (reset == 1'b1) 
	begin
	end
	else
	begin
		if (wen == 1'b1) 
		begin
			registers[address] <= in;
		end

		if (value_wen == 1'b1)
		begin
			registers[3] <= value_register_in;
		end
	end
end 

endmodule 


