connect -url tcp:127.0.0.1:3121
source C:/Xilinx/SDK/2019.1/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Xilinx HW-Z1-ZCU104 FT4232H 01553A"} -index 1
loadhw -hw C:/Users/Carina/Documents/ma_ck/zcu104_src_fixed/project_2/project_2.sdk/Base_Zynq_MPSoC_wrapper_hw_platform_1/system.hdf -mem-ranges [list {0x80000000 0xbfffffff} {0x400000000 0x5ffffffff} {0x1000000000 0x7fffffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Xilinx HW-Z1-ZCU104 FT4232H 01553A"} -index 1
source C:/Users/Carina/Documents/ma_ck/zcu104_src_fixed/project_2/project_2.sdk/Base_Zynq_MPSoC_wrapper_hw_platform_1/psu_init.tcl
psu_init
after 1000
psu_ps_pl_isolation_removal
after 1000
psu_ps_pl_reset_config
catch {psu_protection}
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Xilinx HW-Z1-ZCU104 FT4232H 01553A"} -index 1
rst -processor
dow C:/Users/Carina/Documents/ma_ck/zcu104_src_fixed/project_2/project_2.sdk/sysmon/Debug/sysmon.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Xilinx HW-Z1-ZCU104 FT4232H 01553A"} -index 1
con
