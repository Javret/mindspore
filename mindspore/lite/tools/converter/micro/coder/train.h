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

#ifndef MINDSPORE_LITE_TOOLS_CONVERTER_MICRO_CODER_TRAIN_H_
#define MINDSPORE_LITE_TOOLS_CONVERTER_MICRO_CODER_TRAIN_H_

#include <memory>
#include <vector>
#include "coder/context.h"
#include "coder/opcoders/op_coder.h"

namespace mindspore::lite::micro {
class Train {
 public:
  static int TransformGraphForTrain(CoderContext *context, const std::vector<std::unique_ptr<OperatorCoder>> &op_coders,
                                    int schema_version);
};
}  // namespace mindspore::lite::micro
#endif  // MINDSPORE_LITE_TOOLS_CONVERTER_MICRO_CODER_TRAIN_H_