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

#include "tools/graph_kernel/converter/preprocess_weight.h"
#include <utility>
#include <vector>
#include "utils/anf_utils.h"
#include "common/graph_kernel/core/graph_kernel_callback.h"

namespace mindspore::graphkernel {
constexpr size_t kConv2dDataIndex = 1;
constexpr size_t kConv2dWeightIndex = 2;
constexpr size_t kWeightChannelOutAxis = 0;
constexpr size_t kWeightHeightAxis = 1;
constexpr size_t kWeightWidthAxis = 2;
constexpr size_t kWeightChannelInAxis = 3;
constexpr size_t kShapeRank = 4;

std::pair<int64_t, int64_t> TilingChannel(int64_t channel) {
  const int64_t simd_size = 8LL;
  for (auto inner = simd_size; inner > 0; inner--) {
    if (channel % inner == 0) {
      return std::make_pair(channel / inner, inner);
    }
  }
  return {channel, 1LL};
}

class IndexCalc {
 public:
  explicit IndexCalc(const ShapeVector &shape) : shape_(shape) {}
  int64_t GetFlatIndex(const ShapeVector &index) {
    if (index.size() != shape_.size()) {
      MS_LOG(EXCEPTION) << "The index's size should be equal to shape's size, but got " << index.size() << " vs "
                        << shape_.size();
    }
    int64_t prod = 1LL;
    int64_t result = 0LL;
    for (int i = SizeToInt(shape_.size()) - 1; i >= 0; i--) {
      result += index[i] * prod;
      prod *= shape_[i];
    }
    return result;
  }

