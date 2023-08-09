#define TESTAPP_GEN
/*
 * uart_header.h
 *
 *  Created on: Oct 3, 2019
 *      Author: Carina
 */

#ifndef SRC_PERIPHERAL_UART_HEADER_H_
#define SRC_PERIPHERAL_UART_HEADER_H_
#include "xparameters.h"
#include "xplatform_info.h"
#include "xuartps.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

#ifdef XPAR_INTC_0_DEVICE_ID
#include "xintc.h"
#else
#include "xscugic.h"
#endif

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifdef XPAR_INTC_0_DEVICE_ID
	#define INTC		XIntc
	#define UART_DEVICE_ID		XPAR_XUARTPS_0_DEVICE_ID
	#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
	#define UART_INT_IRQ_ID		XPAR_INTC_0_UARTPS_0_VEC_ID
#else
	#define INTC		XScuGic
	#define UART_DEVICE_ID		XPAR_XUARTPS_1_DEVICE_ID
	#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
	#define UART_INT_IRQ_ID		XPAR_XUARTPS_1_INTR
#endif
/*
 * The following constant controls the length of the buffers to be sent
 * and received with the UART,
 */
#define BUFFER_SIZE	100


/**************************** Type Definitions ******************************/


/************************** Function Prototypes *****************************/

int UartPsIntrInitialize(INTC *IntcInstPtr, XUartPs *UartInstPtr,
			u16 DeviceId, u16 UartIntrId);

void UartPsIntrDisable(INTC *IntcInstPtr, u16 UartIntrId);

void UartPsIntrEnable(INTC *IntcInstPtr, u16 UartIntrId);

static int SetupInterruptSystem(INTC *IntcInstancePtr,
				XUartPs *UartInstancePtr,
				u16 UartIntrId);

void Handler(void *CallBackRef, u32 Event, unsigned int EventData);

int sendUart(XUartPs *IntcInstPtr, u8 * msg, u32 size);
int readUart(XUartPs *IntcInstPtr, u8 * msg);

int loadEnabled;
int sendMinMaxEnabled;
int pausePollingEnabled;
int continuePollingEnabled;
int checkForTamperingEnabled;
int adjustFactorIPCoreLoad;
int adjustFactorDutyCycle;
int setValueDutyCycle;

#define INCREASE_FACTOR_FINE 100
#define DECREASE_FACTOR_FINE (-100)
#define INCREASE_FACTOR_COARSE (1000)
#define DECREASE_FACTOR_COARSE (-1000)


#endif /* SRC_PERIPHERAL_UART_HEADER_H_ */
