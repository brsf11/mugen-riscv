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
# @Date      :   2022/07/07
# @License   :   Mulan PSL v2
# @Desc      :   Test configure ipv6 vlan
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    ip link add dev vlan.1 link ${NODE1_NIC} type vlan id 1
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ip -4 addr add 127.127.0.1/24 dev vlan.1
    CHECK_RESULT $? 0 0 "Failed to add ipv4"
    ip -4 addr show | grep "127.127.0.1/24"
    CHECK_RESULT $? 0 0 "Failed to show ipv4"
    ip -6 addr add ::3/24 dev vlan.1
    CHECK_RESULT $? 0 0 "Failed to add ipv6"
    ip -6 addr show | grep "::3/24"
    CHECK_RESULT $? 0 0 "Failed to show ipv6"
    ip -4 addr del 127.127.0.1/24 dev vlan.1
    CHECK_RESULT $? 0 0 "Failed to delete ipv4"
    ip -4 addr show | grep "127.127.0.1/24"
    CHECK_RESULT $? 0 1 "Succeed to show ipv4"
    ip -6 addr del ::3/24 dev vlan.1
    CHECK_RESULT $? 0 0 "Failed to delete ipv6"
    ip -6 addr show | grep "::3/24"
    CHECK_RESULT $? 0 1 "Succeed to show ipv6"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip link del dev vlan.1 link ${NODE1_NIC} type vlan id 1
    LOG_INFO "End to restore the test environment."
}

main "$@"
