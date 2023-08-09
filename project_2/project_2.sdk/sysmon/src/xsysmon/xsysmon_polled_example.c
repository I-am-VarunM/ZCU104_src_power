#define TESTAPP_GEN
/******************************************************************************
*
* Copyright (C) 2007 - 2014 Xilinx, Inc.  All rights reserved.
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
/****************************************************************************/
/**
*
* @file xsysmon_polled_printf_example.c
*
* This file contains a design example using the driver functions
* of the System Monitor driver. The example here shows the
* driver/device in polled mode to check the on-chip temperature and voltages.
*
* @note
*
* This examples also assumes that there is a STDIO device in the system.
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who    Date     Changes
* ----- -----  -------- -----------------------------------------------------
* 1.00a xd/sv  05/22/07 First release
* 2.00a sv     06/22/08 Added printfs and used conversion macros
* 4.00a ktn    10/22/09 Updated the example to use macros that have been
*		        renamed to remove _m from the name of the macro.
* 5.03a bss    04/25/13 Modified SysMonPolledPrintfExample function to
*			set Sequencer Mode as Safe mode instead of Single
*			channel mode before configuring Sequencer registers.
*			CR #703729
* 7.3   ms   01/23/17 Added xil_printf statement in main function to
*                     ensure that "Successfully ran" and "Failed" strings
*                     are available in all examples. This is a fix for
*                     CR-965028.
*       ms   04/05/17 Modified Comment lines in functions to
*                     recognize it as documentation block for doxygen
*                     generation.
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xsysmon.h"
#include "xparameters.h"
#include "xstatus.h"
#include "stdio.h"
#include "xil_printf.h"
#include "xtime_l.h"
#include "uart_header.h"
#include "sysmon_header.h"

/************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define SYSMON_DEVICE_ID 	XPAR_SYSMON_0_DEVICE_ID


/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/

#define printf xil_printf /* Small foot-print printf function */

/************************** Function Prototypes *****************************/

int SysMonPolledPrintfExample(u16 SysMonDeviceId);
int SysMonPolledSetup(u16 SysMonDeviceId, XSysMon *SysMonInstPtr);
int SysMonPolledReadCurrent(u16 SysMonDeviceId);
int SysMonPolledReadMinMax(u16 SysMonDeviceId);
int Setup_Done = 0;
static int SysMonFractionToInt(float FloatNum);

/************************** Variable Definitions ****************************/
//int max = 0;
static XSysMon SysMonInst;      /* System Monitor driver instance */
#ifndef TESTAPP_GEN

