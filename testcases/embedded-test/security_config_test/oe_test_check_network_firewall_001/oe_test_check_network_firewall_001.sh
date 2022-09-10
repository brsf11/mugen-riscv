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
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check log_martians set
#                check net.ipv4.tcp_syncookies
#                check net.ipv4.ip_forward
#                check send_redirects
#                check accept_source_route
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    # check net.ipv4.tcp_syncookies
    sysctl net.ipv4.tcp_syncookies | awk -F "=" '{print $2}' | grep "1"
    CHECK_RESULT $? 0 0 "check net.ipv4.tcp_syncookies set fail"

    # check net.ipv4.ip_forward
    sysctl net.ipv4.ip_forward | awk -F "=" '{print $2}' | grep "0"
    CHECK_RESULT $? 0 0 "check net.ipv4.ip_forward set fail"

    # check icmp_echo_ignore_broadcasts
    sysctl net.ipv4.icmp_echo_ignore_broadcasts | awk -F "=" '{print $2}' | grep "1"
    CHECK_RESULT $? 0 0 "check net.ipv4.icmp_echo_ignore_broadcasts set fail"

    # check icmp_ignore_bogus_error_responses
    sysctl net.ipv4.icmp_ignore_bogus_error_responses | awk -F "=" '{print $2}' | grep "1"
    CHECK_RESULT $? 0 0 "check net.ipv4.icmp_ignore_bogus_error_responses set fail"

    # check rp_filter
    sysctl net.ipv4.icmp_ignore_bogus_error_responses | awk -F "=" '{print $2}' | grep "1"
    CHECK_RESULT $? 0 0 "check net.ipv4.icmp_ignore_bogus_error_responses set fail"

    LOG_INFO "End to run test."
}

main "$@"
