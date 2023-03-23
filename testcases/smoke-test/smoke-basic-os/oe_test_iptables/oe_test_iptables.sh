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
# @Desc      :   Test iptables add rule
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    iptables -A INPUT -i lo -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule INPUT"
    iptables -vL | grep -A 20 INPUT | grep -w lo
    CHECK_RESULT $? 0 0 "Failed to show rule INPUT"
    iptables -A OUTPUT -o lo -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule OUTPUT"
    iptables -vL | grep -A 20 OUTPUT | grep -w lo
    CHECK_RESULT $? 0 0 "Failed to show rule OUTPUT"
    iptables -A INPUT -i eth0 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule eth0 INPUT"
    iptables -vL | grep -A 20 INPUT | grep -w eth0
    CHECK_RESULT $? 0 0 "Failed to show rule eth0 INPUT"
    iptables -A OUTPUT -o eth0 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule eth0 OUTPUT"
    iptables -vL | grep -A 20 OUTPUT | grep -w eth0
    CHECK_RESULT $? 0 0 "Failed to show rule eth0 OUTPUT"
    iptables -A FORWARD -i eth1 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule eth1 INPUT"
    iptables -vL | grep -A 20 FORWARD | awk '{print $6}' | grep -w eth1
    CHECK_RESULT $? 0 0 "Failed to show rule eth1 INPUT"
    iptables -A FORWARD -o eth1 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule eth1 OUTPUT"
    iptables -vL | grep -A 20 FORWARD | awk '{print $7}' | grep -w eth1
    CHECK_RESULT $? 0 0 "Failed to show rule eth1 OUTPUT"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    iptables -D INPUT -i lo -j ACCEPT
    iptables -D OUTPUT -o lo -j ACCEPT
    iptables -D INPUT -i eth0 -j ACCEPT
    iptables -D OUTPUT -o eth0 -j ACCEPT
    iptables -D FORWARD -i eth1 -j ACCEPT
    iptables -D FORWARD -o eth1 -j ACCEPT
    LOG_INFO "End to restore the test environment."
}

main "$@"
