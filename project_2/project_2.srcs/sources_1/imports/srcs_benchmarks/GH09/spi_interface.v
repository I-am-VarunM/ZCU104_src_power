`timescale 1ns / 1ps
`include "parameters.v"

module spi_interface(
	clk,
	reset,
	SCLK,
	SI,
	SO,
	SS,
	read, 
	write, 
	address, 
	wen,
	fifo_top_entry,
	fifo_ren,
	fifo_empty);

input clk;
input reset;

/* access to the register file */
input [`REG_WIDTH-1:0] read;
output [`REG_WIDTH-1:0] write;
output [`ADDRESS_WIDTH-1:0] address;
reg [`ADDRESS_WIDTH-1:0] address;
output wen;
reg wen;
wire [`REG_WIDTH-1:0] write;

/* the SPI pins */
input SCLK;
input SI;
output SO;
reg SO;
input SS;

/* counters to count SCLK and packets */
reg [4:0]clock_counter;
reg [1:0]packets;

/* the actual read register */
reg [15:0]spi_read_register;

/* the fifo read port */
input [`REG_WIDTH-1:0] fifo_top_entry;
output fifo_ren;
reg fifo_ren;
input fifo_empty;

parameter STATE_SIZE=11;
parameter IDLE = 									11'b00000000001,//001
			INPUT_READ = 							11'b00000000010,//002
			INPUT_READ_CLOCK_HIGH_COUNT = 	11'b00000000100,//004
			INPUT_READ_CLOCK_HIGH = 			11'b00000001000,//008
			INPUT_READ_CLOCK_LOW_SAMPLE = 	11'b00000010000,//010
			INPUT_READ_CLOCK_LOW = 				11'b00000100000,//020
			OUTPUT_READ_CLOCK_HIGH_COUNT = 	11'b00100000000,//100
			OUTPUT_READ_CLOCK_HIGH = 			11'b01000000000,//200
			OUTPUT_READ_CLOCK_LOW =			 	11'b10000000000;//400
			
reg [STATE_SIZE-1:0]state;
reg [STATE_SIZE-1:0]next_state;

/* the write always goes out */
assign write = spi_read_register;

