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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   -d/-v/-o/-n command parameters used
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    systemctl stop rsyslog
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rsyslogd -d >file1
    CHECK_RESULT $?
    [ -f file1 ] && grep "main Q" file1
    CHECK_RESULT $?
    pgrep -f rsyslogd | xargs kill -9 && SLEEP_WAIT 3
    CHECK_RESULT $?
    rsyslogd -v 2>&1 | grep 'rsyslogd'
    CHECK_RESULT $?
    rsyslogd -o file2
    CHECK_RESULT $?
    [ -f file2 ] && grep "/etc/rsyslog.conf" file2
    CHECK_RESULT $?
    pgrep -f rsyslogd | xargs kill -9 && SLEEP_WAIT 1
    CHECK_RESULT $?
    (SLEEP_WAIT 1 && pgrep -f rsyslogd | xargs kill -9) &
    rsyslogd -n
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf file1 file2
    systemctl start rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
