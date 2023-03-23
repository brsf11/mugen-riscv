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
# @Date      :   2022/07/15
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of traceroute6 -n
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL traceroute
    ip -6 address add fe80::2e0:fcff:fe09:fffd/64 dev ${NODE1_NIC} scope link
    ip -6 address add fe80::2e0:fcff:fe09:fffe/64 dev ${NODE1_NIC} scope link
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SLEEP_WAIT 3
    traceroute6 -n fe80::2e0:fcff:fe09:fffe%${NODE1_NIC} | grep "fe80::2e0:fcff:fe09:fffe\%${NODE1_NIC}" | grep "ms"
    CHECK_RESULT $? 0 0 "Failed to execute traceroute6"
    traceroute6 -n fe80::2e0:fcff:fe09:fffd%${NODE1_NIC} | grep "fe80::2e0:fcff:fe09:fffd\%${NODE1_NIC}" | grep "ms"
    CHECK_RESULT $? 0 0 "Failed to repeat execute traceroute6"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 address del fe80::2e0:fcff:fe09:fffd/64 dev ${NODE1_NIC} scope link
    ip -6 address del fe80::2e0:fcff:fe09:fffe/64 dev ${NODE1_NIC} scope link
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
