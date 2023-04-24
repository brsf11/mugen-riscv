#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/06
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of ethool
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    GSO_init=$(ethtool -k ${NODE1_NIC} | grep "generic-segmentation-offload:" | awk '{print $NF}')
    GRO_init=$(ethtool -k ${NODE1_NIC} | grep "generic-receive-offload:" | awk '{print $NF}')
    TSO_init=$(ethtool -k ${NODE1_NIC} | grep "tcp-segmentation-offload:" | awk '{print $NF}')
    TX_init=$(ethtool -k ${NODE1_NIC} | grep "tx-checksumming:" | awk '{print $NF}')
    SG_init=$(ethtool -k ${NODE1_NIC} | grep "scatter-gather:" | awk '{print $NF}')

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ethtool -K ${NODE1_NIC} sg on
    ethtool -K ${NODE1_NIC} gso on
    CHECK_RESULT $? 0 0 "GSO open failed"
    ethtool -k ${NODE1_NIC} | grep "generic-segmentation-offload: on"
    CHECK_RESULT $? 0 0 "Check GSO open failed"
    ethtool -K ${NODE1_NIC} gso off
    CHECK_RESULT $? 0 0 "GSO shut off failed"
    ethtool -k ${NODE1_NIC} | grep "generic-segmentation-offload: off"
    CHECK_RESULT $? 0 0 "Check GSO shut off failed"
    ethtool -K ${NODE1_NIC} gro on
    CHECK_RESULT $? 0 0 "GRO open failed"
    ethtool -k ${NODE1_NIC} | grep "generic-receive-offload: on"
    CHECK_RESULT $? 0 0 "Check GRO open failed"
    ethtool -K ${NODE1_NIC} gro off
    CHECK_RESULT $? 0 0 "GRO shut off failed"
    ethtool -k ${NODE1_NIC} | grep "generic-receive-offload: off"
    CHECK_RESULT $? 0 0 "Check GRO shut off failed"
    ethtool -K ${NODE1_NIC} tx on
    ethtool -K ${NODE1_NIC} tso on
    CHECK_RESULT $? 0 0 "TSO open failed"
    ethtool -k ${NODE1_NIC} | grep "tcp-segmentation-offload: on"
    CHECK_RESULT $? 0 0 "Check TSO open failed"
    ethtool -K ${NODE1_NIC} tso off
    CHECK_RESULT $? 0 0 "TSO shut off failed"
    ethtool -k ${NODE1_NIC} | grep "tcp-segmentation-offload: off"
    CHECK_RESULT $? 0 0 "Check TSO shut off failed"
    ethtool -K ${NODE1_NIC} tx on
    CHECK_RESULT $? 0 0 "TX open failed"
    ethtool -k ${NODE1_NIC} | grep "tx-checksumming: on"
    CHECK_RESULT $? 0 0 "Check TX open failed"
    ethtool -K ${NODE1_NIC} tx off
    CHECK_RESULT $? 0 0 "TX shut off failed"
    ethtool -k ${NODE1_NIC} | grep "tx-checksumming: off"
    CHECK_RESULT $? 0 0 "Check TX shut off failed"
    ethtool -K ${NODE1_NIC} sg on
    CHECK_RESULT $? 0 0 "SG open failed"
    ethtool -k ${NODE1_NIC} | grep "scatter-gather: on"
    CHECK_RESULT $? 0 0 "Check SG open failed"
    ethtool -K ${NODE1_NIC} sg off
    CHECK_RESULT $? 0 0 "SG shut off failed"
    ethtool -k ${NODE1_NIC} | grep "scatter-gather: off"
    CHECK_RESULT $? 0 0 "Check SG shut off failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ethtool -K ${NODE1_NIC} gso ${GSO_init}
    ethtool -K ${NODE1_NIC} gro ${GRO_init}
    ethtool -K ${NODE1_NIC} tso ${TSO_init}
    ethtool -K ${NODE1_NIC} tx ${TX_init}
    ethtool -K ${NODE1_NIC} sg ${SG_init}
    LOG_INFO "End to restore the test environment."
}

main "$@"
