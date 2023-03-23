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
# @Date      :   2022/07/08
# @License   :   Mulan PSL v2
# @Desc      :   Test ip add ipv6 route
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip -6 route add 1001::2/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 route 1001::2"
    ip -6 route show | grep "1001::/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 route 1001::2"
    ip -6 route add 1002::2/64 via fe80:: dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 route 1002::2"
    ip -6 route show | grep "1002::/64 via fe80::"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 route 1002::2"
    ip -6 route add to 1003::2/64 dev ${NODE1_NIC} table 1
    CHECK_RESULT $? 0 0 "Failed to add ipv6 route 1003::2"
    ip -6 route list table 1 | grep "1003::/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 route 1003::2"
    ip -6 route add default via fe80:: dev ${NODE1_NIC} table 2
    CHECK_RESULT $? 0 0 "Failed to add ipv6 route fe80::"
    ip -6 route list table 2 | grep "via fe80:: dev"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 fe80::"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 route del 1001::2/64 dev ${NODE1_NIC}
    ip -6 route del 1002::2/64 via fe80:: dev ${NODE1_NIC}
    ip -6 route del to 1003::2/64 dev ${NODE1_NIC} table 1
    ip -6 route del default via fe80:: dev ${NODE1_NIC} table 2
    LOG_INFO "End to restore the test environment."
}

main "$@"