 private:
  ShapeVector shape_;
};

AnfNodePtr SubstituteConv2D::InferWeightValue(const AnfNodePtr &node) {
  auto cnode = QuickCloneCNode(node);
  auto prim = GetCNodePrimitive(cnode)->Clone();
  cnode->set_input(0, NewValueNode(prim));
  auto cb = Callback::Instance();
  // the weight should be a 4D tensor of format OHWI
  auto weight_shape = cb->GetInputShape(cnode, kConv2dWeightIndex - 1);
  if (weight_shape.size() != kShapeRank) {
    return nullptr;
  }
  auto c_out = weight_shape[kWeightChannelOutAxis];
  auto c_in = weight_shape[kWeightChannelInAxis];
  int64_t c_out_o, c_out_i, c_in_o, c_in_i;
  std::tie(c_out_o, c_out_i) = TilingChannel(c_out);
  std::tie(c_in_o, c_in_i) = TilingChannel(c_in);
  prim->AddAttr("weight_coo", MakeValue(c_out_o));
  prim->AddAttr("weight_coi", MakeValue(c_out_i));
  prim->AddAttr("weight_cio", MakeValue(c_in_o));
  prim->AddAttr("weight_cii", MakeValue(c_in_i));

  auto weight_node = cnode->input(kConv2dWeightIndex)->cast<ValueNodePtr>();
  if (weight_node == nullptr) {
    return nullptr;
  }
  auto tensor = weight_node->value()->cast<tensor::TensorPtr>();
  if (tensor == nullptr) {
    return nullptr;
  }
  if (tensor->data().const_data() == nullptr) {
    return nullptr;
  }
  if (tensor->data_type() != kNumberTypeFloat32) {
    return nullptr;
  }
  auto h_len = weight_shape[kWeightHeightAxis];
  auto w_len = weight_shape[kWeightWidthAxis];

  // step 1, reshape the weight, [O,H,W,I] -> [Oo,Oi,H,W,Io,Ii]
  // step 2, transpose it to [Oo,Io,H,W,Ii,Oi]
  IndexCalc old_shape_calc({c_out_o, c_out_i, h_len, w_len, c_in_o, c_in_i});
  ShapeVector new_shape = {c_out_o, c_in_o, h_len, w_len, c_in_i, c_out_i};
  IndexCalc new_shape_calc(new_shape);
  auto new_tensor = std::make_shared<tensor::Tensor>(tensor->data_type(), new_shape);
  auto new_data = new_tensor->data_c();
  auto old_data = tensor->data_c();
  for (int64_t coo = 0; coo < c_out_o; coo++) {
    for (int64_t cio = 0; cio < c_in_o; cio++) {
      for (int64_t h = 0; h < h_len; h++) {
        for (int64_t w = 0; w < w_len; w++) {
          for (int64_t cii = 0; cii < c_in_i; cii++) {
            for (int64_t coi = 0; coi < c_out_i; coi++) {
              auto old_val = static_cast<float *>(old_data)[old_shape_calc.GetFlatIndex({coo, coi, h, w, cio, cii})];
              static_cast<float *>(new_data)[new_shape_calc.GetFlatIndex({coo, cio, h, w, cii, coi})] = old_val;
            }
          }
        }
      }
    }
  }

  auto v = NewValueNode(new_tensor);
  v->set_abstract(new_tensor->ToAbstract());
  v->set_kernel_info(weight_node->kernel_info_ptr());
  cnode->set_input(kConv2dWeightIndex, v);
  return cnode;
}

AnfNodePtr SubstituteConv2D::Run(const AnfNodePtr &node) {
  auto new_node = InferWeightValue(node);
  if (new_node == nullptr) {
    return nullptr;
  }
  return ExpanderDecorator::Run(new_node);
}

AnfNodePtr MatmulPackB::InferValue(const AnfNodePtr &node) {
  auto cnode = QuickCloneCNode(node);
  MS_EXCEPTION_IF_NULL(cnode);
  const size_t kMatMulWeightIndex = 2;
  const size_t kMatMulWeightRank = 2;
  auto cb = Callback::Instance();
  auto type_id = cb->GetInputType(cnode, kMatMulWeightIndex - 1);
  // only support float32
  if (type_id != kNumberTypeFloat32) {
    MS_LOG(INFO) << "MatmulPackB only supports Float32 but got " << TypeIdToString(type_id);
    return nullptr;
  }
  auto shape = cb->GetInputShape(cnode, kMatMulWeightIndex - 1);
  if (shape.size() != kMatMulWeightRank) {
    MS_LOG(INFO) << "MatmulPackB only supports 2D weight, but got weight of rank " << shape.size();
    return nullptr;
  }
  auto prim = GetCNodePrimitive(cnode);
  auto weight_node = cnode->input(kConv2dWeightIndex)->cast<ValueNodePtr>();
  if (weight_node == nullptr) {
    return nullptr;
  }
  auto tensor = weight_node->value()->cast<tensor::TensorPtr>();
  if (tensor == nullptr) {
    return nullptr;
  }
  if (tensor->data().const_data() == nullptr) {
    return nullptr;
  }

  // infer the transpose_b result
  bool transpose_b = false;
  if (prim->HasAttr("transpose_b")) {
    transpose_b = GetValue<bool>(prim->GetAttr("transpose_b"));
  }
  auto new_tensor = PackB(tensor, shape, transpose_b);
  if (transpose_b) {
    auto new_prim = prim->Clone();
    new_prim->set_attr("transpose_b", MakeValue(false));
    cnode->set_input(0, NewValueNode(new_prim));
  }
  auto v = NewValueNode(new_tensor);
  v->set_abstract(new_tensor->ToAbstract());
  v->set_kernel_info(weight_node->kernel_info_ptr());
  cnode->set_input(kMatMulWeightIndex, v);
  return cnode;
}

/*
Pack(B) example
tensor of shape (3, 7):
[ 1  2  3  4  5  6  7]
[ 8  9 10 11 12 13 14]
[15 16 17 18 19 20 21]
--- pack in size 4, 2, 1  --->
[(1 2 3 4) (8 9 10 11) (15 16 17 18) (5 6) (12 13) (19 20) (7) (14) (21)]
--- reshape to (3, 7)  --->
[ 1  2  3  4  8  9 10]
[11 15 16 17 18  5  6]
[12 13 19 20  7 14 21]
*/
tensor::TensorPtr MatmulPackB::PackB(const tensor::TensorPtr &tensor, const ShapeVector &shape, bool transpose) {
  std::vector<int64_t> pack_size = {24, 16, 8, 4, 2, 1};
  IndexCalc index_calc(shape);
  auto height = shape[0];
  auto width = shape[1];
  if (transpose) {
    std::swap(height, width);
  }
  auto new_tensor = std::make_shared<tensor::Tensor>(tensor->data_type(), std::vector{height, width});
  auto *new_tensor_iter = static_cast<float *>(new_tensor->data_c());
  int64_t width_offset = 0;
  for (auto pack : pack_size) {
    while (width_offset + pack <= width) {
      for (int64_t i = 0; i < height; ++i) {
        for (int64_t j = 0; j < pack; ++j) {
          if (transpose) {
            *new_tensor_iter++ = static_cast<float *>(tensor->data_c())[index_calc.GetFlatIndex({j + width_offset, i})];
          } else {
            *new_tensor_iter++ = static_cast<float *>(tensor->data_c())[index_calc.GetFlatIndex({i, j + width_offset})];
          }
        }
      }
      width_offset += pack;
    }
  }
  return new_tensor;
}

AnfNodePtr MatmulPackB::Run(const AnfNodePtr &node) {
  auto new_node = InferValue(node);
  if (new_node == nullptr) {
    return nullptr;
  }
  return ExpanderDecorator::Run(new_node);
}
}  // namespace mindspore::graphkernel
