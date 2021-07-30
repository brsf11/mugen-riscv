#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/05/29
# @License   :   Mulan PSL v2
# @Desc      :   Kernel parameter hardening
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    sysctl -p | grep 'net.ipv4.icmp_echo_ignore_broadcasts = 1'
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.all.rp_filter = 1'
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.default.rp_filter = 1' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.ip_forward = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.all.accept_source_route = 0'
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.default.accept_source_route = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.all.accept_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.default.accept_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv6.conf.all.accept_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv6.conf.default.accept_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.all.send_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.default.send_redirects = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.icmp_ignore_bogus_error_responses = 1' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.tcp_syncookies = 1' 
    CHECK_RESULT $?
    sysctl -p | grep 'kernel.dmesg_restrict = 1' 
    CHECK_RESULT $?
    sysctl -p | grep 'kernel.sysrq = 0' 
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.all.secure_redirects = 0'
    CHECK_RESULT $?
    sysctl -p | grep 'net.ipv4.conf.default.secure_redirects = 0' 
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
main "$@"
