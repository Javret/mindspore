/**
 * Copyright 2021 Huawei Technologies Co., Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef MINDSPORE_NNACL_EXPERIMENT_CONV_H_
#define MINDSPORE_NNACL_EXPERIMENT_CONV_H_
#include "nnacl/conv_parameter.h"
#include "nnacl/kernel.h"

typedef struct KConv2d {
  KernelBase base;
  char *im2colBuf;
  char *packedWeight;
} KConv2d;

#ifdef __cplusplus
extern "C" {
#endif
KernelBase *CreateConv(OpParameter *param, TensorC *in[], size_t insize, TensorC *out[], size_t outsize);
#ifdef __cplusplus
}
#endif
#endif