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
# @Date      :   2022/06/27
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rsyslog
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -f /run/log/imjournal.state /run/log/imjournal.state.bak
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl stop rsyslog
    CHECK_RESULT $? 0 0 "Failed to stop service"
    SLEEP_WAIT 3
    echo "" >/run/log/imjournal.state
    systemctl start rsyslog
    CHECK_RESULT $? 0 0 "Failed to start service"
    SLEEP_WAIT 8
    main_pid=$(systemctl status rsyslog | grep "Main PID" | awk '{print $3}')
    grep rsyslog /var/log/messages | grep $main_pid
    CHECK_RESULT $? 0 0 "Log not recorded"
    rm -rf /run/log/imjournal.state
    systemctl restart rsyslog
    CHECK_RESULT $? 0 0 "Failed to restart service"
    SLEEP_WAIT 3
    main_pid=$(systemctl status rsyslog | grep "Main PID" | awk '{print $3}')
    grep rsyslog /var/log/messages | grep $main_pid
    CHECK_RESULT $? 0 0 "The pid not recorded"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /run/log/imjournal.state.bak /run/log/imjournal.state
    LOG_INFO "End to restore the test environment."
}

main "$@"
