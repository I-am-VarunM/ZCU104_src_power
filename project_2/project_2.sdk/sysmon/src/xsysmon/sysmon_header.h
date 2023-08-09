#define TESTAPP_GEN

/******************************************************************************
*
* Copyright (C) 2017 Xilinx, Inc.  All rights reserved.
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
#ifndef SYSMON_HEADER_H		/* prevent circular inclusions */
#define SYSMON_HEADER_H		/* by using protection macros */

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "uart_header.h"
#include "xtime_l.h"

int SysMonPolledPrintfExample(u16 DeviceId);
int SysMonPolledReadCurrent(u16 SysMonDeviceId);
int SysMonPolledReadMinMax(u16 SysMonDeviceId);

int SysMonReadCurrentTemp(u16 SysMonDeviceId, float * value, XTime * time);
int SysMonReadCurrentVccint(u16 SysMonDeviceId, float * value, XTime * time);
int SysMonReadCurrentVccaux(u16 SysMonDeviceId, float * value, XTime * time);
int SysMonReadMinMaxTemp(u16 SysMonDeviceId, float * max, float * min, XTime * time);
int SysMonReadMinMaxVccint(u16 SysMonDeviceId, float * max, float * min, XTime * time);
int SysMonReadMinMaxVccaux(u16 SysMonDeviceId, float * max, float * min, XTime * time);



//Setup Uart Interrupt
XUartPs UartPs	;		/* Instance of the UART Device */
INTC InterruptController;	/* Instance of the Interrupt Controller */

#endif
