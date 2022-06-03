/**
 * Copyright 2020-2022 Huawei Technologies Co., Ltd
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

#ifndef MINDSPORE_CORE_OPS_MVLGAMMA_GRAD_H_
#define MINDSPORE_CORE_OPS_MVLGAMMA_GRAD_H_
#include <map>
#include <string>
#include <vector>
#include <memory>
#include "ops/primitive_c.h"
#include "ops/op_utils.h"
#include "abstract/abstract_value.h"
#include "utils/check_convert_utils.h"
#include "ops/base_operator.h"
#include "mindapi/base/types.h"

namespace mindspore {
namespace ops {
constexpr auto kNameMvlgammaGrad = "MvlgammaGrad";
class MIND_API MvlgammaGrad : public BaseOperator {
 public:
  MIND_API_BASE_MEMBER(MvlgammaGrad);
  MvlgammaGrad() : BaseOperator(kNameMvlgammaGrad) { InitIOName({"y_grad", "x"}, {"x_grad"}); }
  void Init(const int64_t p = 0);
  /// \brief Set p.
  void set_p(const int64_t p);
  int64_t get_p() const;
  // ~MvlgammaGrad() = default;
  // MS_DECLARE_PARENT(MvlgammaGrad, PrimitiveC);
};

abstract::AbstractBasePtr MvlgammaGradInfer(const abstract::AnalysisEnginePtr &, const PrimitivePtr &primitive,
                                            const std::vector<AbstractBasePtr> &input_args);
using PrimMvlgammaGradPtr = std::shared_ptr<MvlgammaGrad>;
}  // namespace ops
}  // namespace mindspore

#endif  // MINDSPORE_CORE_OPS_MVLGAMMA_GRAD_H_
