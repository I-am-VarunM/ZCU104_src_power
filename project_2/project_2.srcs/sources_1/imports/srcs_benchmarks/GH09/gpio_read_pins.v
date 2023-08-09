`timescale 1ns / 1ps
`include "parameters.v"

module gpio_read_pins(
	clk, 
	reset, 
	gpio_pins_in, 
	read_mask, 
	interrupt_mask, 
	ready, 
	interrupt, 
	value_register_input, 
	value_register_output, 
	value_wen);

input clk;
input reset;

/* the gpio_pins input is the only things needed to be handled...when they
* change */
input [`GPIO_PINS-1:0]gpio_pins_in;
/* masks for what is to be read and interrupted on */
input [`GPIO_PINS-1:0]read_mask;
input [`GPIO_PINS-1:0]interrupt_mask;
/* signal to indicate when this device can begin normal operation */
input ready;

// the pin we send interrupts on for 1 cycle ... the gpio then decides which interrupt to send
output interrupt;
reg interrupt;

// direct access to writing of value register in reg file
input [`REG_WIDTH-1:0]value_register_input;
output [`REG_WIDTH-1:0]value_register_output;
wire [`REG_WIDTH-1:0]value_register_output;
output value_wen;
reg value_wen;

/* registers and wires to handle logic for changes on these pins */
reg [`GPIO_PINS-1:0]last_in_value;
reg [`GPIO_PINS-1:0]last_in_value_int;
wire [`GPIO_PINS-1:0]in_value;
wire [`GPIO_PINS-1:0]in_value_int;
wire [`GPIO_PINS-1:0]change;
wire [`GPIO_PINS-1:0]change_int;

parameter STATE_SIZE=4;
parameter RESET =			4'b0001,
			IDLE =	 	4'b0010,
			INTERRUPT = 	4'b0100,
			UPDATE = 	4'b1000;
			
reg [STATE_SIZE-1:0]state;
reg [STATE_SIZE-1:0]next_state;

// always have the write going out...needs to be activated with the value_wen
assign value_register_output = (value_register_input & ~read_mask) | (gpio_pins_in & read_mask);
// mask in the reads that and the reads that should be interrupted
assign in_value = gpio_pins_in & read_mask;
assign in_value_int = gpio_pins_in & read_mask & interrupt_mask;
// bitwise xor to see if there is a change
assign change = in_value ^ last_in_value;
assign change_int = in_value_int ^ last_in_value_int;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		interrupt <= 1'b0;
		value_wen <= 1'b0;
	end
	else
	begin
		case (state)
			IDLE:
			begin
				interrupt <= 1'b0;
				value_wen <= 1'b0;
			end
			INTERRUPT:
			begin
				interrupt <= 1'b1; // interrupt since changed on interrupt pin
				value_wen <= 1'b1; // write value since changed
			end
			UPDATE:
			begin
				interrupt <= 1'b0;
				value_wen <= 1'b1; // write value since changed
			end
		endcase

	end
end

/* Combinational state machine */
always @(state or ready or change or change_int)
begin
	next_state = 0;
	case (state)
		RESET:
		begin
			if (ready == 1'b1)
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
			if (change_int != 0)
			begin
				next_state = INTERRUPT;
			end
			else if (change != 0)
			begin
				next_state = UPDATE;
			end
			else
			begin
				next_state = IDLE;
			end
		end
		INTERRUPT:
		begin
			next_state = IDLE;
		end
		UPDATE:
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
		last_in_value_int <= 0;
		last_in_value <= 0;
	end
	else
	begin
		state <= next_state;
		// keep a record so we can figure out changes
		last_in_value_int <= in_value_int;
		last_in_value <= in_value;
	end
end

endmodule
