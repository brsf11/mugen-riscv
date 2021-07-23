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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in ndisc6 package
# ############################################

source "../common/common_ndisc6.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    tcptraceroute6 -d -A -f 1 -i lo -m 30 -q 3 -w 5 -z 0 -t 22 -S localhost 7 | grep "60 bytes"
    CHECK_RESULT $?
    tcptraceroute6 -g ${NODE2_IPV6} localhost 7 | grep "64 bytes"
    CHECK_RESULT $?
    tcptraceroute6 -d localhost 7 | grep "open"
    CHECK_RESULT $?
    tcptraceroute6 -l 50 -S localhost 7 | grep "50 bytes"
    CHECK_RESULT $?
    tcptraceroute6 -E localhost 7 | grep "bytes packets"
    CHECK_RESULT $?
    tcptraceroute6 -N localhost 7 | grep "1  localhost (::1)"
    CHECK_RESULT $?
    tcptraceroute6 -n localhost 7 | grep "1  localhost (::1)"
    CHECK_RESULT $? 0 1
    ndisc6_version=$(rpm -qa ndisc6 | awk -F '-' '{print $2}')
    tcptraceroute6 -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    tcptraceroute6 -h | grep "tcptraceroute6"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
