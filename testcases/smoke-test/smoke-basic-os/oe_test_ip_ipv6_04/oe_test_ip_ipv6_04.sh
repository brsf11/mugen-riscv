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
# @Desc      :   Test ifconfig add ipv6
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL net-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ifconfig ${NODE1_NIC} inet6 add 4::4/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6 4::4"
    ifconfig ${NODE1_NIC} | grep "4::4"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 4::4"
    ifconfig ${NODE1_NIC} add 1111:1111:1111:1111:1111:1111:1111:1111/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6 1111:"
    ifconfig ${NODE1_NIC} | grep "1111:1111:1111:1111:1111:1111:1111:1111"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 1111:"
    ifconfig ${NODE1_NIC} add 2001:da8:8000:d010:0:5efe:3.3.3.3/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6 2001:"
    ifconfig ${NODE1_NIC} | grep "2001:da8:8000:d010:0:5efe:3.3.3.3"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 2001:"
    ifconfig ${NODE1_NIC} add 7::7/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6 7::7"
    ifconfig ${NODE1_NIC} | grep "7::7"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 7::7"
    ifconfig ${NODE1_NIC} add 9000:0000:0000:0000:0000:0000:0000:0009/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6 9000:"
    ifconfig ${NODE1_NIC} | grep "9000::9"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 9000:"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ifconfig ${NODE1_NIC} inet6 del 4::4/64
    ifconfig ${NODE1_NIC} del 1111:1111:1111:1111:1111:1111:1111:1111/64
    ifconfig ${NODE1_NIC} del 2001:da8:8000:d010:0:5efe:3.3.3.3/64
    ifconfig ${NODE1_NIC} del 7::7/64
    ifconfig ${NODE1_NIC} del 9000:0000:0000:0000:0000:0000:0000:0009/64
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
