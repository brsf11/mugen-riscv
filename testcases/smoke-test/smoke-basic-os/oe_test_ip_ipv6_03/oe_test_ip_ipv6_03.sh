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
# @Desc      :   Test ip show ipv6 config
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip -6 address show permanent
    CHECK_RESULT $? 0 0 "Failed to show permanent"
    ip -6 address show dynamic
    CHECK_RESULT $? 0 0 "Failed to show dynamic"
    ip -6 address show tentative
    CHECK_RESULT $? 0 0 "Failed to show tentative"
    ip -6 address show deprecated
    CHECK_RESULT $? 0 0 "Failed to show deprecated"
    ip -6 addr show dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to show ${NODE1_NIC}"
    ip -6 addr show dev eth10 2>&1 | grep 'Device "eth10" does not exist'
    CHECK_RESULT $? 0 0 "Successd to show"
    ip -6 addr show scope host | grep host
    CHECK_RESULT $? 0 0 "Failed to show host"
    ip -6 addr show scope link | grep link
    CHECK_RESULT $? 0 0 "Failed to show link"
    ip -6 address add 1001::5/64 dev ${NODE1_NIC} home
    ip -6 addr show scope global
    CHECK_RESULT $? 0 0 "Failed to show global"
    ip -6 address show label ${NODE1_NIC} | grep inet6
    CHECK_RESULT $? 0 0 "Failed to show inet6"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 address del 1001::5/64 dev ${NODE1_NIC} home
    LOG_INFO "End to restore the test environment."
}

main "$@"
