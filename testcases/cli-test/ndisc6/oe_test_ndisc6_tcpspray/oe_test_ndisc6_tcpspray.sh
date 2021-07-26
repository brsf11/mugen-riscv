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
    tcpspray -4 -v -f echo.c localhost 7 | grep "Sending 102400 bytes"
    CHECK_RESULT $?
    tcpspray -6 -f echo.c localhost 7 | grep "Transmitted 102400 bytes"
    CHECK_RESULT $?
    tcpspray -e -v -f echo.c localhost 7 | grep "Received 102400 bytes"
    CHECK_RESULT $?
    ndisc6_version=$(rpm -qa ndisc6 | awk -F '-' '{print $2}')
    tcpspray -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    tcpspray -h | grep tcpspray
    CHECK_RESULT $?
    tcpspray6 -4 -v -f echo.c localhost 7 | grep "Sending 102400 bytes"
    CHECK_RESULT $?
    tcpspray6 -6 -f echo.c localhost 7 | grep "Transmitted 102400 bytes"
    CHECK_RESULT $?
    tcpspray6 -e -v -f echo.c localhost 7 | grep "Received 102400 bytes"
    CHECK_RESULT $?
    tcpspray6 -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    tcpspray6 -h | grep tcpspray
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
