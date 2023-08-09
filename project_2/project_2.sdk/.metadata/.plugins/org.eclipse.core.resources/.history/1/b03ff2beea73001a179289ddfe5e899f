/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "sysmon_header.h"
#include "sysmonpsu_header.h"
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xgpiops.h"
#include "scugic_header.h"
#include "xscugic.h"
#include "xsysmonpsu.h"
#include "xsysmon.h"
#include "gpio_header.h"
#include "system_test.h"
#include "xtime_l.h"
#include "uart_header.h"
#include "pmodtmp2.h"
#include <stdlib.h>
#include "sleep.h"
#include "uart_header.h"
#include "classifier\feature_extraction.h"
#include "classifier\mlmodel.h"

//#define RUN_SUBMODULES

//Set global constants
#define CHANNEL_LED 				1
#define CHANNEL_PUSH 				2
#define CHANNEL_DIP 				1
#define CHANNEL_LOAD_IP_CORE_EN 	2
//#define CHANNEL_GPIO_IN_LOAD_OUT 	1
#define CHANNEL_GPIO_OUT_LOAD_EN 	2
#define CHANNEL_GPIO_OUT_DUTY_CYCLE 1
#define BTN_MEAS_PAUSE				0x04
#define BTN_MEAS_STOP				0x08
#define LED_MEAS_PAUSED				0x04
#define LED_MEAS_STOPPED			0x08
#define LED_LOAD_STARTED			0x01
#define LED_CHIP_TAMPERED			0x02
#define MEASUREMENT_BUFFER_SIZE		2000

#define STATUS_LOAD_ON 				0x00
#define STATUS_LOAD_OFF 			0x01
#define STATUS_POLLING_PAUSED 		0x02
#define STATUS_POLLING_CONTINUED 	0x03
#define STATUS_DUTY_CYCLE 			0x04
#define STATUS_CHIP_TAMPERED		0x05
#define STATUS_CHIP_UNTAMPERED		0x06

#define MEASUREMENT_TYPE_AMBIENT_TEMP 	0x00
#define MEASUREMENT_TYPE_PSU_TEMP 		0x01
#define MEASUREMENT_TYPE_PSU_REM_TEMP 	0x02
#define MEASUREMENT_TYPE_PL_TEMP 		0x03
#define MEASUREMENT_TYPE_PSU_VCCINT		0x04
#define MEASUREMENT_TYPE_PSU_VCCAUX 	0x05
#define MEASUREMENT_TYPE_PL_VCCINT 		0x06
#define MEASUREMENT_TYPE_PL_VCCAUX 		0x07

#define AMOUNT_OF_COARSE_MODULES 15
#define AMOUNT_OF_FINE_MODULES 9
#define COARSE_MODULES_BIT_MASK (0xFFFFFFFF >> (32-AMOUNT_OF_COARSE_MODULES))
#define FINE_MODULES_BIT_MASK (0xFFFFFFFF >> (32-AMOUNT_OF_FINE_MODULES))
#define NEW_DUTY_CYCLE_ENABLE_BIT 0x100
#define WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_SEC 10
#define WAIT_TILL_STOPPING_LOAD_TIME_INTERVAL_SEC 30
#define WAIT_TILL_ENDING_MEAS_TIME_INTERVAL_SEC  10
#define WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_MS 10000
#define WAIT_TILL_STOPPING_LOAD_TIME_INTERVAL_MS 30000
#define WAIT_TILL_ENDING_MEAS_TIME_INTERVAL_MS  10000
#define TOTAL_MEAS_TIME_INTERVAL_SEC  (WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_SEC + WAIT_TILL_STOPPING_LOAD_TIME_INTERVAL_SEC + WAIT_TILL_ENDING_MEAS_TIME_INTERVAL_SEC)
#define TOTAL_MEAS_TIME_INTERVAL_MS  (WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_MS + WAIT_TILL_STOPPING_LOAD_TIME_INTERVAL_MS + WAIT_TILL_ENDING_MEAS_TIME_INTERVAL_MS)
//#define TOTAL_MEAS_TIME_INTERVAL_MS 1000

#define SEC_TO_TIMESTAMP_FACTOR  100000000 // 100000000 = 1 sec
#define MS_TO_TIMESTAMP_FACTOR  100000 // 100000000 = 1 sec
#define MEASUREMENT_OFFSET 1000
#define MEASUREMENT_TIME_OFFSET_MS (70)

#define WELCH_COEFF 2


//Helper functions
void sendStatusMsgViaUart(int status, int value);
void adjustIPCoreLoad(XGpio * gpio_handler);
void triggerMeasurementLoad(XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler);
void pollAndSendCurrentMeasruementData();
void pollAndSendMinMaxMeasruementData();
void controlPolling(XGpio * gpio_led_pb_handler, XGpio * gpio_led_handler);
void controlSendingMinMax();
void changeDutyCycle( XGpio * gpio_load_handler);
void sendCurrentMeasurmentViaUart(int measurmenet_type, float value, XTime time);
void sendMinMaxMeasurmentViaUart(int measurmenet_type, float min, float max, XTime time);
void setDutyCycle( XGpio * gpio_load_handler, int value);
void checkForTampering(XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler);
int classify_measurement(int amount_meas_datapoints, double* measurement_buffer);
int runMeasurement(double* measurement_buffer, XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler);

//Initialize global control variables
int dip_or_load_history;
int button1_on_history;
int polling_paused_history;
int checking_for_tampering_started_history;
int checking_for_tampering_started_time;
int button2_on;
int psu_rem_temp_max;
int psu_rem_temp_max_changed;


#ifndef RUN_SUBMODULES