/****************************************************************************/
/**
*
* Main function that invokes the polled example in this file.
*
* @param	None.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note		None.
*
*****************************************************************************/
int main(void)
{

	int Status;

	/*
	 * Run the SysMonitor polled example, specify the Device ID that is
	 * generated in xparameters.h.
	 */
	Status = SysMonPolledPrintfExample(SYSMON_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		xil_printf("Sysmon polled printf Example Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully ran Sysmon polled printf Example\r\n");
	return XST_SUCCESS;
}

#endif /* TESTAPP_GEN */


/****************************************************************************/
/**
*
* This function performs setup for the System Monitor device using the
* driver APIs.
* This function does the following tasks:
*	- Initiate the System Monitor device driver instance
*	- Run self-test on the device
*	- Setup the sequence registers to continuously monitor on-chip
*	temperature, VCCINT and VCCAUX
*	- Setup configuration registers to start the sequence
*
* @param	SysMonDeviceId is the XPAR_<SYSMON_instance>_DEVICE_ID value
*		from xparameters.h.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note   	None
*
****************************************************************************/
int SysMonPolledSetup(u16 SysMonDeviceId, XSysMon * SysMonInstPtr)
{
	int Status;
	XSysMon_Config *ConfigPtr;
	//u64 IntrStatus;

	printf("\r\nEntering the SysMon Polled Setup. \r\n");

	/*
		 * Initialize the SysMon driver.
		 */
		ConfigPtr = XSysMon_LookupConfig(SysMonDeviceId);
		if (ConfigPtr == NULL) {
			return XST_FAILURE;
		}
		XSysMon_CfgInitialize(SysMonInstPtr, ConfigPtr,
					ConfigPtr->BaseAddress);

		/*
		 * Self Test the System Monitor/ADC device
		 */
		Status = XSysMon_SelfTest(SysMonInstPtr);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		/*
		 * Disable the Channel Sequencer before configuring the Sequence
		 * registers.
		 */
		XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_SAFE);


		/*
		 * Disable all the alarms in the Configuration Register 1.
		 */
		XSysMon_SetAlarmEnables(SysMonInstPtr, 0x0);


		/*
		 * Setup the Averaging to be done for the channels in the
		 * Configuration 0 register as 16 samples:
		 */
		XSysMon_SetAvg(SysMonInstPtr, XSM_AVG_16_SAMPLES);

		/*
		 * Setup the Sequence register for 1st Auxiliary channel
		 * Setting is:
		 *	- Add acquisition time by 6 ADCCLK cycles.
		 *	- Bipolar Mode
		 *
		 * Setup the Sequence register for 16th Auxiliary channel
		 * Setting is:
		 *	- Add acquisition time by 6 ADCCLK cycles.
		 *	- Unipolar Mode
		 */
		Status = XSysMon_SetSeqInputMode(SysMonInstPtr, XSM_SEQ_CH_AUX00);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		Status = XSysMon_SetSeqAcqTime(SysMonInstPtr, XSM_SEQ_CH_AUX15 |
							XSM_SEQ_CH_AUX00);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}


		/*
		 * Enable the averaging on the following channels in the Sequencer
		 * registers:
		 * 	- On-chip Temperature, VCCINT/VCCAUX  supply sensors
		 * 	- 1st/16th Auxiliary Channels
		  *	- Calibration Channel
		 */
		Status =  XSysMon_SetSeqAvgEnables(SysMonInstPtr, XSM_SEQ_CH_TEMP |
							XSM_SEQ_CH_VCCINT |
							XSM_SEQ_CH_VCCAUX |
							XSM_SEQ_CH_AUX00 |
							XSM_SEQ_CH_AUX15 |
							XSM_SEQ_CH_CALIB);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		/*
		 * Enable the following channels in the Sequencer registers:
		 * 	- On-chip Temperature, VCCINT/VCCAUX supply sensors
		 * 	- 1st/16th Auxiliary Channel
		 *	- Calibration Channel
		 */
		Status =  XSysMon_SetSeqChEnables(SysMonInstPtr, XSM_SEQ_CH_TEMP |
							XSM_SEQ_CH_VCCINT |
							XSM_SEQ_CH_VCCAUX |
							XSM_SEQ_CH_AUX00 |
							XSM_SEQ_CH_AUX15 |
							XSM_SEQ_CH_CALIB);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}


		/*
		 * Set the ADCCLK frequency equal to 1/32 of System clock for the System
		 * Monitor/ADC in the Configuration Register 2.
		 */
		XSysMon_SetAdcClkDivisor(SysMonInstPtr, 32);


		/*
		 * Set the Calibration enables.
		 */
		XSysMon_SetCalibEnables(SysMonInstPtr,
					XSM_CFR1_CAL_PS_GAIN_OFFSET_MASK |
					XSM_CFR1_CAL_ADC_GAIN_OFFSET_MASK);

		/*
		 * Enable the Channel Sequencer in continuous sequencer cycling mode.
		 */
		XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_CONTINPASS);

		/*
		 * Wait till the End of Sequence occurs
		 */
		XSysMon_GetStatus(SysMonInstPtr); /* Clear the old status */
		while ((XSysMon_GetStatus(SysMonInstPtr) & XSM_SR_EOS_MASK) !=
				XSM_SR_EOS_MASK);


	printf("\r\nSysMon Polled Setup was successful. \r\n");
	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function runs a test on the System Monitor/ADC device using the
