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
# @Desc      :   Test bridge
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL bridge-utils
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    brctl addbr br0
    CHECK_RESULT $? 0 0 "Failed to add br0"
    ip a | grep br0
    CHECK_RESULT $? 0 0 "Failed to show br0"
    ip -4 addr add 127.127.0.1/24 dev br0
    CHECK_RESULT $? 0 0 "Failed to add ipv4 127.127.0.1"
    ip -4 addr show | grep "127.127.0.1/24"
    CHECK_RESULT $? 0 0 "Failed to show ipv4 127.127.0.1"
    ip -6 addr add ::3/24 dev br0
    CHECK_RESULT $? 0 0 "Failed to add ipv6 ::3"
    ip -6 addr show | grep "::3/24"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 ::3"
    ip -4 addr del 127.127.0.1/24 dev br0
    CHECK_RESULT $? 0 0 "Failed to delete ipv4 127.127.0.1"
    ip -4 addr show | grep "127.127.0.1/24"
    CHECK_RESULT $? 0 1 "Successfully display ipv4 127.127.0.1"
    ip -6 addr del ::3/24 dev br0
    CHECK_RESULT $? 0 0 "Failed to delete ipv6 ::3"
    ip -6 addr show | grep "::3/24"
    CHECK_RESULT $? 0 1 "Successfully display ipv6 ::3"
    brctl delbr br0
    CHECK_RESULT $? 0 0 "Failed to delete br0"
    ip a | grep -w br0
    CHECK_RESULT $? 0 1 "Failed to delete br0"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
