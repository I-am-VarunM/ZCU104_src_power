/*
 * system_test.c
 *
 *  Created on: Aug 31, 2019
 *      Author: Carina
 */

/*
 *
 *
 * This file is a generated sample test application.
 *
 * This application is intended to test and/or illustrate some
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * SDK application project when you run the "Generate Libraries" menu item.
 *
 */

#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "scugic_header.h"
#include "xsysmonpsu.h"
#include "sysmonpsu_header.h"
#include "xgpio.h"
#include "gpio_header.h"
#include "system_test.h"

int run_system_test(XScuGic * intc, XSysMonPsu * psu_ams){
	int result = XST_SUCCESS;
	{
	  int Status;


	  print("\r\n Running ScuGicSelfTestExample() for psu_acpu_gic...\r\n");

	  Status = ScuGicSelfTestExample(XPAR_PSU_ACPU_GIC_DEVICE_ID);

	  if (Status == 0) {
		 print("ScuGicSelfTestExample PASSED\r\n");
	  }
	  else {
		 print("ScuGicSelfTestExample FAILED\r\n");
		 result = XST_FAILURE;
	  }
	}

	{
	   int Status;

	   Status = ScuGicInterruptSetup(intc, XPAR_PSU_ACPU_GIC_DEVICE_ID);
	   if (Status == 0) {
		  print("ScuGic Interrupt Setup PASSED\r\n");
	   }
	   else {
		 print("ScuGic Interrupt Setup FAILED\r\n");
		 result = XST_FAILURE;
	  }
	}



	{
		int Status;

		print("\r\n Running SysMonPsuPolledPrintfExample() for psu_ams...\r\n");

		Status = SysMonPsuPolledPrintfExample(XPAR_PSU_AMS_DEVICE_ID);

		if (Status == 0) {
			print("SysMonPsuPolledPrintfExample PASSED\r\n");
		}
		else {
			print("SysMonPsuPolledPrintfExample FAILED\r\n");
			 result = XST_FAILURE;
		}
	}



   {
      u32 status;

      print("\r\nRunning GpioOutputExample() for axi_gpio_0...\r\n");

      status = GpioOutputExample(XPAR_AXI_GPIO_0_DEVICE_ID,4);

      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
		 result = XST_FAILURE;
      }
   }



   return result;
}

