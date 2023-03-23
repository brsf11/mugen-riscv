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
# @Desc      :   Test ip6tables add rule
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip6tables -A INPUT -i lo -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule INPUT"
    ip6tables -vL | grep -A 20 INPUT | grep -w lo
    CHECK_RESULT $? 0 0 "Failed to show rule INPUT"
    ip6tables -A OUTPUT -o lo -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule OUTPUT"
    ip6tables -vL | grep -A 20 OUTPUT | grep -w lo
    CHECK_RESULT $? 0 0 "Failed to show rule OUTPUT"
    ip6tables -A INPUT -i eth0 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule INPUT eth0"
    ip6tables -vL | grep -A 20 INPUT | grep -w eth0
    CHECK_RESULT $? 0 0 "Failed to show rule INPUT eth0"
    ip6tables -A OUTPUT -o eth0 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule OUTPUT eth0"
    ip6tables -vL | grep -A 20 OUTPUT | grep -w eth0
    CHECK_RESULT $? 0 0 "Failed to show rule OUTPUT eth0"
    ip6tables -A FORWARD -i eth1 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule FORWARD INPUT"
    ip6tables -vL | grep -A 20 FORWARD | awk '{print $5}' | grep -w eth1
    CHECK_RESULT $? 0 0 "Failed to show rule FORWARD INPUT"
    ip6tables -A FORWARD -o eth1 -j ACCEPT
    CHECK_RESULT $? 0 0 "Failed to add rule FORWARD OUTPUT"
    ip6tables -vL | grep -A 20 FORWARD | awk '{print $6}' | grep -w eth1
    CHECK_RESULT $? 0 0 "Failed to show rule FORWARD OUTPUT"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip6tables -D INPUT -i lo -j ACCEPT
    ip6tables -D OUTPUT -o lo -j ACCEPT
    ip6tables -D INPUT -i eth0 -j ACCEPT
    ip6tables -D OUTPUT -o eth0 -j ACCEPT
    ip6tables -D FORWARD -i eth1 -j ACCEPT
    ip6tables -D FORWARD -o eth1 -j ACCEPT
    LOG_INFO "End to restore the test environment."
}

main "$@"