/* output logic */
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		clock_counter <= 0;
		SO <= 1'bx;
		spi_read_register <= 0;
		packets <= 0;
		fifo_ren <= 1'b0;
	end
	else
	begin
		case (state)
			IDLE:
			begin
				wen <= 1'b0;
				SO <= 1'bx;
				spi_read_register <= 0;
				packets <= 0;
				fifo_ren <= 1'b0;
			end
			INPUT_READ:	
			begin
				// in read mode reset the clock counter
				clock_counter <= 0;
			end
			INPUT_READ_CLOCK_HIGH_COUNT:
			begin
				// found high bit so count next clock
				clock_counter <= clock_counter + 1;
			end
			INPUT_READ_CLOCK_HIGH:
			begin
			end
			INPUT_READ_CLOCK_LOW_SAMPLE:
			begin
				// record the value in the spi_read_register
				spi_read_register[clock_counter-1] <= SI;
			end
			INPUT_READ_CLOCK_LOW:
			begin
				if ((((clock_counter == 8) && (packets == 0)) || ((clock_counter == 16) && (packets == 1))) && (SS == 1'b0))
				begin
					if ((spi_read_register[0] == 1'b1) && (packets == 0)) // read 16 bits
					begin
						address <= spi_read_register[4:1];
						spi_read_register <= 0;
						wen <= 1'b0;
						clock_counter <= 0;
						packets <= packets + 1;
					end
					else // 0 = write
					begin
						clock_counter <= 0;
						if (packets == 0)
						begin
							// set up the writing 
							address <= spi_read_register[4:1];
							spi_read_register <= 0;
							packets <= packets + 1;
						end
						else
						begin
							// write the second read value
							wen <= 1'b1;
						end
					end
				end
			end
			OUTPUT_READ_CLOCK_HIGH_COUNT:
			begin
				// read is actaully an output since the
				// external world wants to read a register
				//
				// count the clocks
				clock_counter <= clock_counter + 1;
			end
			OUTPUT_READ_CLOCK_HIGH:
			begin
				if (address == 5) // if we're reading from the fifo of keypresses
				begin
					if (fifo_empty == 1'b0)
					begin
						SO <= fifo_top_entry[clock_counter-1];
					end
					else
					begin
						SO <= 0;
					end
				end
				else
				begin
					// sendout the read register form the file
					SO <= read[clock_counter-1];
				end
			end
			OUTPUT_READ_CLOCK_LOW:
			begin
				if ((clock_counter == 16) && (SS == 1'b0))
				begin
					// if we count the last bit
					if (address == 5) // if we're reading from the fifo of keypresses
					begin
						if (fifo_empty == 1'b0)
						begin
							fifo_ren <= 1'b1; // move the fifo to the next item
						end
					end
				end
			end
			default:
			begin
			end
		endcase
	end
end

/* Combinational state machine */
always @(state or SCLK or SS or clock_counter or spi_read_register or packets)
begin
	next_state = 0;
	case (state)
		IDLE:
		begin
			if ((SCLK == 1'b1) && (SS == 1'b0)) // SS is active low
			begin
				next_state = INPUT_READ;
			end
			else
			begin
				next_state = IDLE;
			end
		end
		INPUT_READ:
		begin
			if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = INPUT_READ_CLOCK_HIGH_COUNT;
			end
		end
		INPUT_READ_CLOCK_HIGH_COUNT:
		begin
			// Waiting for clock to go low so we can read bit and count bits read
			if ((SCLK == 1'b0) && (SS == 1'b0))
			begin
				next_state = INPUT_READ_CLOCK_LOW_SAMPLE;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = INPUT_READ_CLOCK_HIGH;
			end
		end
		INPUT_READ_CLOCK_HIGH:
		begin
			// Waiting for clock to go low so we can read bit and count bits read
			if ((SCLK == 1'b0) && (SS == 1'b0))
			begin
				next_state = INPUT_READ_CLOCK_LOW_SAMPLE;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = INPUT_READ_CLOCK_HIGH;
			end
		end
		INPUT_READ_CLOCK_LOW_SAMPLE:
		begin
			// Waiting for clock to go high
			if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = INPUT_READ_CLOCK_LOW;
			end
		end
		INPUT_READ_CLOCK_LOW:
		begin
			// Waiting for clock to go high
			if ((((clock_counter == 8) && (packets == 0)) ||  ((clock_counter == 16) && (packets == 1))) && (SS == 1'b0))
			begin
				if ((spi_read_register[0] == 1'b1) && (packets == 0)) // read
				begin
					next_state = OUTPUT_READ_CLOCK_LOW;
				end
				else if (packets == 0) // 0 = write
				begin
					next_state = INPUT_READ;
				end
				else 
				begin
					next_state = IDLE;
				end
			end
			else if ((SCLK == 1'b1) && (SS == 1'b0))
			begin
				next_state = INPUT_READ_CLOCK_HIGH_COUNT;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = INPUT_READ_CLOCK_LOW;
			end
		end
		OUTPUT_READ_CLOCK_HIGH_COUNT:
		begin
			// Waiting for clock to go low so we can read bit and count bits read
			if ((SCLK == 1'b0) && (SS == 1'b0))
			begin
				next_state = OUTPUT_READ_CLOCK_LOW;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = OUTPUT_READ_CLOCK_HIGH;
			end
		end
		OUTPUT_READ_CLOCK_HIGH:
		begin
			// Waiting for clock to go low so we can read bit and count bits read
			if ((SCLK == 1'b0) && (SS == 1'b0))
			begin
				next_state = OUTPUT_READ_CLOCK_LOW;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = OUTPUT_READ_CLOCK_HIGH;
			end
		end
		OUTPUT_READ_CLOCK_LOW:
		begin
			// Waiting for clock to go high
			if ((clock_counter == 16) && (SS == 1'b0))
			begin
				next_state = IDLE;
			end
			else if ((SCLK == 1'b1) && (SS == 1'b0))
			begin
				next_state = OUTPUT_READ_CLOCK_HIGH_COUNT;
			end
			else if (SS == 1'b1)
			begin
				next_state = IDLE;
			end
			else
			begin
				next_state = OUTPUT_READ_CLOCK_LOW;
			end
		end
		default: 
		begin
			next_state = IDLE;
		end
	endcase
end

/* sequential state changes */
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		state <= IDLE;
		next_state <= IDLE;
	end
	else
	begin
		state <= next_state;
	end
end

endmodule
