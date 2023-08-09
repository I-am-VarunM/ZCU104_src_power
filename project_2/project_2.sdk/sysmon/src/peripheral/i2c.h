/*
 * i2c.h
 *
 *  Created on: Nov 14, 2019
 *      Author: Carina
 */

#ifndef SRC_PERIPHERAL_I2C_H_
#define SRC_PERIPHERAL_I2C_H_

#include "xparameters.h"
#include "xil_printf.h"

/************************** Constant Definitions ******************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define IIC_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID


#define DELAY_AFTER_WRITE	250


/**************************** Type Definitions ********************************/


/************************** Function Prototypes *******************************/

int IicPsMasterPolled(u16 DeviceId, u16 SlaveAddr, u16 sclk_rate);
int IicPsMasterSetup(u16 DeviceId, u16 sclk_rate);
int IicPsMasterWriteReg(u16 SlaveAddr, u8 configReg, u8 configData);
int IicPsMasterReadReg(u16 SlaveAddr, u8 configReg, u8 * configData, u8 byteCount);

#endif /* SRC_PERIPHERAL_I2C_H_ */