* driver APIs.
* This function does the following tasks:
*	- Initiate the System Monitor device driver instance
*	- Run self-test on the device
*	- Setup the sequence registers to continuously monitor on-chip
*	temperature, VCCINT and VCCAUX
*	- Setup configuration registers to start the sequence
*	- Read the latest on-chip temperature, VCCINT and VCCAUX
*
* @param	SysMonDeviceId is the XPAR_<SYSMON_ADC_instance>_DEVICE_ID value
*		from xparameters.h.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note   	None
*
****************************************************************************/
int SysMonPolledPrintfExample(u16 SysMonDeviceId)
{
	u32 TempRawData;
	u32 VccAuxRawData;
	u32 VccIntRawData;
	float TempData;
	float VccAuxData;
	float VccIntData;
	float MaxData;
	float MinData;
	XSysMon *SysMonInstPtr = &SysMonInst;

	//printf("\r\nEntering the SysMon Polled Example. \r\n");



	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	TempRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_TEMP);
	TempData = XSysMon_RawToTemperature(TempRawData);
	printf("\r\nThe Current Temperature is %0d.%03d Centigrades.\r\n",
				(int)(TempData), SysMonFractionToInt(TempData));


	TempRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MAX_TEMP);
	MaxData = XSysMon_RawToTemperature(TempRawData);
	printf("The Maximum Temperature is %0d.%03d Centigrades. \r\n",
				(int)(MaxData), SysMonFractionToInt(MaxData));

	TempRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MIN_TEMP);
	MinData = XSysMon_RawToTemperature(TempRawData);
	printf("The Minimum Temperature is %0d.%03d Centigrades. \r\n",
				(int)(MinData), SysMonFractionToInt(MinData));

	/*
	 * Read the VccInt Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccIntRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCINT);
	VccIntData = XSysMon_RawToVoltage(VccIntRawData);
	printf("\r\nThe Current VCCINT is %0d.%03d Volts. \r\n",
			(int)(VccIntData), SysMonFractionToInt(VccIntData));

	VccIntRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MAX_VCCINT);
	MaxData = XSysMon_RawToVoltage(VccIntRawData);
	printf("The Maximum VCCINT is %0d.%03d Volts. \r\n",
			(int)(MaxData), SysMonFractionToInt(MaxData));

	VccIntRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MIN_VCCINT);
	MinData = XSysMon_RawToVoltage(VccIntRawData);
	printf("The Minimum VCCINT is %0d.%03d Volts. \r\n",
			(int)(MinData), SysMonFractionToInt(MinData));

	/*
	 * Read the VccAux Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccAuxRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCAUX);
	VccAuxData = XSysMon_RawToVoltage(VccAuxRawData);
	printf("\r\nThe Current VCCAUX is %0d.%03d Volts. \r\n",
			(int)(VccAuxData), SysMonFractionToInt(VccAuxData));

	VccAuxRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MAX_VCCAUX);
	MaxData = XSysMon_RawToVoltage(VccAuxRawData);
	printf("The Maximum VCCAUX is %0d.%03d Volts. \r\n",
				(int)(MaxData), SysMonFractionToInt(MaxData));


	VccAuxRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MIN_VCCAUX);
	MinData = XSysMon_RawToVoltage(VccAuxRawData);
	printf("The Minimum VCCAUX is %0d.%03d Volts. \r\n\r\n",
				(int)(MinData), SysMonFractionToInt(MinData));

	//printf("Exiting the SysMon Polled Example. \r\n");

	return XST_SUCCESS;
}
/****************************************************************************/
/**
*
* This function reads current vcc and temp.
*
* @param	SysMonDeviceId is the XPAR_<SYSMON_instance>_DEVICE_ID value
*		from xparameters.h.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note   	None
*
****************************************************************************/
int SysMonPolledReadCurrent(u16 SysMonDeviceId)
{
	u32 TempRawData;
	u32 VccAuxRawData;
	u32 VccIntRawData;
	float TempData;
	float VccAuxData;
	float VccIntData;
    XTime * Xtime = 0;
	XSysMon *SysMonInstPtr = &SysMonInst;
	char * msg = NULL, * msg1 = NULL, * msg2 = NULL;
	int size = 0;

	//printf("\r\nEntering the SysMon Polled Current. \r\n");
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	TempRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_TEMP);
	TempData = XSysMon_RawToTemperature(TempRawData);
	XTime_GetTime(Xtime);
