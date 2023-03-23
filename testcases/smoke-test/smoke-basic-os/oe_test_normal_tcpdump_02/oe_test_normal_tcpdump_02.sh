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
#@Desc      	:   Add the macvlan device created on bond to the network namespace verification
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL tcpdump
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ping -I ${NODE1_NIC} baidu.com &
    CHECK_RESULT $? 0 0 "ping -I  ${NODE1_NIC} baidu.com:failed"
    timeout 5 tcpdump -i ${NODE1_NIC} 2>&1 | grep "listening on ${NODE1_NIC}"
    CHECK_RESULT $? 0 0 "tcpdump -i: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF REMOVE
    kill -9 $(ps -ef | grep "baidu.com" | grep -v grep | awk '{print $2}')
    kill -9 $(ps -ef | grep "tcpdump -i" | grep -v grep | awk '{print $2}')
    LOG_INFO "End to restore the test environment."
}

main "$@"
