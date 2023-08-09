/******************************************************************************
*
* Copyright (C) 2010 - 2014 Xilinx, Inc.  All rights reserved.
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
* @file		xuartps_intr_example.c
*
* This file contains a design example using the XUartPs driver in interrupt
* mode. It sends data and expects to receive the same data through the device
* using the local loopback mode.
*
*
* @note
* The example contains an infinite loop such that if interrupts are not
* working it may hang.
*
* MODIFICATION HISTORY:
* <pre>
* Ver   Who    Date     Changes
* ----- ------ -------- ----------------------------------------------
* 1.00a  drg/jz 01/13/10 First Release
* 1.00a  sdm    05/25/11 Modified the example for supporting Peripheral tests
*		        in SDK
* 1.03a  sg     07/16/12 Updated the example for CR 666306. Modified
*			the device ID to use the first Device Id
*			and increased the receive timeout to 8
*			Removed the printf at the start of the main
*			Put the device normal mode at the end of the example
* 3.1	kvn		04/10/15 Added code to support Zynq Ultrascale+ MP.
* 3.1   mus     01/14/16 Added support for intc interrupt controller
*
* </pre>
****************************************************************************/

/***************************** Include Files *******************************/

#include "uart_header.h"
#include <stdio.h>
/************************** Constant Definitions **************************/


volatile int TotalReceivedCount;



/**************************************************************************/
/**
*
* Main function to call the Uart interrupt example.
*
* @param	None
*
* @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful
*
* @note		None
*
**************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
	int Status;

	/* Run the UartPs Interrupt example, specify the the Device ID */
	Status = UartPsIntrInitialize(&InterruptController, &UartPs,
				UART_DEVICE_ID, UART_INT_IRQ_ID);
	if (Status != XST_SUCCESS) {
		xil_printf("UART Interrupt Example Test Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully ran UART Interrupt Example Test\r\n");
	return XST_SUCCESS;
}
#endif

