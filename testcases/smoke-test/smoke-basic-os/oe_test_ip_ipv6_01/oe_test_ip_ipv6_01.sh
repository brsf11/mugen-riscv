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
# @Desc      :   Test add ipv6
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip -6 address add 1001::1/64 dev ${NODE1_NIC} label ${NODE1_NIC}:1
    CHECK_RESULT $? 0 0 "Failed to add ipv6 1001::1"
    ip -6 address show dev ${NODE1_NIC} | grep inet6 | grep "1001::1/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 1001::1"
    ip -6 address del ::1/128 dev lo scope host
    CHECK_RESULT $? 0 0 "Failed to delete ipv6 ::1"
    ip -6 address add ::1/128 dev lo scope host
    CHECK_RESULT $? 0 0 "Failed to add ipv6 ::1"
    ip -6 address show scope host | grep "::1/128"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 ::1"
    ip -6 address add fe80::2e0:fcff:fe09:fffe/64 dev ${NODE1_NIC} scope link
    CHECK_RESULT $? 0 0 "Failed to add ipv6 fe80::"
    ip -6 address show dev ${NODE1_NIC} scope link | grep "fe80::2e0:fcff:fe09:fffe/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 fe80::"
    ip -6 address add 1001::4/64 dev ${NODE1_NIC} valid_lft 3600 preferred_lft 3600
    CHECK_RESULT $? 0 0 "Failed to add valid_lft"
    ip -6 address show dev ${NODE1_NIC} | grep "001::4/64" -A 1 | grep sec
    CHECK_RESULT $? 0 0 "Failed to show valid_lft"
    ip -6 address add 1001::5/64 dev ${NODE1_NIC} home
    CHECK_RESULT $? 0 0 "Failed to add home"
    ip -6 address show dev ${NODE1_NIC} | grep "1001::5/64 scope global home"
    CHECK_RESULT $? 0 0 "Failed to show home"
    ip -6 address add 1001::6/64 dev ${NODE1_NIC} nodad
    CHECK_RESULT $? 0 0 "Failed to add nodad"
    ip -6 address show dev ${NODE1_NIC} | grep "1001::6/64 scope global nodad"
    CHECK_RESULT $? 0 0 "Failed to show nodad"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 address del 1001::1/64 dev ${NODE1_NIC} label ${NODE1_NIC}:1
    ip -6 address del fe80::2e0:fcff:fe09:fffe/64 dev ${NODE1_NIC} scope link
    ip -6 address del 1001::4/64 dev ${NODE1_NIC} valid_lft 3600 preferred_lft 3600
    ip -6 address del 1001::5/64 dev ${NODE1_NIC} home
    ip -6 address del 1001::6/64 dev ${NODE1_NIC} nodad
    LOG_INFO "End to restore the test environment."
}

main "$@"
