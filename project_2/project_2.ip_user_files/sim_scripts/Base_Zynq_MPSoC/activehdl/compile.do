vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_5
vlib activehdl/zynq_ultra_ps_e_vip_v1_0_5
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/interrupt_control_v3_1_4
vlib activehdl/axi_gpio_v2_0_21
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_register_slice_v2_1_19
vlib activehdl/fifo_generator_v13_2_4
vlib activehdl/axi_data_fifo_v2_1_18
vlib activehdl/axi_crossbar_v2_1_20
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/axi_protocol_converter_v2_1_19
vlib activehdl/axi_clock_converter_v2_1_18
vlib activehdl/blk_mem_gen_v8_4_3
vlib activehdl/axi_dwidth_converter_v2_1_19

vmap xilinx_vip activehdl/xilinx_vip
vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_5 activehdl/axi_vip_v1_1_5
vmap zynq_ultra_ps_e_vip_v1_0_5 activehdl/zynq_ultra_ps_e_vip_v1_0_5
vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap interrupt_control_v3_1_4 activehdl/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_21 activehdl/axi_gpio_v2_0_21
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_19 activehdl/axi_register_slice_v2_1_19
vmap fifo_generator_v13_2_4 activehdl/fifo_generator_v13_2_4
vmap axi_data_fifo_v2_1_18 activehdl/axi_data_fifo_v2_1_18
vmap axi_crossbar_v2_1_20 activehdl/axi_crossbar_v2_1_20
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap axi_protocol_converter_v2_1_19 activehdl/axi_protocol_converter_v2_1_19
vmap axi_clock_converter_v2_1_18 activehdl/axi_clock_converter_v2_1_18
vmap blk_mem_gen_v8_4_3 activehdl/blk_mem_gen_v8_4_3
vmap axi_dwidth_converter_v2_1_19 activehdl/axi_dwidth_converter_v2_1_19

vlog -work xilinx_vip  -sv2k12 "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_5  -sv2k12 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/d4a8/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_5  -sv2k12 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0_vip_wrapper.v" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work interrupt_control_v3_1_4 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_21 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/9c6e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_axi_gpio_0_0/sim/Base_Zynq_MPSoC_axi_gpio_0_0.vhd" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_19  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/4d88/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_4  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/1f5a/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_4 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_4  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_18  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/5b9c/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_20  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ace7/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_xbar_0/sim/Base_Zynq_MPSoC_xbar_0.v" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_rst_ps8_0_100M_0/sim/Base_Zynq_MPSoC_rst_ps8_0_100M_0.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_conv_funs_pkg.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/common_types_pkg.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_proc_common_pkg.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_ipif_pkg.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_family_support.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_family.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_soft_reset.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_pselect_f.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/axi_lite_ipif_v1_31_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_address_decoder.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/axi_lite_ipif_v1_31_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_slave_attachment.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/interrupt_control_v2_01_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_interrupt_control.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/axi_lite_ipif_v1_31_a/hdl/src/vhdl/Base_Zynq_MPSoC_system_management_wiz_0_0_axi_lite_ipif.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/Base_Zynq_MPSoC_system_management_wiz_0_0_xadc_core_drp.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/Base_Zynq_MPSoC_system_management_wiz_0_0_axi_xadc.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_system_management_wiz_0_0/Base_Zynq_MPSoC_system_management_wiz_0_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_axi_gpio_1_0/sim/Base_Zynq_MPSoC_axi_gpio_1_0.vhd" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_axi_gpio_2_0/sim/Base_Zynq_MPSoC_axi_gpio_2_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_Simulated_Load_IP_Co_0_0/sim/Base_Zynq_MPSoC_Simulated_Load_IP_Co_0_0.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_pwm_0_1/sim/Base_Zynq_MPSoC_pwm_0_1.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_Measurement_Load_0_1/sim/Base_Zynq_MPSoC_Measurement_Load_0_1.v" \
"../../../bd/Base_Zynq_MPSoC/sim/Base_Zynq_MPSoC.v" \

vlog -work axi_protocol_converter_v2_1_19  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/c83a/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work axi_clock_converter_v2_1_18  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ac9d/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work blk_mem_gen_v8_4_3  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/c001/simulation/blk_mem_gen_v8_4.v" \

vlog -work axi_dwidth_converter_v2_1_19  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/e578/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/ec67/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ipshared/cac7/hdl" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+../../../../project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_ds_0/sim/Base_Zynq_MPSoC_auto_ds_0.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_pc_0/sim/Base_Zynq_MPSoC_auto_pc_0.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_ds_1/sim/Base_Zynq_MPSoC_auto_ds_1.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_pc_1/sim/Base_Zynq_MPSoC_auto_pc_1.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_ds_2/sim/Base_Zynq_MPSoC_auto_ds_2.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_pc_2/sim/Base_Zynq_MPSoC_auto_pc_2.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_ds_3/sim/Base_Zynq_MPSoC_auto_ds_3.v" \
"../../../bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_auto_pc_3/sim/Base_Zynq_MPSoC_auto_pc_3.v" \

vlog -work xil_defaultlib \
"glbl.v"

