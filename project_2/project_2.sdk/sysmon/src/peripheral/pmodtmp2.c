/*
 * pmodtmp2.c
 *
 *  Created on: Nov 14, 2019
 *      Author: Carina
 */

#include "i2c.h"
#include "pmodtmp2.h"
#include "xstatus.h"
#include "sleep.h"
#include <stdio.h>
#include "xtime_l.h"
#include "uart_header.h"
#include "sysmon_header.h"
#include "uart_header.h"
#include "xuartps.h"

#define TEST_MODULE_PMODTMP2

#ifndef TEST_MODULE_PMODTMP2
int main(void){
	int Status = 0;
	Status = configurePmodtmp2();
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Configuration PMOD Failed\r\n");
		return XST_FAILURE;
	}
	for(int i = 0; i < 100; i++){
		float value =0;
		XTime time = 0;
		printf("Temperatur of PMODTMP2: %.4f\n",readTmpFromPmodtmp2(&value, &time));
		printf("The Current PSU Temperature is %0d.%03d Centigrades (time: %lu).\r\n",
					(int)(value), SysMonPsuFractionToInt(value), time);
		usleep(500000);
	}
}
#endif

int configurePmodtmp2(){
	u8 configData = 0;
	int Status =0;
	//SW RST
	Status = IicPsMasterWriteReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_SW_SRT_REG, configData);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Write Failed\r\n");
		return XST_FAILURE;
	}

	//Configuration
	configData = PMODTMP2_CONFIG_OPERATION_MODE_CONTINUOUS | PMODTMP2_CONFIG_HIGH_RESOLUTION;
	Status = IicPsMasterWriteReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_CONFIG_REG, configData);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Write Failed\r\n");
		return XST_FAILURE;
	}

	u8 readData = 0;
	Status =  IicPsMasterReadReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_CONFIG_REG, &readData, 1);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Read Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("config = 0x%x\n",readData);

	readData = 0;
	Status =  IicPsMasterReadReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_STATUS_REG, &readData, 1);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Read Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("Stauts = 0x%x\n",readData);

	readData = 0;
	Status =  IicPsMasterReadReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_ID_REG, &readData, 1);
	if (Status != XST_SUCCESS) {
		xil_printf("IIC Master Read Failed\r\n");
		return XST_FAILURE;
	}

	xil_printf("ID = 0x%x\n",readData);
	return XST_SUCCESS;

}


float readTmpFromPmodtmp2(float * value, XTime * time){
	u8 lsb = 0, msb = 0;
	u8 tmp[2];
	//XTime * Xtime = 0;
	IicPsMasterReadReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_TMP_MSB_REG, tmp, 2);
	XTime_GetTime(time);
	//char * msg = NULL;
			//* st = NULL;
	//* st = 0;
	*value = convertTmpRawToFloatPmodtmp2(tmp[0], tmp[1]);
	//int fraction = (temp - ((int)temp)) * 1000;
	//printf("Temperatur of PMODTMP2: %.4f, fraction %i\n",temp, fraction);
	//gcvt(temp, 2, st);
	//printf("%s", st);
	//printf("The Current PSU Temperature is %0d.%03d Centigrades (time: %lu).\r\n",
	//			(int)(TempData), SysMonPsuFractionToInt(TempData), *Xtime);

	//asiprintf(&msg,"The Current Ambient Temperature is %0d.%03d Centigrades (time: %lu).\n",(int)temp,fraction, *Xtime);
	//int size = strlen(msg);
	//printf("%s", msg);
	//sendUart(&UartPs, msg, size);
	//free(msg);
	//free(st);
	//IicPsMasterReadReg(IIC_SLAVE_ADDR_PMODTMP2, PMODTMP2_TMP_LSB_REG, &lsb);
	return ;
}

float convertTmpRawToFloatPmodtmp2(u8 msb, u8 lsb){
	int raw = (msb << 8) | lsb;
	return (((float)raw)/128);
}
