delay_buffer	delay_buffer_inst (
	.data ( data_sig ),
	.wren ( wren_sig ),
	.wraddress ( wraddress_sig ),
	.rdaddress ( rdaddress_sig ),
	.rden ( rden_sig ),
	.clock ( clock_sig ),
	.q ( q_sig )
	);
