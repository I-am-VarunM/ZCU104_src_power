`timescale 1ns / 1ps
`include "parameters.v"

module io_expander(
	clk,
	reset,
	SCLK,
	SI,
	SO,
	SS,
	INT,
	gpio_pins);

input clk;
input reset;

/* SPI pins */
input SCLK;
input SI;
input SS;
output SO;
wire SO;

/* the general purpose io pins */
inout [`GPIO_PINS-1:0]gpio_pins;

/* interrupt signal */
output INT;
wire INT;

/* access wires to the register file */
wire [`REG_WIDTH-1:0] read;
wire [`REG_WIDTH-1:0] write;
wire [`ADDRESS_WIDTH-1:0] address_regfile;
wire [`ADDRESS_WIDTH-1:0] address_gpio;
wire [`ADDRESS_WIDTH-1:0] address_spi;
wire wen;

/* bit to tell the device when it has all the registers properly programmed
* and can operate */
wire ready_bit;

/* bit to tell if there is a new programming of the chip and we need to
* reset the keypad and gpio control structures */
reg spi_write_int;
/* a bit that tells the gpio when it can operate */
reg gpio_ready;

/* wires for direct access of the value register in the register file */
wire [`REG_WIDTH-1:0] value_register_in;
wire [`REG_WIDTH-1:0] value_register_out;
wire value_wen;

/* fifo access pins.  Keypad writes, SPI reads on address 5 */
wire fifo_ren;
wire [`REG_WIDTH-1:0]fifo_out;
wire fifo_empty;
wire fifo_wen;
wire [`REG_WIDTH-1:0]fifo_in;
wire fifo_full;

parameter STATE_SIZE=4;
parameter RESET =			4'b0001,
			IDLE =	 	4'b0010;
reg [STATE_SIZE-1:0]state;
reg [STATE_SIZE-1:0]next_state;
			
/* Register file:
* 0 Control Register
* 1 Interrupt Register A * 2 Interrupt Register B
* 2 Direction Register A * 4 Direction Register B
* 3 Value Register A * 6 Value Register B
* 4 Interrupt Type Register // Not used in this design
* 5 FIFO head */
register_file regfile(
	.clk(clk),
	.reset(reset),
	.out(read),
	.in(write),
	.address(address_regfile),
	.wen(wen),
	.value_register_in(value_register_out),
	.value_register_out(value_register_in),
	.value_wen(value_wen),
	.ready_bit(ready_bit));

spi_interface spi(
	.clk(clk),
	.reset(reset),
	.SCLK(SCLK),
	.SI(SI),
	.SO(SO),
	.SS(SS),
	.read(read), 
	.write(write), 
	.address(address_spi), 
	.wen(wen),
	.fifo_top_entry(fifo_out),
	.fifo_ren(fifo_ren),
	.fifo_empty(fifo_empty));

gpio_port gp(
	.clk(clk), 
	.reset(reset), 
	.gpio_pins(gpio_pins), 
	.INT(INT), 
	.spi_write_int(spi_write_int), 
	.ready(gpio_ready), 
	.read(read), 
	.address(address_gpio), 
	.value_register_input(value_register_in), 
	.value_register_output(value_register_out), 
	.value_wen(value_wen),
	.fifo_write(fifo_in),
	.fifo_wen(fifo_wen));

fifo fifo_for_keypresses (
	.clk(clk), 
	.reset(reset), 
	.input_data(fifo_in), 
	.wen(fifo_wen), 
	.ren(fifo_ren), 
	.output_data(fifo_out), 
	.empty(fifo_empty), 
	.full(fifo_full));

/* another poor way of accessing memory.  If both try to access at the same
* time we'll have trouble */
assign address_regfile = address_spi | address_gpio;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		gpio_ready <= 1'b0;
	end
	else
	begin
		case (state)
			IDLE:
			begin
				gpio_ready <= 1'b1;
			end
		endcase

	end
end

/* Combinational state machine */
always @(state or ready_bit)
begin
	next_state = 0;
	case (state)
		RESET:
		begin
			if (ready_bit == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = RESET;
			end
		end
		IDLE:
		begin
			next_state = IDLE;
		end
		default: 
		begin
			next_state = RESET;
		end
	endcase
end

/* sequential state changes */
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		state <= RESET;
		next_state <= RESET;
	end
	else
	begin
		state <= next_state;
	end
end

endmodule
