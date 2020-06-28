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
""" test lazy adam """
import numpy as np
import pytest

import mindspore.nn as nn
from mindspore import Tensor, Parameter
from mindspore.common.api import _executor
from mindspore.nn import TrainOneStepCell, WithLossCell
from mindspore.nn.optim import LazyAdam
from mindspore.ops import operations as P


class Net(nn.Cell):
    """ Net definition """

    def __init__(self):
        super(Net, self).__init__()
        self.weight = Parameter(Tensor(np.ones([64, 10]).astype(np.float32)), name="weight")
        self.bias = Parameter(Tensor(np.ones([10]).astype((np.float32))), name="bias")
        self.matmul = P.MatMul()
        self.biasAdd = P.BiasAdd()

    def construct(self, x):
        x = self.biasAdd(self.matmul(x, self.weight), self.bias)
        return x


class NetWithSparseGatherV2(nn.Cell):
    """ NetWithSparseGatherV2 definition """
    def __init__(self):
        super(NetWithSparseGatherV2, self).__init__()
        self.weight1 = Parameter(Tensor(np.ones([3, 1, 2]).astype(np.float32)),
                                 name="weight1", sparse_grad="sparse_key_w1")
        self.weight2 = Parameter(Tensor(np.ones([2, 1, 2]).astype((np.float32))), name="weight2")
        self.axis = 0
        self.gather = P.SparseGatherV2()

    def construct(self, indices, label):
        return self.gather(self.weight1, indices, self.axis) + self.weight2


def test_lazy_adam_compile():
    """ test lazy adam compile """
    inputs = Tensor(np.ones([1, 64]).astype(np.float32))
    label = Tensor(np.zeros([1, 10]).astype(np.float32))
    net = Net()
    net.set_train()

    loss = nn.SoftmaxCrossEntropyWithLogits()
    optimizer = LazyAdam(net.trainable_params(), learning_rate=0.1, weight_decay=0.9, loss_scale=2.0)

    net_with_loss = WithLossCell(net, loss)
    train_network = TrainOneStepCell(net_with_loss, optimizer)
    _executor.compile(train_network, inputs, label)


def test_spares_lazy_adam_compile():
    """ test sparse adam compile """
    indices = Tensor(np.array([0, 1]).astype(np.int32))
    label = Tensor(np.zeros([2, 1, 2]).astype(np.float32))
    net = NetWithSparseGatherV2()
    net.set_train()

    optimizer = LazyAdam(net.trainable_params(), learning_rate=0.1, weight_decay=0.9, loss_scale=2.0)
    train_network = TrainOneStepCell(net, optimizer)
    _executor.compile(train_network, indices, label)


def test_lazy_adam_error():
    net = Net()
    with pytest.raises(ValueError):
        LazyAdam(net.get_parameters(), learning_rate=-0.1)

    with pytest.raises(TypeError):
        LazyAdam(net.get_parameters(), learning_rate=0.1, beta1=2)
