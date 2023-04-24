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
# @Date      :   2022/07/11
# @License   :   Mulan PSL v2
# @Desc      :   Test route add ipv6 route
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL net-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    route -A inet6 add 5001::/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add route 5001::"
    route -A inet6 | grep "5001::/64"
    CHECK_RESULT $? 0 0 "Failed to show route 5001::"
    ip -6 addr add 1111:1111:1111:1111:1111:1111:1111:1111/64 dev ${NODE1_NIC}
    route -A inet6 add 1112::/64 gw 1111:1111:1111:1111::
    CHECK_RESULT $? 0 0 "Failed to add route 1112::"
    route -A inet6 | grep "1112::/64"
    CHECK_RESULT $? 0 0 "Failed to show route 1112::"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    route -A inet6 del 5001::/64
    route -A inet6 del 1112::/64
    ip -6 addr del 1111:1111:1111:1111:1111:1111:1111:1111/64 dev ${NODE1_NIC}
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
