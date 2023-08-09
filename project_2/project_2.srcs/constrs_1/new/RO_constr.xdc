set_property DONT_TOUCH true [get_cells -hier *RO_inst]
set_property ALLOW_COMBINATORIAL_LOOPS true [get_nets -hier *out_ro]
#set_property ALLOW_COMBINATORIAL_LOOPS true [get_nets Base_Zynq_MPSoC_i/RO_1/inst/outclk]


set_property PACKAGE_PIN J9 [get_ports {pwm_out_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out_0[0]}]
set_property DRIVE 12 [get_ports {pwm_out_0[0]}]


