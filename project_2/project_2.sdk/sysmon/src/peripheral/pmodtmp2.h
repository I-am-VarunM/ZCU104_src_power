/*
 * pmodtmp2.h
 *
 *  Created on: Nov 14, 2019
 *      Author: Carina
 */

#ifndef SRC_PERIPHERAL_PMODTMP2_H_
#define SRC_PERIPHERAL_PMODTMP2_H_
#include "xparameters.h"
#include "xil_printf.h"
#include "xtime_l.h"

#define IIC_SLAVE_ADDR_PMODTMP2		0x4B


#define PMODTMP2_TMP_MSB_REG	0x00
#define PMODTMP2_TMP_LSB_REG	0x01
#define PMODTMP2_STATUS_REG		0x02
#define PMODTMP2_CONFIG_REG		0x03
#define PMODTMP2_ID_REG			0x0B
#define PMODTMP2_SW_SRT_REG		0x2F

#define PMODTMP2_CONFIG_FAULT_QUEUE_1 				0x00
#define PMODTMP2_CONFIG_FAULT_QUEUE_2 				0x01
#define PMODTMP2_CONFIG_FAULT_QUEUE_3 				0x02
#define PMODTMP2_CONFIG_FAULT_QUEUE_4 				0x03
#define PMODTMP2_CONFIG_CT_POLARITY 				0x04
#define PMODTMP2_CONFIG_INT_POLARITY 				0x08
#define PMODTMP2_CONFIG_COMPARATOR_MODE				0x10
#define PMODTMP2_CONFIG_OPERATION_MODE_CONTINUOUS 	0x00
#define PMODTMP2_CONFIG_OPERATION_MODE_ONE_SHOT 	0x20
#define PMODTMP2_CONFIG_OPERATION_MODE_SPS			0x40
#define PMODTMP2_CONFIG_OPERATION_MODE_SHUTDOWN		0x60
#define PMODTMP2_CONFIG_HIGH_RESOLUTION					0x80

int configurePmodtmp2();
float readTmpFromPmodtmp2(float * value, XTime * time);
float convertTmpRawToFloatPmodtmp2(u8 msb, u8 lsb);

#endif /* SRC_PERIPHERAL_PMODTMP2_H_ */