/**************************************************************************/
/**
*
* This function does a minimal test on the UartPS device and driver as a
* design example. The purpose of this function is to illustrate
* how to use the XUartPs driver.
*
* This function sends data and expects to receive the same data through the
* device using the local loopback mode.
*
* This function uses interrupt mode of the device.
*
* @param	IntcInstPtr is a pointer to the instance of the Scu Gic driver.
* @param	UartInstPtr is a pointer to the instance of the UART driver
*		which is going to be connected to the interrupt controller.
* @param	DeviceId is the device Id of the UART device and is typically
*		XPAR_<UARTPS_instance>_DEVICE_ID value from xparameters.h.
* @param	UartIntrId is the interrupt Id and is typically
*		XPAR_<UARTPS_instance>_INTR value from xparameters.h.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note
*
* This function contains an infinite loop such that if interrupts are not
* working it may never return.
*
**************************************************************************/
int UartPsIntrInitialize(INTC *IntcInstPtr, XUartPs *UartInstPtr,
			u16 DeviceId, u16 UartIntrId)
{
	int Status;
	XUartPs_Config *Config;
	u32 IntrMask;

	TotalReceivedCount = 0;


	if (XGetPlatform_Info() == XPLAT_ZYNQ_ULTRA_MP) {
#ifdef XPAR_XUARTPS_1_DEVICE_ID
		DeviceId = XPAR_XUARTPS_1_DEVICE_ID;
#endif
	}


	printf("DeviceId: %i\r\n", DeviceId);

	/*
	 * Initialize the UART driver so that it's ready to use
	 * Look up the configuration in the config table, then initialize it.
	 */
	Config = XUartPs_LookupConfig(DeviceId);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(UartInstPtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Check hardware build */
	Status = XUartPs_SelfTest(UartInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	printf("UART Interrupt Setup Selftest Successful\r\n");

	/*
	 * Connect the UART to the interrupt subsystem such that interrupts
	 * can occur. This function is application specific.
	 */
	Status = SetupInterruptSystem(IntcInstPtr, UartInstPtr, UartIntrId);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	printf("UART Interrupt Setup SetupInterruptSystem\r\n");
	/*
	 * Setup the handlers for the UART that will be called from the
	 * interrupt context when data has been sent and received, specify
	 * a pointer to the UART driver instance as the callback reference
	 * so the handlers are able to access the instance data
	 */
	XUartPs_SetHandler(UartInstPtr, (XUartPs_Handler)Handler, UartInstPtr);

	XUartPs_SetBaudRate(UartInstPtr, 115200);
	/*
	 * Enable the interrupt of the UART so interrupts will occur, setup
	 * a local loopback so data that is sent will be received.
	 */
	IntrMask = XUARTPS_IXR_TOUT | XUARTPS_IXR_OVER | XUARTPS_IXR_RXFULL | XUARTPS_IXR_RXOVR;

	if (UartInstPtr->Platform == XPLAT_ZYNQ_ULTRA_MP) {
		IntrMask |= XUARTPS_IXR_RBRK;
		printf("BRK Interrupt enabled\r\n");
	}

	XUartPs_SetInterruptMask(UartInstPtr, IntrMask);

	u32 intMaskTest = XUartPs_GetInterruptMask(UartInstPtr);
	printf("UART Interrupt mask is %u\n", intMaskTest);



	/* Set the UART in Normal Mode */
	XUartPs_SetOperMode(UartInstPtr, XUARTPS_OPER_MODE_NORMAL);
	printf("UART Interrupt Setup Set Normal\r\n");



    XUartPs_WriteReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET,XUARTPS_CR_RXRST);
    XUartPs_WriteReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET,XUARTPS_CR_TXRST);

	u32 CntrlRegister;

	CntrlRegister = XUartPs_ReadReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET);


	/* Enable TX and RX for the device */
	XUartPs_WriteReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET,
			  ((CntrlRegister & ~XUARTPS_CR_EN_DIS_MASK) |
			   XUARTPS_CR_TX_EN | XUARTPS_CR_RX_EN));


	CntrlRegister = XUartPs_ReadReg(UartInstPtr->Config.BaseAddress, XUARTPS_ISR_OFFSET);
	printf("Interrupt status is %u\n", CntrlRegister);

	u8 result = XUartPs_GetFifoThreshold(UartInstPtr);
	printf("Fifo threshold is %u\n", result);


	u16 result16 = XUartPs_GetOptions(UartInstPtr);
	printf("Option is %u\n", result16);




	TotalReceivedCount = 0;
	return XST_SUCCESS;
}

void UartPsIntrDisable(INTC *IntcInstPtr, u16 UartIntrId)
{

	XScuGic_Disable(IntcInstPtr, UartIntrId);
}

void UartPsIntrEnable(INTC *IntcInstPtr, u16 UartIntrId)
{
	XScuGic_Enable(IntcInstPtr, UartIntrId);
}

int sendUart(XUartPs *IntcInstPtr, u8 * msg, u32 size){
	//printf("Send via Uart: %s (%i bytes)\n", msg, size);
	//XUartPs_Send(IntcInstPtr, msg, size);
	//printf("Send via Uart was successful\n");
	int SentCount = 0;
	while (SentCount < (size)) {
		/* Transmit the data */
		SentCount += XUartPs_Send(IntcInstPtr, &msg[SentCount], 1);
	}

	return XST_SUCCESS;
}

int readUart(XUartPs *IntcInstPtr, u8 * msg){
	if(TotalReceivedCount > 0){
		printf("Read UART data...\n");
		XUartPs_Recv(IntcInstPtr, msg, TotalReceivedCount);
		printf("Data received: %u \n", msg);
		TotalReceivedCount = 0;
	}
	return XST_SUCCESS;
}