//		printf("The Current Temperature is %0d.%03d Centigrades (time: %lu).\r\n",
//					(int)(TempData), SysMonFractionToInt(TempData), *Xtime);
	asiprintf(&msg,"The Current Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(TempData), SysMonFractionToInt(TempData), *Xtime);
	size = strlen(msg);
	//printf("size %i %s \n", size, msg);
	sendUart(&UartPs, msg, size);

	/*
	 * Read the VccInt Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccIntRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCINT);
	VccIntData = XSysMon_RawToVoltage(VccIntRawData);
	XTime_GetTime(Xtime);
//	printf("The Current VCCINT is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(VccIntData), SysMonFractionToInt(VccIntData), *Xtime);

	asiprintf(&msg1,"The Current VCCINT is %0d.%03d Volts (time: %lu). \n",	(int)(VccIntData), SysMonFractionToInt(VccIntData), *Xtime);
	size = strlen(msg1);
	//printf("%s", msg1);
	sendUart(&UartPs, msg1, size);

	/*
	 * Read the VccAux Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccAuxRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCAUX);
	VccAuxData = XSysMon_RawToVoltage(VccAuxRawData);
	XTime_GetTime(Xtime);
//	printf("The Current VCCAUX is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(VccAuxData), SysMonFractionToInt(VccAuxData), *Xtime);

	asiprintf(&msg2,"The Current VCCAUX is %0d.%03d Volts (time: %lu). \n",	(int)(VccAuxData), SysMonFractionToInt(VccAuxData), *Xtime);
	size = strlen(msg2);
	//printf("%s", msg2);
	sendUart(&UartPs, msg2, size);


	free(msg);
	free(msg1);
	free(msg2);
	//printf("Exiting the SysMon Polled Example. \r\n");

	return XST_SUCCESS;
}


int SysMonReadCurrentTemp(u16 SysMonDeviceId, float * value, XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	rawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_TEMP);
	*value = XSysMon_RawToTemperature(rawData);
	XTime_GetTime(time);
	//	printf("The Current Temperature is %0d.%03d Centigrades (time: %lu).\r\n",
	//				(int)(*value), SysMonFractionToInt(*value), *time);
	//asiprintf(&msg,"The Current Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)(TempData), SysMonFractionToInt(TempData), *Xtime);
	return XST_SUCCESS;
}
int SysMonReadCurrentVccint(u16 SysMonDeviceId, float * value, XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the VccInt Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	rawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCINT);
	*value = XSysMon_RawToVoltage(rawData);
	XTime_GetTime(time);
//	printf("The Current VCCINT is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(VccIntData), SysMonFractionToInt(VccIntData), *Xtime);

	//asiprintf(&msg1,"The Current VCCINT is %0d.%03d Volts (time: %lu). \n",	(int)(VccIntData), SysMonFractionToInt(VccIntData), *Xtime);

	return XST_SUCCESS;
}
int SysMonReadCurrentVccaux(u16 SysMonDeviceId, float * value, XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the VccAux Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	rawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_VCCAUX);
	*value = XSysMon_RawToVoltage(rawData);
	XTime_GetTime(time);
//	printf("The Current VCCAUX is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(VccAuxData), SysMonFractionToInt(VccAuxData), *Xtime);

	//asiprintf(&msg2,"The Current VCCAUX is %0d.%03d Volts (time: %lu). \n",	(int)(VccAuxData), SysMonFractionToInt(VccAuxData), *Xtime);

	return XST_SUCCESS;
}

int SysMonReadMinMaxTemp(u16 SysMonDeviceId, float * max, float * min, XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the on-chip Temperature Data (Current/Maximum/Minimum)
	 * from the ADC data registers.
	 */
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MAX_TEMP);
	*max = XSysMon_RawToTemperature(rawData);
	XTime_GetTime(time);
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MIN_TEMP);
	*min = XSysMon_RawToTemperature(rawData);
	return XST_SUCCESS;
}
int SysMonReadMinMaxVccint(u16 SysMonDeviceId, float * max, float * min,XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the VccInt Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MAX_VCCAUX);
	*max = XSysMon_RawToVoltage(rawData);
	XTime_GetTime(time);
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MIN_VCCAUX);
	*min = XSysMon_RawToVoltage(rawData);
	return XST_SUCCESS;
}

int SysMonReadMinMaxVccaux(u16 SysMonDeviceId, float * max, float * min, XTime * time)
{
	u32 rawData;
	XSysMon *SysMonInstPtr = &SysMonInst;
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}
	/*
	 * Read the VccAux Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MAX_VCCINT);
	*max = XSysMon_RawToVoltage(rawData);
	XTime_GetTime(time);
	rawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MIN_VCCINT);
	*min = XSysMon_RawToVoltage(rawData);
	return XST_SUCCESS;
}
/****************************************************************************/
/**
*
* This function reads min and max vcc and temp.
*
* @param	SysMonDeviceId is the XPAR_<SYSMON_instance>_DEVICE_ID value
*		from xparameters.h.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note   	None
*
****************************************************************************/
int SysMonPolledReadMinMax(u16 SysMonDeviceId)
{
	u32 TempRawData;
	u32 VccAuxRawData;
	u32 VccIntRawData;
	float MaxData;
	float MinData;
    XTime * Xtime = 0;
	XSysMon *SysMonInstPtr = &SysMonInst;
	char * msg = NULL, * msg1 = NULL, * msg2 = NULL;
	int size = 0;

	//printf("Entering the SysMon Polled MinMax. \r\n");
	if(Setup_Done == 0){
		if( SysMonPolledSetup(SysMonDeviceId, SysMonInstPtr) == XST_SUCCESS){
			Setup_Done = 1;
		}
	}


	TempRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MAX_TEMP);
	MaxData = XSysMon_RawToTemperature(TempRawData);
	XTime_GetTime(Xtime);
