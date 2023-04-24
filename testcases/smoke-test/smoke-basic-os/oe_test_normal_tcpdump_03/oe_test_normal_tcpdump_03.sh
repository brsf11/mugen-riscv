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
# @Desc      :   Test the basic functions of tcpdump
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL tcpdump
    ping -q -I ${NODE1_NIC} baidu.com &
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    tcpdump -i ${NODE1_NIC} -c 10 -w test.pcap 2>&1 | grep "listening on ${NODE1_NIC}"
    CHECK_RESULT $? 0 0 "Failed to execute tcpdump -w"
    test -f ./test.pcap
    CHECK_RESULT $? 0 0 "Failed to find test.pcap"
    tcpdump -r test.pcap 2>&1 | grep "reading from file test.pcap"
    CHECK_RESULT $? 0 0 "Failed to execute tcpdump -r"
    tcpdump -r test.pcap | grep -E "IP|ARP"
    CHECK_RESULT $? 0 0 "Failed to display IP"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    kill -9 $(pgrep ping)
    rm -rf ./test.pcap
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
