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
# @Desc      :   check accept_redirects
#                check secure_redirects
#                check icmp_echo_ignore_broadcasts
#                check icmp_ignore_bogus_error_responses
#                check rp_filter
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function check_version()
{
    grep "VERSION_ID" /etc/os-release | grep -q "22.03"
    if [ $? -eq 0 ]; then
        LOG_WARN "check $2 set fail"
    else
        CHECK_RESULT $1 0 0 "check $2 set fail"
    fi
}

function run_test()
{
    LOG_INFO "Start to run test."

    # check accept_redirects
    sysctl net.ipv4.conf.all.accept_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.all.accept_redirects"

    sysctl net.ipv4.conf.default.accept_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.default.accept_redirects"

    # check secure_redirects
    sysctl net.ipv4.conf.all.secure_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.all.secure_redirects"

    sysctl net.ipv4.conf.default.secure_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.default.secure_redirects"

    # check log_martians set
    sysctl net.ipv4.conf.default.log_martians | awk -F "=" '{print $2}' | grep "1"
    check_version $? "net.ipv4.conf.default.log_martians"

    sysctl net.ipv4.conf.all.log_martians | awk -F "=" '{print $2}' | grep "1"
    check_version $? "net.ipv4.conf.all.log_martians"

    # check send_redirects
    sysctl net.ipv4.conf.all.send_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.all.send_redirects"

    sysctl net.ipv4.conf.default.send_redirects | awk -F "=" '{print $2}' | grep "0"
    check_version $? "sysctl net.ipv4.conf.default.send_redirects"

    # check accept_source_route
    sysctl net.ipv4.conf.all.accept_source_route | awk -F "=" '{print $2}' | grep "0"
    check_version $? "net.ipv4.conf.all.accept_source_route"

    sysctl net.ipv4.conf.default.accept_source_route | awk -F "=" '{print $2}' | grep "0"
    check_version $? "sysctl net.ipv4.conf.default.accept_source_route"

    LOG_INFO "End to run test."
}

main "$@"