/**************************************************************************/
/**
*
* This function is the handler which performs processing to handle data events
* from the device.  It is called from an interrupt context. so the amount of
* processing should be minimal.
*
* This handler provides an example of how to handle data for the device and
* is application specific.
*
* @param	CallBackRef contains a callback reference from the driver,
*		in this case it is the instance pointer for the XUartPs driver.
* @param	Event contains the specific kind of event that has occurred.
* @param	EventData contains the number of bytes sent or received for sent
*		and receive events.
*
* @return	None.
*
* @note		None.
*
***************************************************************************/
void Handler(void *CallBackRef, u32 Event, unsigned int EventData)
{

	printf("\n\n\n\nINTERRUPT Event:%u. Eventdata: %u\n\n\n\n", Event, EventData);
	XUartPs *UartInstPtr = (XUartPs *)CallBackRef;
	//u32 interruptStatus = XUartPs_ReadReg(UartInstPtr->Config.BaseAddress, XUARTPS_ISR_OFFSET);
	//printf("Interrupt status is %u\n", interruptStatus);

	/* All of the data has been sent */
	if (Event == XUARTPS_EVENT_SENT_DATA) {
		printf("Data was successfully sent \n");
		XUartPs_WriteReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET,XUARTPS_CR_TXRST);
	}

	/* All of the data has been received */
	if (Event == XUARTPS_EVENT_RECV_DATA) {
		printf("Data was successfully received \n");
		//TotalReceivedCount = EventData;
		//printf("TotalReceivedCount: %u \n", TotalReceivedCount);

		u32 datarec = XUartPs_IsReceiveData(UartInstPtr->Config.BaseAddress);
		u32 data = XUartPs_ReadReg(UartInstPtr->Config.BaseAddress,XUARTPS_FIFO_OFFSET);
		printf("Data was received(%u): %u [%c] \n", datarec, data, data);
		//u32 test = 'S';
		//printf("Ist it an %u bzw %c\n",test,test);
		if(data == 'S' || data == 's' ){
			printf("S or s was received: Stop load!\n");
			loadEnabled = 0;
		}else if(data == 'L' || data == 'l' ){
			printf("L or l was received: Start load!\n");
			loadEnabled = 1;
		}else if(data == 'M' || data == 'm' ){
			printf("M or m was received: Send Min/Max values!\n");
			sendMinMaxEnabled = 1;
		}else if(data == 'P' || data == 'p' ){
			printf("P or p was received: Pause polling!\n");
			pausePollingEnabled = 1;
		}else if(data == 'C' || data == 'c' ){
			printf("C or c was received: Continue polling!\n");
			continuePollingEnabled = 1;
		}else if(data == 'I' || data == 'i' ){
			printf("I or i was received: Increase IP Core Load by %i!\n", INCREASE_FACTOR_COARSE);
			adjustFactorIPCoreLoad = INCREASE_FACTOR_COARSE;
		}else if(data == 'A' || data == 'a' ){
			printf("A or a was received: Increase IP Core Load by %i!\n",INCREASE_FACTOR_FINE);
			adjustFactorIPCoreLoad = INCREASE_FACTOR_FINE;
		}else if(data == 'D' || data == 'd' ){
			printf("D or d was received: Decrease IP Core Load by %i!\n",DECREASE_FACTOR_COARSE);
			adjustFactorIPCoreLoad = DECREASE_FACTOR_COARSE;
		}else if(data == 'B' || data == 'b' ){
			printf("B or b was received: Decrease IP Core Load by %i!\n",DECREASE_FACTOR_FINE);
			adjustFactorIPCoreLoad = DECREASE_FACTOR_FINE;
		}else if(data == 'E' || data == 'e' ){
			printf("E or e was received:  Fan Speed (Duty Cycle)!\n");
			adjustFactorDutyCycle = -1;
		}else if(data == 'F' || data == 'f' ){
			printf("F or f was received: Increase Fan Speed (Duty Cycle)!\n");
			adjustFactorDutyCycle = 1;
		}else if(data == 'N' || data == 'n' ){
			printf("N or n was received: Measure, classify and check for tampering!\n");
			checkForTamperingEnabled = 1;
		}else if(data == '0'){
			printf("0 was received: Set Fan Speed (Duty Cycle) to 0%%!\n");
			setValueDutyCycle = 0;
		}else if(data == '1'){
			printf("1 was received: Set Fan Speed (Duty Cycle) to 20%%!\n");
			setValueDutyCycle = 1;
		}else if(data == '2'){
			printf("2 was received: Set Fan Speed (Duty Cycle) to 40%%!\n");
			setValueDutyCycle = 2;
		}else if(data == '3'){
			printf("3 was received: Set Fan Speed (Duty Cycle) to 60%%!\n");
			setValueDutyCycle = 3;
		}else if(data == '4'){
			printf("4 was received: Set Fan Speed (Duty Cycle) to 80%%!\n");
			setValueDutyCycle = 4;
		}else if(data == '5'){
			printf("5 was received: Set Fan Speed (Duty Cycle) to 100%%!\n");
			setValueDutyCycle = 5;
		}


		XUartPs_WriteReg(UartInstPtr->Config.BaseAddress, XUARTPS_CR_OFFSET,XUARTPS_CR_RXRST);
	}

	if (Event == XUARTPS_EVENT_RECV_ERROR) {
		u32 datarec = XUartPs_IsReceiveData(UartInstPtr->Config.BaseAddress);
		printf("Data was received: %u \n", datarec);
	}

}


