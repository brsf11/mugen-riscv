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
# @Author    :   wangxiaoya
# @Contact   :   wangxiaoya@qq.com
# @Date      :   2022/6/13
# @License   :   Mulan PSL v2
# @Desc      :   Kernel parameter reinforcement description
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^net.ipv4.icmp_echo_ignore_broadcasts=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^net.ipv4.conf.all.rp_filter=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.default.rp_filter=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.ip_forward=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.all.accept_source_route=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.default.accept_source_route=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.all.accept_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.default.accept_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv6.conf.all.accept_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv6.conf.default.accept_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.all.send_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.default.send_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.icmp_ignore_bogus_error_responses=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.tcp_syncookies=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "kernel.dmesg_restrict=1" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "kernel.sched_autogroup_enabled=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 1 "Security reinforcement options are set."
    grep "kernel.sysrq=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.all.secure_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "net.ipv4.conf.default.secure_redirects=0" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    LOG_INFO "Finish testcase execution."
}

main "$@"
