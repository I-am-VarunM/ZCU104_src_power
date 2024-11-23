# FPGA-based Measurement Setup

This repository contains the implementation of a measurement setup on an FPGA using Vivado and Vitis SDE. The setup includes various functionalities such as load generation, PWM generation, sensor data acquisition, and communication with a PC via UART.

## FPGA Implementation (Vivado)

The FPGA implementation is done using Vivado 2019.1. The project file can be loaded into Vivado for further exploration and modifications. The main components of the FPGA implementation are:

1. **PS Zynq Ultrascale+ MPSoC block**: Configures I/O, clock, DDR, and PS-PL interface.
2. **AXI interconnect block**: Provides inter-block communication.
3. **System management wizard**: Configures SYSMON modules for on-chip sensor readout.
4. **AXI GPIO blocks**: Interfaces with on-board buttons, LEDs, DIP switches, and the PS.
5. **Load generators**: Implements ring oscillators (ROs) for measurement load and additional workload.
6. **PWM generator**: Generates PWM signal to control fan speed.
7. **External ambient temperature sensor**: Connects to the Pmod TMP2 via I2C.

The load generators are implemented using LUTs realizing NAND gates, and their outputs are connected to XOR gates. The measurement load generator consists of 2500 ROs for EMA detection and 25000 ROs for power attack detection. The additional load generator is made up of 15 load generators with 1000 ROs each and 9 load generators with 100 ROs each.

The PWM generator has a resolution of 8 bits, a switching frequency of 32 Hz, and a system clock of 100 MHz. The duty cycle is controlled by an 8-bit signal from the PS via an AXI GPIO pin.

## Software Implementation (Vitis SDE)

The software implementation is done using Vitis SDE. The PS is responsible for accessing sensor data from the System Monitor device, preprocessing the data, and sending it via UART. It also receives triggering commands from the PC via UART using interrupts to control the additional load, measurement load, and PWM duty cycle.

The main components of the software implementation are:

1. **UART driver**: Communicates with the PC via UART.
2. **Interrupt handler**: Handles interrupts for receiving messages from the PC via UART.
3. **Timer**: Generates timestamps for messages sent to the PC.
4. **System Monitor device**: Reads out on-chip sensors using ADCs in both PS and PL blocks.
5. **I2C driver**: Communicates with the external ambient temperature sensor via I2C.

The measurement routine continuously polls temperature and voltage data from the System Monitor device and sends it via UART. Triggering commands received via UART interrupt can control the duty cycle, additional load, measurement load, and pause/continue/stop the measurement routine.

## Usage

1. Open Vivado 2019.1 and load the project file.
2. Explore and modify the FPGA implementation as needed.
3. Open Vitis SDE and load the software project.
4. Configure the necessary settings and parameters.
5. Build and run the software project on the FPGA.

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
