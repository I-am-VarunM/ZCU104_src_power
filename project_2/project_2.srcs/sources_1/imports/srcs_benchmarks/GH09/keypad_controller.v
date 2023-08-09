`timescale 1ns / 1ps
`include "parameters.v"

module keypad_controller(
	clk, 
	reset, 
	gpio_pins_in, 
	keypad_controller_out, 
	row_mask, 
	column_mask, 
	control_register, 
	ready, 
	interrupt, 
	fifo_out,
	fifo_wen);

input clk;
input reset;

/* gpio pins in */
input [`GPIO_PINS-1:0]gpio_pins_in;
/* what the keypad controller will send out in terms of signals */
output [`GPIO_PINS-1:0]keypad_controller_out;
wire [`GPIO_PINS-1:0]keypad_controller_out;

// the masks for which pins do what
input [`GPIO_PINS-1:0]row_mask;
input [`GPIO_PINS-1:0]column_mask;

// control register for which pins are what in the keypad
input [`GPIO_PINS-1:0]control_register;

// the signal that tells the keypad controller to start
input ready;

// the pin we send interrupts on for 1 cycle ... the gpio then decides which interrupt to send
output interrupt;
reg interrupt;

// direct access to writing of value register in reg file
output [`REG_WIDTH-1:0]fifo_out;
reg [`REG_WIDTH-1:0]fifo_out;
output fifo_wen;
reg fifo_wen;

// pins that are supposed to be active as polling pins
wire [`GPIO_PINS-1:0]active_poll_pins;
// counters as we go through the polling
reg [3:0]row_counter;
reg [3:0]column_counter;

// records the changes and compares against the current signal.  last
// keypress is for storing a keypress before polling
reg [`GPIO_PINS-1:0]last_in_value;
reg [`GPIO_PINS-1:0]last_keypress;
wire [`GPIO_PINS-1:0]change;
wire [`REG_WIDTH-1:0]in_value;

parameter STATE_SIZE=6;
parameter RESET =				6'b000001,
			IDLE =			6'b000010,
			CHANGE = 		6'b000100,
			POLL_NEXT_COLUMN =	6'b001000,
			POLL_NEXT_ROWS = 	6'b010000,
			DONE_POLL = 		6'b100000;
			
reg [STATE_SIZE-1:0]state;
reg [STATE_SIZE-1:0]next_state;

// depending on counter returns an active vector for polling
turn_on_poll_pins topp({1'b0, column_counter}, active_poll_pins);

// mask in the reads that and the reads that should be interrupted
assign /*in_value*/in_value = gpio_pins_in & row_mask;
// bitwise xor to see if there is a change
assign change = in_value ^ last_in_value;
//      		          the non-keypad value   the collumn output pins masked
assign keypad_controller_out = (active_poll_pins & (column_mask & ~row_mask)); 

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		interrupt <= 1'b0;
		fifo_wen <= 1'b0;
		column_counter <= 0; // set to value the number of columns
		last_keypress <= 0;
		fifo_out <= 0;
	end
	else
	begin
		case (state)
			IDLE:
			begin
				interrupt <= 1'b0;
				column_counter <= 0; // set to value the number of columns
			end
			CHANGE:
			begin
				last_keypress <= in_value; // record the keypress so we can restore last_in_value after polling keypad
				column_counter <= control_register[3:0]; // start at the number of rows since those low pins (rows) are for reading
				row_counter <= 0; // set to value of the number of rows
			end
			POLL_NEXT_COLUMN:
			begin
				// increase the counter to set a different pin
				column_counter <= column_counter + 1; // this increase will also change the polling output pin
				row_counter <= 0;
				fifo_wen <= 1'b0;
			end
			POLL_NEXT_ROWS:
			begin
				row_counter <= row_counter + 1;
				if (in_value[row_counter] != 0)
				begin
					/* if there is a value then we've found a keypress so write to the fifo */
					fifo_wen <= 1'b1;
					fifo_out <= {column_counter-control_register[6:4],row_counter};
				end
				else
				begin
					fifo_wen <= 1'b0;
					fifo_out <= 0;
				end
			end
			DONE_POLL:
			begin
				/* after a poll send an interrupt */
				interrupt <= 1'b1;
				/* turn off the fifo wren just in case it was on */
				fifo_wen <= 1'b0;
			end
		endcase
	end
end

/* Combinational state machine */
always @(state or ready or change or column_counter or row_counter)
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
			if (ready == 1'b0)
			begin
				next_state = RESET;
			end
			else if (change != 0)
			begin
				next_state = CHANGE;
			end
			else
			begin
				next_state = IDLE;
			end
		end
		CHANGE:
		begin
			if (ready == 1'b0)
			begin
				next_state = RESET;
			end
			else 
			begin
				next_state = POLL_NEXT_COLUMN;
			end
		end
		POLL_NEXT_COLUMN:
		begin
			if (ready == 1'b0)
			begin
				next_state = RESET;
			end
			else if (column_counter == control_register[6:4]+control_register[6:4])
			begin
				next_state = DONE_POLL;
			end
			else
			begin
				next_state = POLL_NEXT_ROWS;
			end
		end
		POLL_NEXT_ROWS:
		begin
			if (ready == 1'b0)
			begin
				next_state = RESET;
			end
			else if (row_counter == control_register[3:0]-1)
			begin
				next_state = POLL_NEXT_COLUMN;
			end
			else
			begin
				next_state = POLL_NEXT_ROWS;
			end
		end
		DONE_POLL:
		begin
			if (ready == 1'b0)
			begin
				next_state = RESET;
			end
			else
			begin
				next_state = IDLE;
			end
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
		last_in_value <= in_value;
	end
	else
	begin
		state <= next_state;
		// keep a record so we can figure out changes
		if (state == IDLE)
		begin
			// update the last in_value with the last keypress
			last_in_value <= last_keypress;
		end
		else
		begin
			/* otherwise record old state to check for changes */
			last_in_value <= in_value;
		end
	end
end

endmodule