//	printf("The Maximum Temperature is %0d.%03d Centigrades (time: %lu). \r\n",
//				(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime);


	TempRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr, XSM_MIN_TEMP);
	MinData = XSysMon_RawToTemperature(TempRawData);
	XTime_GetTime(Xtime);
//	printf("The Minimum Temperature is %0d.%03d Centigrades (time: %lu). \r\n",
//				(int)(MinData), SysMonFractionToInt(MinData), *Xtime);

	asiprintf(&msg,"The Maximum Temperature is %0d.%03d Centigrades (time: %lu).\n"
			"The Minimum Temperature is %0d.%03d Centigrades (time: %lu).\n",	(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime,
			(int)(MinData), SysMonFractionToInt(MinData), *Xtime);
	size = strlen(msg);
	//printf("%s", msg);
	sendUart(&UartPs, msg, size);


	VccIntRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MAX_VCCINT);
	MaxData = XSysMon_RawToVoltage(VccIntRawData);
	XTime_GetTime(Xtime);
//	printf("The Maximum VCCINT is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime);

	VccIntRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MIN_VCCINT);
	MinData = XSysMon_RawToVoltage(VccIntRawData);
	XTime_GetTime(Xtime);
//	printf("The Minimum VCCINT is %0d.%03d Volts (time: %lu). \r\n",
//			(int)(MinData), SysMonFractionToInt(MinData), *Xtime);

	asiprintf(&msg1,"The Maximum VCCINT is %0d.%03d Centigrades (time: %lu).\n"
			"The Minimum VCCINT is %0d.%03d Centigrades (time: %lu).\n",	(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime,
			(int)(MinData), SysMonFractionToInt(MinData), *Xtime);
	size = strlen(msg1);
	//printf("%s", msg1);
	sendUart(&UartPs, msg1, size);


	VccAuxRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MAX_VCCAUX);
	MaxData = XSysMon_RawToVoltage(VccAuxRawData);
	XTime_GetTime(Xtime);
//	printf("The Maximum VCCAUX is %0d.%03d Volts (time: %lu). \r\n",
//				(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime);


	VccAuxRawData = XSysMon_GetMinMaxMeasurement(SysMonInstPtr,
							XSM_MIN_VCCAUX);
	MinData = XSysMon_RawToVoltage(VccAuxRawData);
	XTime_GetTime(Xtime);
//	printf("The Minimum VCCAUX is %0d.%03d Volts (time: %lu). \r\n",
//				(int)(MinData), SysMonFractionToInt(MinData), *Xtime);

	asiprintf(&msg2,"The Maximum VCCAUX is %0d.%03d Centigrades (time: %lu).\n"
			"The Minimum VCCAUX is %0d.%03d Centigrades (time: %lu).\n",	(int)(MaxData), SysMonFractionToInt(MaxData), *Xtime,
			(int)(MinData), SysMonFractionToInt(MinData), *Xtime);
	size = strlen(msg2);
	//printf("%s", msg2);
	sendUart(&UartPs, msg2, size);
	//printf("Exiting the SysMon Polled MinMax. \r\n");

	free(msg);
	free(msg1);
	free(msg2);
	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* This function converts the fraction part of the given floating point number
* (after the decimal point)to an integer.
*
* @param	FloatNum is the floating point number.
*
* @return	Integer number to a precision of 3 digits.
*
* @note
* This function is used in the printing of floating point data to a STDIO device
* using the xil_printf function. The xil_printf is a very small foot-print
* printf function and does not support the printing of floating point numbers.
*
*****************************************************************************/
int SysMonFractionToInt(float FloatNum)
{
	float Temp;

	Temp = FloatNum;
	if (FloatNum < 0) {
		Temp = -(FloatNum);
	}

	return( ((int)((Temp -(float)((int)Temp)) * (1000.0f))));
}
