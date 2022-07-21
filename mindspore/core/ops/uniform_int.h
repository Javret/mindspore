/**
 * Copyright 2022 Huawei Technologies Co., Ltd
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

#ifndef MINDSPORE_CORE_OPS_UNIFORM_INT_H_
#define MINDSPORE_CORE_OPS_UNIFORM_INT_H_
#include <map>
#include <vector>
#include <string>
#include <memory>

#include "ops/base_operator.h"
#include "mindapi/base/types.h"

namespace mindspore {
namespace ops {
constexpr auto kNameUniformInt = "UniformInt";
/// \brief Produces random floating-point values i, uniformly distributed to the interval [minval, maxval).
/// Refer to Python API @ref mindspore.ops.UniformReal for more details.

class MIND_API UniformInt : public BaseOperator {
 public:
  MIND_API_BASE_MEMBER(UniformInt);
  /// \brief Constructor.
  UniformInt() : BaseOperator(kNameUniformInt) { InitIOName({"shape", "minval", "maxval"}, {"output"}); }
  /// \brief Init. Refer to the parameters of Python API @ref mindspore.ops.UniformInt for the inputs.
  void Init(int64_t seed, int64_t seed2);
  /// \brief Set seed.
  void set_seed(int64_t seed);
  /// \brief Set seed2.
  void set_seed2(int64_t seed2);
  /// \brief Get seed.
  ///
  /// \return seed.
  int64_t get_seed() const;
  /// \brief Get seed2.
  ///
  /// \return seed2.
  int64_t get_seed2() const;
};

abstract::AbstractBasePtr UniformIntInfer(const abstract::AnalysisEnginePtr &, const PrimitivePtr &primitive,
                                          const std::vector<abstract::AbstractBasePtr> &input_args);
}  // namespace ops
}  // namespace mindspore

#endif  // MINDSPORE_CORE_OPS_UNIFORM_INT_H_
