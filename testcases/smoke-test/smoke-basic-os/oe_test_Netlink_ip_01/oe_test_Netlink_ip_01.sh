#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Hulk supports ipv4\ipv6 network netlink interface
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL  strace
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    strace ip -6 addr add fe80::9ee3:74ff:fe0c:99f1/64 dev ${NODE1_NIC} 2>&1 | grep "socket(AF_NETLINK"
    CHECK_RESULT $? 0 0 "Set ipv6: failed!"
    strace ip -4 addr add 9.82.35.6/16 dev ${NODE1_NIC} 2>&1 | grep "socket(AF_NETLINK"
    CHECK_RESULT $? 0 0 "Set ipv4: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    ip address del 9.82.35.6/16 dev ${NODE1_NIC}
    ip address del fe80::9ee3:74ff:fe0c:99f1/64 dev ${NODE1_NIC}
    LOG_INFO "End to restore the test environment."
}

main "$@"
