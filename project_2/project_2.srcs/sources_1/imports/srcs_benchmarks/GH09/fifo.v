`timescale 1ns / 1ps
`include "parameters.v"

module fifo (
	clk, 
	reset, 
	input_data, 
	wen, 
	ren, 
	output_data, 
	empty, 
	full);

input clk;
input reset;
input [`REG_WIDTH-1:0]input_data;
input ren;
input wen;
output [`REG_WIDTH-1:0]output_data;
reg [`REG_WIDTH-1:0]output_data;
output empty;
reg empty;
output full;
reg full;

// Defines sizes in terms of bits.
parameter MAX_COUNT = 4'b1111;	// FIFO cap.  This is 16 mem spots.

// The FIFO pointers.
reg [`FIFO_BIT_SIZE-1:0]tail;
reg [`FIFO_BIT_SIZE-1:0]head;
reg [`FIFO_BIT_SIZE-1:0]count;

// The actual memory
reg [`REG_WIDTH:0]fifo_memory[0:MAX_COUNT];

// outputdata is registered and gets the value that tail points to RIGHT NOW.  The
// head points to the last read.  Because of overflow the head and tail
// autowrap.
always @(posedge clk) 
begin
	if (reset == 1'b1) begin
		output_data <= 16'h0000;
		head <= 0;
		tail <= 0;
		count <= 0;
		full <= 0;
		empty <= 0;
	end
	else 
	begin
		// the output
		output_data <= fifo_memory[tail];
	
		// the input write
		if (wen == 1'b1 && full == 1'b0) 
		begin
			fifo_memory[head] <= input_data;
			// move the head down
	        	head <= head + 1;
		end
	
		// moving the tail on a read
	      	if (ren == 1'b1 && empty == 1'b0) begin
	       		// READ               
			tail <= tail + 1;
		end
	
		// what to do under different read write scenarios
		case ({ren, wen})
			2'b00: 
			begin
				count <= count;
			end
			2'b01: 
			begin
				// WRITE
				if (count != MAX_COUNT) 
				begin
					count <= count + 1;
				end
	      			empty <= 1'b0;
			end
			2'b10: 
			begin
				// READ
				if (count != 2'b00)
				begin
					count <= count - 1;
				end
	      			empty <= 1'b0;
			end
			2'b11:
			begin
				// Concurrent read and write.. no change in count
				count <= count;
	      			empty <= 1'b0;
			end
		endcase
	
		// full and empty signals
	   	if (count == MAX_COUNT)
		begin
			full <= 1'b1;
		end
		else if (count == 0)
		begin
			empty <= 1'b1;
		end
		else
		begin
			full <= 1'b0;
		end
	end
end 
     
endmodule
