onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Base_Zynq_MPSoC_opt

do {wave.do}

view wave
view structure
view signals

do {Base_Zynq_MPSoC.udo}

run -all

quit -force
