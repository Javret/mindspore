# Copyright 2020 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

import numpy as np
import pytest

import mindspore.context as context
import mindspore.nn as nn
from mindspore import Tensor
from mindspore.ops import operations as P

context.set_context(mode=context.GRAPH_MODE, device_target='CPU')


class OpNetWrapper(nn.Cell):
    def __init__(self, op):
        super(OpNetWrapper, self).__init__()
        self.op = op

    def construct(self, *inputs):
        return self.op(*inputs)


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_int32():
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, 3]).astype(np.int32))
    input_y = Tensor(np.array([3, 2, 1]).astype(np.int32))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [False, True, True])


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_float32():
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, -1]).astype(np.float32))
    input_y = Tensor(np.array([-3, 2, -1]).astype(np.float32))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [True, True, True])


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_float64():
    """
    Feature: ALL To ALL
    Description: test cases for GreaterEqual of float64
    Expectation: the result match to numpy
    """
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, -1]).astype(np.float64))
    input_y = Tensor(np.array([-3, 2, -1]).astype(np.float64))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [True, True, True])


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_uint8():
    """
    Feature: ALL To ALL
    Description: test cases for GreaterEqual of uint8
    Expectation: the result match to numpy
    """
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, -1]).astype(np.uint8))
    input_y = Tensor(np.array([-3, 2, -1]).astype(np.uint8))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [False, True, True])


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_int8():
    """
    Feature: ALL To ALL
    Description: test cases for GreaterEqual of int8
    Expectation: the result match to numpy
    """
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, -1]).astype(np.int8))
    input_y = Tensor(np.array([-3, 2, -1]).astype(np.int8))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [True, True, True])


@pytest.mark.level0
@pytest.mark.platform_x86_cpu
@pytest.mark.env_onecard
def test_float16():
    """
    Feature: ALL To ALL
    Description: test cases for GreaterEqual of float16
    Expectation: the result match to numpy
    """
    op = P.GreaterEqual()
    op_wrapper = OpNetWrapper(op)

    input_x = Tensor(np.array([1, 2, -1]).astype(np.float16))
    input_y = Tensor(np.array([-3, 2, -1]).astype(np.float16))
    outputs = op_wrapper(input_x, input_y)

    print(outputs)
    assert outputs.shape == (3,)
    assert np.allclose(outputs.asnumpy(), [True, True, True])


if __name__ == '__main__':
    test_int32()
    test_float32()
