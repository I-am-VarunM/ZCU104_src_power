/*
 * mlmodel.h
 *
 *  Created on: Mar 18, 2020
 *      Author: Carina
 */

#define RUN_NOT_STANDALONE

#ifndef SRC_CLASSIFIER_MLMODEL_H_
#define SRC_CLASSIFIER_MLMODEL_H_

#define N_FEATURES 1
#define N_CLASSES 2

int predict(double features[N_FEATURES], int node);

#endif /* SRC_CLASSIFIER_MLMODEL_H_ */