void setup(XGpio* my_gpios_led_pb, XGpio* my_gpios_dip_ipload,
		XGpio* my_gpios_load) {
	XTime_StartTimer();
	//Setup UART Interrupt
	int status = UartPsIntrInitialize(&InterruptController, &UartPs,
			UART_DEVICE_ID, UART_INT_IRQ_ID);
	if (status != XST_SUCCESS) {
		printf("UART Interrupt Example Test Failed\r\n");
		//return XST_FAILURE;
	}
	printf("UART Interrupt Setup Successful\r\n");
	//Setup GPIO Init PL
	XGpio_Initialize(&*my_gpios_led_pb, XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_Initialize(&*my_gpios_dip_ipload, XPAR_AXI_GPIO_1_DEVICE_ID);
	XGpio_Initialize(&*my_gpios_load, XPAR_AXI_GPIO_2_DEVICE_ID);
	//Run GPIO Self Test
	int result = XGpio_SelfTest(&*my_gpios_led_pb);
	if (result != XST_SUCCESS) {
		print("Gpio SelfTest failed!\r");
	}
	result = XGpio_SelfTest(&*my_gpios_dip_ipload);
	if (result != XST_SUCCESS) {
		print("Gpio SelfTest failed!\r");
	}
	result = XGpio_SelfTest(&*my_gpios_load);
	if (result != XST_SUCCESS) {
		print("Gpio SelfTest failed!\r");
	}
	//Setup Ambient Temp Sensor
	result = configurePmodtmp2();
	if (result != XST_SUCCESS) {
		print("Setup Ambient Temp Sensor failed!\r");
	}
	//Set Data Directions
	XGpio_SetDataDirection(&*my_gpios_led_pb, CHANNEL_PUSH, 0xffffffff); //Bits set to 0 are output and bits set to 1 are input.
	XGpio_SetDataDirection(&*my_gpios_led_pb, CHANNEL_LED, 0x0); //Bits set to 0 are output and bits set to 1 are input.
	XGpio_SetDataDirection(&*my_gpios_dip_ipload, CHANNEL_DIP, 0xffffffff); //Bits set to 0 are output and bits set to 1 are input.
	XGpio_SetDataDirection(&*my_gpios_dip_ipload, CHANNEL_LOAD_IP_CORE_EN, 0x0); //Bits set to 0 are output and bits set to 1 are input.
	XGpio_SetDataDirection(&*my_gpios_load, CHANNEL_GPIO_OUT_DUTY_CYCLE, 0x0); //Bits set to 0 are output and bits set to 1 are input.
	XGpio_SetDataDirection(&*my_gpios_load, CHANNEL_GPIO_OUT_LOAD_EN, 0x0); //Bits set to 0 are output and bits set to 1 are input.
	//Setup PWM
	changeDutyCycle(&*my_gpios_load);
	XGpio_DiscreteWrite(&*my_gpios_led_pb, CHANNEL_LED,
			LED_MEAS_STOPPED | LED_MEAS_PAUSED); // Turn on LED1 & LED2
	XGpio_DiscreteWrite(&*my_gpios_led_pb, CHANNEL_GPIO_OUT_LOAD_EN, 0x00); // Disable ro
}

int main()
{
    init_platform();

    //Initialize global variables
	psu_rem_temp_max_changed = 0;
    loadEnabled = 0;
	sendMinMaxEnabled = 0;
	pausePollingEnabled = 0;
	continuePollingEnabled = 0;
	adjustFactorIPCoreLoad = 0;
	adjustFactorDutyCycle = 0;
    checkForTamperingEnabled = 0;
	checking_for_tampering_started_history = 0;
	checking_for_tampering_started_time = 0;
	setValueDutyCycle = -1;

	dip_or_load_history=0;
	button1_on_history = 0;
	polling_paused_history = 0;
	button2_on = 0;
	psu_rem_temp_max = 0;

	XGpio my_gpios_led_pb;
	XGpio my_gpios_dip_ipload;
	XGpio my_gpios_load;

	setup(&my_gpios_led_pb, &my_gpios_dip_ipload, &my_gpios_load);


    //========================================================//
	print("Start System Monitor Readout of Vcc and Temp. Interrupt with any pushbutton...\r\n");


	//System Monitor Readout. Interrupt with pushbutton
	while(button2_on == 0){
		controlPolling(&my_gpios_led_pb, &my_gpios_led_pb );

		controlSendingMinMax();

		triggerMeasurementLoad(&my_gpios_dip_ipload, &my_gpios_load, &my_gpios_led_pb);

		adjustIPCoreLoad(&my_gpios_dip_ipload);

		changeDutyCycle(&my_gpios_load);

		checkForTampering(&my_gpios_dip_ipload, &my_gpios_load, &my_gpios_led_pb);

	}




	pollAndSendMinMaxMeasruementData();
	//SysMonPsuPolledReadMinMax(XPAR_PSU_AMS_DEVICE_ID); //Read min and max value of vcc and temp
	//SysMonPolledReadMinMax(XPAR_SYSMON_0_DEVICE_ID); //Read min and max value of vcc and temp

	XGpio_DiscreteWrite(&my_gpios_led_pb,1, 0x00);// Turn off LED1


    //========================================================//
    print("End of System Monitor Readout\r\n");
    cleanup_platform();
    return 0;
}
#endif

void sendStatusMsgViaUart(int status, int value)
{
	XTime * Xtime = 0;
	char * msg = NULL;
	XTime_GetTime(Xtime);
	printf("Uart msg status %i\n", status);
	switch(status){
		case STATUS_LOAD_ON:
			asiprintf(&msg,"Load started (time: %lu).\n",(*Xtime));
			break;
		case STATUS_LOAD_OFF:
			asiprintf(&msg,"Load stopped (time: %lu).\n",(*Xtime));
			break;
		case STATUS_POLLING_CONTINUED:
			asiprintf(&msg,"Polling continued (time: %lu).\n",(*Xtime));
			break;
		case STATUS_POLLING_PAUSED:
			asiprintf(&msg,"Polling paused (time: %lu).\n",(*Xtime));
			break;
		case STATUS_DUTY_CYCLE:
		{
			int percent = (int)(((float) value)/2.5);
			asiprintf(&msg,"Duty cycle was changed to %i Percent(time: %lu).\n", percent,(*Xtime));
			break;
		}
		case STATUS_CHIP_TAMPERED:
			asiprintf(&msg,"Chip is in a tampered state(time: %lu, exe time: %i ms)!!!\n",(*Xtime), value);
			break;
		case STATUS_CHIP_UNTAMPERED:
			asiprintf(&msg,"Chip is untampered(time: %lu, exe time: %i ms).\n",(*Xtime), value);
			break;
		default:
			asiprintf(&msg,"No status change\n");
	}
	int size_local = strlen(msg);
	sendUart(&UartPs, msg, size_local);
	free(msg);
}

void sendCurrentMeasurmentViaUart(int measurmenet_type, float value, XTime time)
{
	char * msg = NULL;
	switch(measurmenet_type){
		case MEASUREMENT_TYPE_AMBIENT_TEMP:
			asiprintf(&msg,"The Current Ambient Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PSU_TEMP:
			asiprintf(&msg,"The Current PSU Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PSU_REM_TEMP:
			asiprintf(&msg,"The Current PSU Remote Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PL_TEMP:
			asiprintf(&msg,"The Current Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PL_VCCINT:
			asiprintf(&msg,"The Current VCCINT is %0d.%03d Volt (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PL_VCCAUX:
			asiprintf(&msg,"The Current VCCAUX is %0d.%03d Volt (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PSU_VCCINT:
			asiprintf(&msg,"The Current PSU VCCINT is %0d.%03d Volt (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		case MEASUREMENT_TYPE_PSU_VCCAUX:
			asiprintf(&msg,"The Current PSU VCCAUX is %0d.%03d Volt (time: %lu).\n",(int)(value), SysMonPsuFractionToInt(value), time);
			break;
		default:
			asiprintf(&msg,"No status change\n");
	}
	int size_local = strlen(msg);

	//printf("%s", msg);
	sendUart(&UartPs, msg, size_local);
	free(msg);
}

void sendMinMaxMeasurmentViaUart(int measurmenet_type, float min, float max, XTime time)
{
	char * msg = NULL;
	switch(measurmenet_type){
		case MEASUREMENT_TYPE_PSU_TEMP:
			asiprintf(&msg,"The Maximum PSU Temperature is %0d.%03d Centigrades (time: %lu). \n"
						"The Minimum PSU Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PSU_REM_TEMP:
			asiprintf(&msg,"The Maximum PSU Remote Temperature is %0d.%03d Centigrades (time: %lu). \n"
						"The Minimum PSU Remote Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PL_TEMP:
			asiprintf(&msg,"The Maximum Temperature is %0d.%03d Centigrades (time: %lu). \n"
						"The Minimum Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PL_VCCINT:
			asiprintf(&msg,"The Maximum VCCINT is %0d.%03d Voltage (time: %lu). \n"
						"The Minimum VCCINT is %0d.%03d Voltage (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PL_VCCAUX:
			asiprintf(&msg,"The Maximum VCCAUX is %0d.%03d Voltage (time: %lu). \n"
						"The Minimum VCCAUX is %0d.%03d Voltage (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PSU_VCCINT:
			asiprintf(&msg,"The Maximum PSU VCCINT is %0d.%03d Voltage (time: %lu). \n"
						"The Minimum PSU VCCINT is %0d.%03d Voltage (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		case MEASUREMENT_TYPE_PSU_VCCAUX:
			asiprintf(&msg,"The Maximum PSU VCCAUX is %0d.%03d Voltage (time: %lu). \n"
						"The Minimum PSU VCCAUX is %0d.%03d Voltage (time: %lu).\n",(int)(max), SysMonPsuFractionToInt(max), time,
						(int)(min), SysMonPsuFractionToInt(min), time);
			break;
		default:
			asiprintf(&msg,"No status change\n");
	}
	int size_local = strlen(msg);
	sendUart(&UartPs, msg, size_local);
	free(msg);
}

void adjustIPCoreLoad(XGpio * gpio_handler)
{
	//Increase/Decrease IP Core Load
	if(adjustFactorIPCoreLoad != 0){
		int ip_core_load_en_mask = XGpio_DiscreteRead(gpio_handler,CHANNEL_LOAD_IP_CORE_EN);
		int en_coarse = ip_core_load_en_mask & COARSE_MODULES_BIT_MASK;
		int en_fine = (ip_core_load_en_mask >> AMOUNT_OF_COARSE_MODULES) & FINE_MODULES_BIT_MASK;
		printf("IP Core Load Enable Mask: 0x%x = fine 0x%x | coarse 0x%x\n",ip_core_load_en_mask,en_fine, en_coarse);
		printf("Bit masks fine 0x%x | coarse 0x%x\n",FINE_MODULES_BIT_MASK, COARSE_MODULES_BIT_MASK);
		switch(adjustFactorIPCoreLoad){
			case INCREASE_FACTOR_FINE:
				en_fine = (en_fine << 1) | 0x1;
				break;
			case INCREASE_FACTOR_COARSE:
				en_coarse = (en_coarse << 1) | 0x1;
				break;
			case DECREASE_FACTOR_FINE:
				en_fine = en_fine >> 1;
				break;
			case DECREASE_FACTOR_COARSE:
				en_coarse = en_coarse >> 1;
				break;
			default:
				break;
		}
		adjustFactorIPCoreLoad = 0;
		ip_core_load_en_mask = (en_coarse & COARSE_MODULES_BIT_MASK) | ((en_fine & FINE_MODULES_BIT_MASK) << AMOUNT_OF_COARSE_MODULES );
		printf("New IP Core Load Enable Mask: 0x%x = fine 0x%x | coarse 0x%x\n",ip_core_load_en_mask,en_fine, en_coarse);
		XGpio_DiscreteWrite(gpio_handler,CHANNEL_LOAD_IP_CORE_EN, ip_core_load_en_mask);
	}
}

void triggerMeasurementLoad(XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler)
{
	//Disable/Enable RO
	int dip_or_load_current = XGpio_DiscreteRead(gpio_dip_handler,CHANNEL_DIP) | loadEnabled;
	int led_current = XGpio_DiscreteRead(gpio_led_handler,CHANNEL_LED);
	if(dip_or_load_current != dip_or_load_history){
		if((dip_or_load_current != 0) || (loadEnabled != 0)){
			sendStatusMsgViaUart(STATUS_LOAD_ON,0);
			printf("GPIOs Dips: %i. Enable Load\n",dip_or_load_current);
			led_current |= LED_LOAD_STARTED;
			XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_LOAD_EN, 0x01); // Enable ro
		}else {
			sendStatusMsgViaUart(STATUS_LOAD_OFF,0);
			printf("GPIOs Dips: %i. Disable Load\n", dip_or_load_current);
			led_current &= (~LED_LOAD_STARTED);
			XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_LOAD_EN, 0x00); // Disable ro

		}
	}
	XGpio_DiscreteWrite(gpio_led_handler,CHANNEL_LED, led_current);
	dip_or_load_history = dip_or_load_current;
	//printf("Load triggered\n");
}
void pollAndSendCurrentMeasruementData()
{
	XTime time = 0;
	float value =0;
	//printf("Poll and send psu measurement data\n");
	SysMonPsuReadCurrentTemp(XPAR_PSU_AMS_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PSU_TEMP, value, time);
	SysMonPsuReadCurrentVccint(XPAR_PSU_AMS_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PSU_VCCINT, value, time);
	SysMonPsuReadCurrentVccaux(XPAR_PSU_AMS_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PSU_VCCAUX, value, time);

	SysMonPsuReadCurrentTempRem(XPAR_PSU_AMS_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PSU_REM_TEMP, value, time);
	if(psu_rem_temp_max < value){
		psu_rem_temp_max = value;
		psu_rem_temp_max_changed = 1;
		//pollAndSendMinMaxMeasruementData();
	}

	//printf("Poll and send pl measurement data\n");

	SysMonReadCurrentTemp(XPAR_SYSMON_0_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PL_TEMP, value, time);
	SysMonReadCurrentVccint(XPAR_SYSMON_0_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PL_VCCINT, value, time);
	SysMonReadCurrentVccaux(XPAR_SYSMON_0_DEVICE_ID, &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_PL_VCCAUX, value, time);


	//printf("Poll and send ambient measurement data\n");
	readTmpFromPmodtmp2( &value, &time);
	sendCurrentMeasurmentViaUart(MEASUREMENT_TYPE_AMBIENT_TEMP, value, time);

}

void pollAndSendMinMaxMeasruementData()
{
	XTime time = 0;
	float min = 0, max = 0;

	SysMonPsuReadMinMaxTemp(XPAR_PSU_AMS_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PSU_TEMP, min, max, time);
	SysMonPsuReadMinMaxTempRem(XPAR_PSU_AMS_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PSU_REM_TEMP, min, max, time);
	SysMonPsuReadMinMaxVccint(XPAR_PSU_AMS_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PSU_VCCINT, min, max, time);
	SysMonPsuReadMinMaxVccaux(XPAR_PSU_AMS_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PSU_VCCAUX, min, max, time);


	SysMonReadMinMaxTemp(XPAR_SYSMON_0_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PL_TEMP, min, max, time);
	SysMonReadMinMaxVccint(XPAR_SYSMON_0_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PL_VCCINT, min, max, time);
	SysMonReadMinMaxVccaux(XPAR_SYSMON_0_DEVICE_ID, &max, &min, &time);
	sendMinMaxMeasurmentViaUart(MEASUREMENT_TYPE_PL_VCCAUX, min, max, time);

}
void controlPolling(XGpio * gpio_led_pb_handler, XGpio * gpio_led_handler)
{
	//printf("Buttons: %i\n", XGpio_DiscreteRead(&my_gpios_led_pb,CHANNEL_PUSH));
	//u8 * msg = NULL;
	//u32 size = 1;
	//readUart(&UartPs, msg);
	//printf("Read byte %s", msg);
	int led_current = XGpio_DiscreteRead(gpio_led_pb_handler,CHANNEL_LED);
	button2_on = (XGpio_DiscreteRead(gpio_led_pb_handler,CHANNEL_PUSH) & BTN_MEAS_STOP);
	int button1_on_current = ((XGpio_DiscreteRead(gpio_led_pb_handler,CHANNEL_PUSH) & BTN_MEAS_PAUSE)>>2) ;
	//printf("pause button %x\n", button1_on_current);
	int polling_paused = polling_paused_history ^ ((button1_on_current != button1_on_history)&& (button1_on_current));
	//printf("polling_paused %x\n", polling_paused);
	polling_paused &= !continuePollingEnabled;
	polling_paused |= pausePollingEnabled;
	//printf("polling_paused after UART input %x\n", polling_paused);
	button1_on_history = button1_on_current;

	//System Monitor Polling
	if(!polling_paused){
		if(polling_paused < polling_paused_history){
			sendStatusMsgViaUart(STATUS_POLLING_CONTINUED,0);
		}
		led_current |= LED_MEAS_PAUSED;// Turn on LED1
		//Button not pushed at all
		//printf("Sysmon Polling running...\n");
		//char * msg = NULL;
		//SysMonPsuReadCurrentTemp(XPAR_PSU_AMS_DEVICE_ID, &msg); //Read current value of vcc and temp
		//printf("Send %s via Uart\n", msg);
		//int size = strlen(msg);
		//sendUart(&UartPs, msg, size);
		//free(msg);

		//SysMonPsuPolledReadCurrent(XPAR_PSU_AMS_DEVICE_ID); //Read current value of vcc and temp
		//SysMonPolledReadCurrent(XPAR_SYSMON_0_DEVICE_ID); //Read current value of vcc and temp

		pollAndSendCurrentMeasruementData();

		continuePollingEnabled = 0;
	}else {
		if(polling_paused > polling_paused_history){
			printf("Sysmon Polling paused...\n");
			led_current &= (~LED_MEAS_PAUSED); // Turn off LED1
			//pollAndSendMinMaxMeasruementData();
			//SysMonPsuPolledReadMinMax(XPAR_PSU_AMS_DEVICE_ID); //Read min and max value of vcc and temp
			//SysMonPolledReadMinMax(XPAR_SYSMON_0_DEVICE_ID); //Read min and max value of vcc and temp
			sendStatusMsgViaUart(STATUS_POLLING_PAUSED,0);
		}
		pausePollingEnabled = 0;
	}
	polling_paused_history = polling_paused;
	XGpio_DiscreteWrite(gpio_led_handler,CHANNEL_LED, led_current);
}

int runMeasurement(double* measurement_buffer, XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler) {
	XTime* Xtime = 0;
	XTime time = 0;
	float value = 0;
	XTime_GetTime(Xtime);
	int starting_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
	int current_time = starting_time;
	int end_time = TOTAL_MEAS_TIME_INTERVAL_MS + starting_time;
	int start_load_time = WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_MS+starting_time;
	int stop_load_time = WAIT_TILL_STARTING_LOAD_TIME_INTERVAL_MS + WAIT_TILL_STOPPING_LOAD_TIME_INTERVAL_MS+starting_time;
	int buffer_index = 0;
	//int time_index = 0;
	int last_measurement_time = 0;
	int load_status = 0;
	printf("start time %i, end time %i\n", starting_time, end_time);
	while (current_time < end_time) {
		//if (time_index == MEASUREMENT_OFFSET) {
		if(current_time > last_measurement_time + (MEASUREMENT_TIME_OFFSET_MS)){
			if (buffer_index < MEASUREMENT_BUFFER_SIZE) {
				SysMonPsuReadCurrentTempRem(XPAR_PSU_AMS_DEVICE_ID, &value,
						&time);
				measurement_buffer[buffer_index] = (double)value;
				printf("current time %i, value %f, index %i\n", current_time, measurement_buffer[buffer_index], buffer_index);
				buffer_index++;
				//time_index = 0;
				last_measurement_time =current_time;
			}
		}
		if((current_time > start_load_time) && load_status == 0){
			loadEnabled = 1;
			printf("Enable load at current time %i\n", current_time);
			load_status = 1;
			triggerMeasurementLoad(gpio_dip_handler, gpio_load_handler, gpio_led_handler);
			//XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_LOAD_EN, 0x01);
		}
		if((current_time > stop_load_time) && load_status == 1){
			loadEnabled = 0;
			load_status = 2;
			printf("Disable load at current time %i\n", current_time);
			triggerMeasurementLoad(gpio_dip_handler, gpio_load_handler, gpio_led_handler);
			//XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_LOAD_EN, 0x00);
		}
		XTime_GetTime(Xtime);
		current_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
		//printf("current time %i\n", current_time);
		//time_index++;
	}
	XTime_GetTime(Xtime);
	current_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
	printf("Measurement finished in %i ms\n", (current_time - starting_time));
	return buffer_index;
}

int classify_measurement(int amount_meas_datapoints, double* measurement_buffer) {
	printf("Calc welch\n");
	XTime* Xtime = 0;
	XTime_GetTime(Xtime);
	int starting_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
	printf("Extracting features...\n");
	double feature = spkt_welch_density(measurement_buffer, amount_meas_datapoints, WELCH_COEFF);
	XTime_GetTime(Xtime);
	int current_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
	double features[N_FEATURES];
	features[0] = feature;
	printf("Predicting...\n");
	int status = predict(features, 0);
	printf("welch %f, status %i (exe in %i ms)\n", feature, status, (current_time - starting_time));
	return status;
}

void checkForTampering(XGpio * gpio_dip_handler, XGpio * gpio_load_handler, XGpio * gpio_led_handler)
{
	int led_current = XGpio_DiscreteRead(gpio_led_handler,CHANNEL_LED);
	if(checkForTamperingEnabled == 1){

		XTime* Xtime = 0;
		XTime_GetTime(Xtime);
		int starting_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
		//Disable Interrupt
		UartPsIntrDisable(&InterruptController,UART_INT_IRQ_ID);

		double *measurement_buffer;
		measurement_buffer = (double *) calloc(MEASUREMENT_BUFFER_SIZE, sizeof(double));

		int amount_meas_datapoints = runMeasurement(measurement_buffer,gpio_dip_handler, gpio_load_handler, gpio_led_handler);
		//double measurement_buffer[732] = {56.695, 56.873999999999995, 56.446000000000005, 57.457, 57.2, 56.99, 57.091, 57.231, 57.34, 57.076, 57.146, 57.099, 57.596000000000004, 57.394, 57.045, 56.958999999999996, 57.581, 57.286, 56.881, 56.726000000000006, 57.239, 57.526, 56.703, 56.975, 57.379, 57.565, 56.843, 56.92, 57.286, 57.681999999999995, 57.068000000000005, 57.146, 57.348, 57.34, 56.835, 56.958999999999996, 57.045, 57.449, 57.379, 57.464, 57.379, 57.363, 57.006, 56.958999999999996, 57.037, 57.006, 57.348, 56.765, 57.153, 57.62, 57.681999999999995, 57.153, 56.951, 57.317, 57.836999999999996, 57.208, 56.888999999999996, 57.495, 57.651, 56.843, 57.153, 57.425, 57.69, 57.115, 57.488, 57.713, 57.208, 57.34, 57.286, 57.091, 57.55, 57.573, 57.558, 57.028999999999996, 57.402, 57.037, 56.951, 57.006, 57.216, 57.464, 57.099, 56.998000000000005, 57.604, 57.853, 57.138000000000005, 56.905, 57.736000000000004, 57.604, 57.045, 56.81100000000001, 57.861000000000004, 57.262, 57.216, 57.153, 57.542, 57.425, 57.387, 57.184, 57.394, 57.371, 57.651, 56.78, 57.2, 57.449, 57.565, 57.41, 57.037, 56.85, 57.76, 57.488, 57.037, 57.091, 57.425, 57.581, 56.563, 57.028999999999996, 57.472, 57.153, 57.184, 57.332, 57.045, 56.788000000000004, 56.858000000000004, 57.239, 57.247, 57.379, 57.013999999999996, 57.309, 57.052, 57.247, 57.169, 57.122, 57.184, 57.013999999999996, 57.317, 57.278, 57.052, 57.254, 57.472, 56.788000000000004, 56.827, 57.876000000000005, 57.526, 56.555, 56.81100000000001, 57.208, 57.806000000000004, 56.951, 56.672, 57.262, 57.441, 56.982, 57.254, 57.278, 57.192, 57.651, 57.122, 56.99, 57.309, 57.052, 57.324, 56.881, 57.332, 57.332, 57.184, 57.208, 57.573, 57.589, 57.076, 56.93600000000001, 57.898999999999994, 57.418, 56.726000000000006, 56.718, 57.107, 57.55, 57.045, 57.153, 57.48, 57.488, 57.379, 57.216, 57.223, 57.146, 57.2, 57.324, 57.379, 56.85, 56.982, 56.912, 57.363, 57.254, 57.433, 56.881, 56.943999999999996, 57.526, 57.651, 57.13, 57.192, 57.861000000000004, 57.946000000000005, 57.068000000000005, 56.86600000000001, 57.681999999999995, 57.868, 57.223, 56.873999999999995, 57.674, 57.457, 57.449, 57.317, 57.286, 57.441, 56.912, 57.13, 56.873999999999995, 57.262, 57.355, 57.534, 57.223, 57.394, 57.301, 57.379, 57.138000000000005, 57.666000000000004, 57.565, 56.99, 57.2, 57.247, 57.363, 57.278, 57.309, 57.379, 57.791000000000004, 57.332, 57.891999999999996, 58.023999999999994, 57.604, 57.729, 58.35, 58.195, 57.495, 57.806000000000004, 58.148, 58.684, 58.195, 58.156000000000006, 58.56, 58.622, 58.117, 58.14, 58.801, 58.995, 58.428000000000004, 58.047, 58.607, 58.56, 58.669, 59.011, 58.754, 58.715, 59.042, 58.832, 58.63, 58.809, 59.244, 58.576, 58.677, 59.236000000000004, 59.345, 58.972, 58.778, 59.336999999999996, 59.089, 58.373999999999995, 58.848, 59.43, 59.221000000000004, 58.747, 58.817, 59.398999999999994, 59.244, 59.042, 59.236000000000004, 59.485, 59.32899999999999, 59.345, 59.531000000000006, 59.967, 59.111999999999995, 59.593999999999994, 59.493, 59.493, 59.5, 59.477, 59.468999999999994, 59.368, 59.415, 59.67100000000001, 59.663999999999994, 59.306000000000004, 59.897, 59.943000000000005, 59.181999999999995, 59.126999999999995, 60.316, 59.485, 59.32899999999999, 59.81100000000001, 59.733999999999995, 59.423, 59.181999999999995, 60.293, 60.114, 60.028999999999996, 60.223, 59.818999999999996, 60.278, 59.648, 60.068000000000005, 60.231, 59.718, 60.635, 60.581, 59.881, 60.626999999999995, 59.92, 60.169, 60.923, 59.974, 60.208, 60.402, 60.044, 60.363, 60.184, 60.433, 60.751999999999995, 60.619, 60.713, 60.114, 60.643, 60.433, 60.744, 60.526, 60.619, 60.938, 60.75899999999999, 61.14, 60.518, 60.441, 60.713, 60.588, 60.316, 60.619, 61.327, 60.876000000000005, 60.674, 61.125, 61.163999999999994, 61.388999999999996, 61.591, 61.871, 61.809, 61.148, 61.062, 61.148, 61.187, 61.342, 61.676, 62.25899999999999, 61.941, 61.568000000000005, 61.878, 61.98, 61.498000000000005, 61.614, 62.088, 61.986999999999995, 61.373000000000005, 61.785, 61.972, 61.42, 61.513000000000005, 61.863, 61.832, 61.272, 61.528999999999996, 61.692, 61.972, 61.871, 61.917, 61.832, 61.638000000000005, 61.995, 62.018, 61.513000000000005, 61.568000000000005, 61.871, 61.528999999999996, 61.669, 61.91, 61.63, 61.754, 61.824, 61.995, 61.358000000000004, 61.163999999999994, 62.026, 62.104, 61.746, 62.251999999999995, 62.011, 61.388999999999996, 62.236000000000004, 61.809, 62.119, 62.034, 62.056999999999995, 62.236000000000004, 61.645, 62.081, 62.298, 61.77, 62.213, 62.143, 61.692, 62.562, 62.096000000000004, 61.832, 62.244, 62.275, 62.166000000000004, 61.871, 61.777, 62.57, 62.158, 61.7, 62.205, 62.266999999999996, 62.026, 62.018, 62.166000000000004, 62.593, 62.283, 62.547, 62.15, 62.073, 62.275, 62.049, 62.718, 62.345, 62.477, 62.275, 61.964, 63.106, 62.43, 62.578, 62.446000000000005, 62.593, 62.45399999999999, 62.881, 63.122, 62.415, 62.111999999999995, 62.858000000000004, 62.555, 62.632, 62.056999999999995, 62.415, 62.531000000000006, 62.531000000000006, 62.415, 62.081, 62.531000000000006, 62.368, 62.485, 62.562, 62.321000000000005, 62.733000000000004, 62.763999999999996, 62.336999999999996, 62.22, 63.425, 62.757, 62.617, 62.865, 62.842, 62.398999999999994, 62.772, 62.842, 62.081, 62.244, 63.099, 62.974, 62.64, 62.733000000000004, 62.873000000000005, 62.625, 62.85, 62.865, 62.422, 62.306000000000004, 62.492, 63.2, 62.438, 62.485, 62.974, 63.347, 62.166000000000004, 63.371, 62.407, 62.57, 62.726000000000006, 62.523999999999994, 62.547, 62.827, 62.966, 62.407, 62.213, 62.78, 63.192, 62.79600000000001, 62.842, 62.903999999999996, 62.702, 63.503, 63.82899999999999, 63.137, 63.332, 62.818999999999996, 63.145, 62.772, 62.407, 61.933, 62.538999999999994, 62.74100000000001, 62.625, 61.933, 62.126999999999995, 62.508, 62.485, 62.298, 62.018, 62.088, 62.25899999999999, 62.205, 61.684, 61.933, 62.555, 62.018, 61.793, 61.824, 62.228, 62.042, 61.739, 61.537, 62.228, 62.119, 61.218, 61.023999999999994, 62.275, 62.236000000000004, 61.723, 61.358000000000004, 61.91, 61.521, 61.715, 61.863, 61.692, 61.49, 61.63, 61.443000000000005, 61.42, 61.498000000000005, 61.863, 61.358000000000004, 61.288000000000004, 61.645, 62.034, 61.047, 61.17100000000001, 61.777, 61.972, 61.108999999999995, 60.977, 61.575, 61.443000000000005, 61.265, 61.125, 61.7, 61.986999999999995, 61.272, 61.521, 61.513000000000005, 61.568000000000005, 61.832, 61.381, 61.29600000000001, 61.373000000000005, 61.482, 61.451, 61.35, 61.661, 61.35, 61.218, 61.257, 61.785, 61.257, 60.821999999999996, 60.868, 61.645, 61.606, 60.93, 60.95399999999999, 61.715, 61.63, 61.07, 61.24100000000001, 61.443000000000005, 61.575, 61.521, 61.148, 61.653, 61.474, 61.265, 61.342, 61.403999999999996, 61.521, 61.63, 61.178999999999995, 61.187, 61.257, 61.31100000000001, 61.358000000000004, 60.798, 60.651, 61.458999999999996, 61.265, 60.985, 61.35, 61.467, 60.635, 60.503, 61.583, 61.451, 61.132, 60.836999999999996, 61.093999999999994, 61.43600000000001, 61.062, 61.156000000000006, 61.575, 61.397, 61.093999999999994, 60.938, 61.17100000000001, 61.047, 61.233000000000004, 60.868, 60.736000000000004, 60.744, 61.093999999999994, 61.14, 60.744, 60.968999999999994, 60.977, 61.272, 60.464, 60.938, 61.226000000000006, 61.552, 60.705, 61.163999999999994, 61.132, 60.604, 60.75899999999999, 61.125, 61.156000000000006, 60.977, 60.915, 60.95399999999999, 61.031000000000006, 60.88399999999999, 60.681999999999995, 60.845, 60.923, 60.821999999999996, 61.055, 60.946000000000005, 60.806000000000004, 60.985, 60.736000000000004, 60.301, 60.464, 61.358000000000004, 61.49, 60.658, 60.511, 60.88399999999999, 61.458999999999996, 60.853, 60.88399999999999, 60.705, 61.101000000000006, 60.923, 60.635, 61.108999999999995, 60.95399999999999, 60.95399999999999, 60.666000000000004, 60.588, 61.178999999999995, 60.581, 61.055, 60.853, 61.078, 61.43600000000001, 60.433, 60.744, 60.651, 60.845, 60.27, 60.534, 61.093999999999994, 61.163999999999994, 60.658, 60.55, 61.117, 61.218, 60.107, 60.347, 60.651};
		//double measurement_buffer[1001] = {58.949,59.446,59.734,59.252,60.052,59.842,58.7,58.855,59.485,58.708,59.555,58.918,59.011,59.508,58.778,59.392,58.886,59.135,58.964,58.972,59.166,59.617,59.337,58.879,59.578,58.622,59.174,58.972,59.12,59.415,59.423,59.392,58.832,59.135,59.19,59.197,59.158,59.011,59.314,58.863,58.886,59.306,59.687,58.84,59.135,58.855,59.042,59.166,58.925,59.57,59.648,58.848,58.785,59.757,58.956,59.493,59.026,59.205,59.197,58.902,58.778,59.166,58.863,59.415,59.547,59.454,58.949,59.943,58.902,59.361,59.586,58.886,59.454,59.127,59.446,59.019,59.446,59.197,59.531,59.454,59.019,59.508,58.832,59.765,59.625,59.236,59.244,59.726,58.925,59.166,59.205,58.886,59.943,59.057,59.322,59.741,59.089,59.695,58.56,59.267,58.886,59.516,59.057,59.298,59.415,59.236,59.881,59.462,59.236,59.337,58.995,59.158,59.298,59.073,58.941,59.073,59.423,59.197,59.221,58.817,59.43,59.12,59.228,59.291,59.493,58.956,59.563,58.964,59.081,59.065,59.151,59.718,59.166,59.306,58.817,59.524,58.941,59.399,58.956,58.972,59.516,58.941,59.267,59.259,59.065,59.446,59.384,59.174,59.259,59.516,58.886,59.609,59.221,58.871,59.298,58.731,59.298,58.98,59.065,58.824,59.236,58.801,59.236,59.384,59.174,59.415,59.158,59.392,59.392,58.801,58.956,59.423,59.454,58.739,59.757,58.98,59.462,59.221,58.941,59.765,58.925,59.127,59.524,59.78,59.228,59.578,59.392,58.871,59.446,58.63,59.399,59.096,58.778,59.081,59.905,59.011,59.104,59.213,58.723,59.803,59.034,59.12,59.399,58.723,59.749,59.368,59.267,58.995,59.5,59.05,59.197,59.524,59.586,59.368,59.026,59.322,58.762,59.788,58.653,59.594,59.314,59.539,59.283,59.531,58.801,59.85,59.361,59.539,59.897,59.399,59.508,59.5,59.749,59.702,59.368,59.71,60.06,60.177,59.827,60.456,60.565,60.534,60.472,59.889,60.985,60.34,60.946,60.41,61.319,60.891,61.195,60.736,60.658,61.249,60.651,61.443,60.619,60.355,60.41,60.868,60.853,60.643,61.49,60.915,61.568,60.697,60.736,61.451,60.658,61.692,61.094,61.334,61.109,61.63,61.249,61.202,61.373,60.954,61.816,61.024,61.366,61.56,61.684,61.148,61.925,61.459,61.575,61.591,61.086,61.389,61.358,61.132,61.591,61.676,61.676,61.42,61.871,61.109,61.84,61.436,61.094,62.112,61.179,61.249,61.653,61.824,61.265,62.104,61.91,61.723,61.653,61.35,62.049,61.529,62.283,62.026,61.202,61.35,61.785,62.049,61.715,62.252,61.708,61.894,61.847,61.762,62.228,61.645,62.166,61.964,62.267,61.148,62.049,61.84,62.213,62.15,61.7,62.228,62.042,61.785,61.715,62.663,61.847,61.863,61.902,61.987,62.236,61.972,62.391,62.625,61.98,62.586,62.36,62.399,62.244,62.492,61.801,62.391,62.368,62.298,62.57,61.692,62.135,62.127,62.368,61.925,62.531,62.049,62.205,62.329,62.034,62.764,62.384,61.972,62.29,61.793,62.166,62.601,62.22,61.824,62.951,62.461,61.956,62.663,62.127,62.663,62.298,62.5,62.127,63.044,62.026,62.71,62.492,61.692,62.858,62.547,62.64,62.353,62.298,61.878,62.555,62.236,62.353,62.485,61.863,62.555,62.5,62.244,62.71,62.376,62.632,62.384,62.92,61.855,62.741,62.283,62.36,62.718,62.275,62.99,62.562,62.345,62.694,62.64,61.956,62.578,62.749,62.446,62.772,62.29,62.492,62.477,62.772,63.029,62.368,62.702,62.694,62.764,62.376,63.021,62.772,62.539,63.005,62.492,63.091,62.64,62.966,62.321,63.052,62.531,63.068,62.819,62.298,63.215,62.788,63.029,63.013,62.64,62.617,62.865,62.788,62.492,63.27,62.679,63.137,62.966,62.694,63.472,62.764,62.951,62.834,63.2,62.718,63.324,62.92,62.796,63.029,62.842,63.137,62.531,62.718,63.254,62.865,63.044,62.943,63.083,62.578,63.293,62.881,62.912,62.865,63.262,63.332,63.029,63.2,63.231,63.542,63.029,62.694,63.254,63.052,63.441,62.873,63.231,63.207,63.246,62.951,63.604,62.935,63.083,63.542,62.928,63.495,63.099,63.472,63.573,63.122,63.402,63.27,63.681,63.145,63.697,63.021,63.417,63.27,63.099,63.767,63.005,63.207,62.749,63.635,63.005,63.456,62.943,63.021,63.549,62.935,63.106,63.137,63.083,62.694,63.573,63.052,62.881,63.464,63.036,63.378,62.951,62.935,63.518,62.671,63.246,63.215,63.332,62.796,63.922,63.231,63.464,63.363,62.764,63.767,62.966,63.068,63.604,63.744,63.044,63.487,63.782,62.982,63.487,62.5,63.518,63.293,62.99,63.526,62.71,63.044,63.394,63.759,63.068,63.635,63.479,62.889,63.371,63.036,63.534,63.386,63.394,63.145,63.137,63.262,63.433,63.728,62.982,64.039,63.192,63.316,63.363,63.2,63.114,63.604,63.332,63.355,63.922,63.192,64.171,63.34,63.184,63.798,63.479,63.417,63.223,63.876,63.503,63.86,63.635,63.837,63.674,63.184,63.93,63.72,64,64.179,63.899,63.518,63.604,64.171,63.829,64,63.619,63.782,64.101,63.161,63.751,63.829,63.798,63.549,64.334,63.518,63.977,63.681,63.573,64.311,63.464,63.705,64.016,63.852,63.549,63.681,63.907,63.891,64.086,63.658,64.093,63.93,63.472,64.14,63.65,64.086,63.814,63.728,63.301,64.187,63.852,63.891,64.179,63.643,63.977,63.534,63.736,63.744,63.93,63.58,64.054,63.713,63.433,64.218,63.441,63.674,63.845,63.378,64.202,64.28,63.852,63.464,63.728,63.565,63.814,63.681,63.821,64.28,63.534,64.008,63.705,64.054,63.487,64.124,64.008,63.705,64.062,63.316,64.194,63.915,63.977,64.202,64.482,63.705,64.047,64.078,64.062,64.552,63.697,63.915,63.992,64.039,64.575,63.658,63.837,63.526,64.358,63.643,64.365,64.054,64.023,64.575,64.179,64.303,64.202,64.117,63.674,64.428,64.148,63.946,64.381,64.023,64.56,64.249,63.837,64.225,63.666,63.798,64.078,64.319,63.953,64.637,64.101,64.148,64.148,64.109,64.598,64.288,64.21,63.985,64.428,63.705,64.334,64.078,64.062,64.824,63.899,64.148,64.295,64.49,64.863,64.396,64.365,64.381,65.026,64.078,64.785,64.303,64.544,64.295,63.728,64.668,64.326,64.404,64,64.466,64.28,64.295,64.14,64.047,64.816,64.49,64.039,64.288,64.785,63.86,64.373,64.257,63.961,64.49,64.008,64.707,63.899,64.241,64.886,64.257,64.396,64.412,64.56,64.078,64.459,64.459,64.412,64.909,64.194,64.49,63.938,64.622,64.389,64.692,64.047,64.7,64.637,64.218,64.521,64.567,64.692,64.738,64.63,65.158,64.583,64.443,64.536,64.692,64.156,64.521,64.661,64.342,64.894,63.837,64.909,64.373,64.505,64.303,64.808,64.28,64.808,64.428,64.451,64.723,64.575,64.731,64.614,64.894,64.124,65.057,64.505,64.497,64.505,64.35,64.863,64.622,63.961,64.56,64.552,64.42,64.684,64.832,64.109,64.622,64.334,64.591,64.723,64.264,64.902,64.303,64.412,64.28,64.769,64.637,64.482,64.777,64.575,64.7,64.257,64.731,64.373,64.404,64.63,64.451,64.521,64.101,64.785,64.49,64.288,64.319,64.07,64.241,63.814,63.961,64.249,63.713,63.713,64.023,64.031,63.169,64.404,63.355,63.394,63.728,63.332,63.969,63.122,63.394,63.386,63.518,62.788,63.518,63.425,63.246,63.347,62.726,63.697,62.959,63.394,62.5,63.332,63.13,62.881,63.169,62.819,63.137,62.889,63.099,62.982,62.485,63.277,63.285,62.578,62.368,63.371,62.586,62.982,62.749,62.741,63.176,62.601,62.803,62.516,63.075,62.5,62.912,62.671,62.586,63.238,61.933,63.293,62.407,62.531,62.897,62.252,62.368,62.228,62.492,62.096,62.726,62.213,62.539,62.586,61.925,63.044,62.298,62.492,62.267,62.842,62.306,62.679,62.508,62.174,62.827,62.22,62.764,62.5,61.964,62.22,62.982,62.166,62.197,62.197,61.995,62.43,62.119,62.687,62.819,61.801,62.593,62.656,62.36,62.345,62.539,62.081,62.321,61.995,62.026,62.733,61.972,61.832,62.368,62.625,61.809,62.57,62.422,62.213,62.803,62.166,62.127,62.407,62.182,62.842,62.57,61.902,62.22,62.524,61.669,62.508,62.104,61.739,62.36,61.847,62.391,62.376,62.267,61.684,62.694,61.847,62.189,62.306,62.353,62.112,61.661,62.049,62.228,61.77,61.676,62.026,62.042,61.855,62.275,61.715,62.081,61.801,61.754,62.461,61.723,61.956,61.871,62.197,61.77,62.112,61.777,61.816,62.391,61.21,61.754,61.91,61.855,61.723,61.941,61.777,62.197,62.011,61.793,62.337,61.443,61.746,62.182,61.537,62.43,62.345,62.088,61.847,62.407,61.451,61.933,61.941,61.676,62.018,61.101,61.762,61.746,61.902,61.63,61.925,61.622,61.661,61.956,61.397,61.871,61.684,61.552,61.995,61.801,61.754,61.583,61.777,61.63,61.832,61.451};
		//int amount_meas_datapoints = 1001;
//		int i;
//		int val = 0;
//		for(i =0; i< MEASUREMENT_BUFFER_SIZE; i++){
//			measurement_buffer[i] = i;
//			val = val+1;
//			printf("meas for %i : %i\n", i, measurement_buffer[i] );
//		}
//		int amount_meas_datapoints = i;
		printf("Measurement finished, continue with feature extraction\n");
		int chip_tampered = classify_measurement(amount_meas_datapoints, measurement_buffer);
		//free(measurement_buffer);
		//Enable Interrupt
		UartPsIntrEnable(&InterruptController,UART_INT_IRQ_ID);
		XTime_GetTime(Xtime);
		int current_time = *Xtime / MS_TO_TIMESTAMP_FACTOR;
		printf("chip_tampered %i (exe in %i ms)\n", chip_tampered, (current_time - starting_time));
		if(chip_tampered == 0){
			printf("Chip is not tampered %i\n", chip_tampered);
			sendStatusMsgViaUart(STATUS_CHIP_UNTAMPERED,(current_time - starting_time));
			led_current &= (~LED_CHIP_TAMPERED);
		}else{
			printf("Chip is tampered %i\n", chip_tampered);
			sendStatusMsgViaUart(STATUS_CHIP_TAMPERED,(current_time - starting_time));
			led_current |= LED_CHIP_TAMPERED;
		}
		checkForTamperingEnabled = 0;
	}
	XGpio_DiscreteWrite(gpio_led_handler,CHANNEL_LED, led_current);
}

void controlSendingMinMax()
{
	if((sendMinMaxEnabled > 0) || (psu_rem_temp_max_changed > 0)){

		//printf("Sending Min Max values...\n");
		sendMinMaxEnabled = 0;
		psu_rem_temp_max_changed = 0;
		pollAndSendMinMaxMeasruementData();
		//SysMonPsuPolledReadMinMax(XPAR_PSU_AMS_DEVICE_ID); //Read min and max value of vcc and temp
		//SysMonPolledReadMinMax(XPAR_SYSMON_0_DEVICE_ID); //Read min and max value of vcc and temp
	}
}
void setDutyCycle( XGpio * gpio_load_handler, int value)
{
	XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_DUTY_CYCLE, value); // Change duty cycle
	usleep(250);
	value = value | NEW_DUTY_CYCLE_ENABLE_BIT;
	XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_DUTY_CYCLE, value); // Change duty cycle
	usleep(250);
	value = value & (~NEW_DUTY_CYCLE_ENABLE_BIT);
	XGpio_DiscreteWrite(gpio_load_handler,CHANNEL_GPIO_OUT_DUTY_CYCLE, value); // Change duty cycle

}

void changeDutyCycle( XGpio * gpio_load_handler)
{
	//Increase/Decrease IP Core Load
	if(adjustFactorDutyCycle != 0){
		int current_duty_cycle = XGpio_DiscreteRead(gpio_load_handler,CHANNEL_GPIO_OUT_DUTY_CYCLE);
		printf("Current Duty Cycle 0x%x\n",current_duty_cycle);

		current_duty_cycle += adjustFactorDutyCycle;
		if(current_duty_cycle < 0)
			current_duty_cycle = 0;

		printf("New Duty Cycle 0x%x\n",current_duty_cycle);
		setDutyCycle( gpio_load_handler, current_duty_cycle);
		sendStatusMsgViaUart(STATUS_DUTY_CYCLE, current_duty_cycle);


	}
	if(setValueDutyCycle >= 0 ){
		int duty_cycle = setValueDutyCycle * 50;
		if(duty_cycle >= 250)
			duty_cycle = 255;
		printf("New Duty Cycle 0x%x\n",duty_cycle);
		setDutyCycle( gpio_load_handler, 0xff);
		usleep(1250000);
		setDutyCycle( gpio_load_handler, duty_cycle);
		sendStatusMsgViaUart(STATUS_DUTY_CYCLE, duty_cycle);
	}

	setValueDutyCycle = -1;
	adjustFactorDutyCycle = 0;


}

