#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/Software/xilinx/2019.1-sdx/SDK/2019.1/bin:/Software/xilinx/2019.1-sdx/Vivado/2019.1/ids_lite/ISE/bin/lin64:/Software/xilinx/2019.1-sdx/Vivado/2019.1/bin
else
  PATH=/Software/xilinx/2019.1-sdx/SDK/2019.1/bin:/Software/xilinx/2019.1-sdx/Vivado/2019.1/ids_lite/ISE/bin/lin64:/Software/xilinx/2019.1-sdx/Vivado/2019.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/manvar00/Downloads/RELEASE_DVD/vivado_designs/zcu104_src_power/project_2/project_2.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log Base_Zynq_MPSoC_wrapper.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source Base_Zynq_MPSoC_wrapper.tcl
