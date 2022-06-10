# Copyright 2022 Huawei Technologies Co., Ltd
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
""" test graph fallback control flow."""
import pytest
import numpy as np
from mindspore import Tensor, ms_function, context

context.set_context(mode=context.GRAPH_MODE)


@pytest.mark.level0
@pytest.mark.platform_x86_gpu_training
@pytest.mark.platform_arm_ascend_training
@pytest.mark.platform_x86_ascend_training
@pytest.mark.env_onecard
def test_if_after_for_in_if_tensor():
    """
    Feature: JIT Fallback
    Description: Test fallback with control flow.
    Expectation: No exception.
    """
    @ms_function
    def control_flow_if_after_for_in_if():
        x = Tensor([1])
        y = Tensor([2])
        z = Tensor([7])
        if y > x and x < z:
            for _ in range(3):
                y -= x
            z = z + y
        if x + y >= z:
            y = y * x - z
        return y + z
    res = control_flow_if_after_for_in_if()
    assert res == 5


@pytest.mark.skip(reason='Not support graph fallback feature yet')
def test_if_after_for_in_if_numpy():
    """
    Feature: JIT Fallback
    Description: Test fallback with control flow.
    Expectation: No exception.
    """
    @ms_function
    def control_flow_if_after_for_in_if():
        x = np.array([1, 2])
        y = np.array([3, 4])
        z = np.array([1, 2, 3, 4])
        if len(x) == len(y):
            for _ in range(3):
                y += x
            z = z + y[0]
        if len(x) + len(y) == len(z):
            return Tensor(y)
        return Tensor(z)
    res = control_flow_if_after_for_in_if()
    assert (res.asnumpy() == [6, 10]).all()