/*****************************************************************************/
/**
*
* This function sets up the interrupt system so interrupts can occur for the
* Uart. This function is application-specific. The user should modify this
* function to fit the application.
*
* @param	IntcInstancePtr is a pointer to the instance of the INTC.
* @param	UartInstancePtr contains a pointer to the instance of the UART
*		driver which is going to be connected to the interrupt
*		controller.
* @param	UartIntrId is the interrupt Id and is typically
*		XPAR_<UARTPS_instance>_INTR value from xparameters.h.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
****************************************************************************/
static int SetupInterruptSystem(INTC *IntcInstancePtr,
				XUartPs *UartInstancePtr,
				u16 UartIntrId)
{
	int Status;

#ifdef XPAR_INTC_0_DEVICE_ID

	printf("UART Interrupt Setup INTC\r\n");
#ifndef TESTAPP_GEN
	/*
	 * Initialize the interrupt controller driver so that it's ready to
	 * use.
	 */

	Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif //TESTAPP_GEN//
	/*
	 * Connect the handler that will be called when an interrupt
	 * for the device occurs, the handler defined above performs the
	 * specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(IntcInstancePtr, UartIntrId,
		(XInterruptHandler) XUartPs_InterruptHandler, UartInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

#ifndef TESTAPP_GEN
	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts.
	 */
	Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif//TESTAPP_GEN//
	/*
	 * Enable the interrupt for uart
	 */
	XIntc_Enable(IntcInstancePtr, UartIntrId);

#ifndef TESTAPP_GEN
	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				(Xil_ExceptionHandler) XIntc_InterruptHandler,
				IntcInstancePtr);
#endif//TESTAPP_GEN//
#else//Not XPAR_INTC_0_DEVICE_ID//
	printf("UART Interrupt Setup ScuGic\r\n");

	XScuGic_Config *IntcConfig; /* Config for interrupt controller */

	/* Initialize the interrupt controller driver */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the interrupt controller interrupt handler to the
	 * hardware interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				(Xil_ExceptionHandler) XScuGic_InterruptHandler,
				IntcInstancePtr);

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler
	 * performs the specific interrupt processing for the device
	 */

	Status = XScuGic_Connect(IntcInstancePtr, UartIntrId,
				  (Xil_ExceptionHandler) XUartPs_InterruptHandler,
				  (void *) UartInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Enable the interrupt for the device */
	XScuGic_Enable(IntcInstancePtr, UartIntrId);

#endif
	/* Enable interrupts */
	 Xil_ExceptionEnable();

	return XST_SUCCESS;
}
