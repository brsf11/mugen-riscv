#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Check the audit service after killing the audit process abnormally
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL audit
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "Start audit: failed!"
    systemctl status auditd | grep "active (running)"
    CHECK_RESULT $? 0 0 "Check audit status: failed!"
    grep "Restart=on-failure" /usr/lib/systemd/system/auditd.service
    CHECK_RESULT $? 0 0 "View auditd.service file: failed!"
    kill -9 $(systemctl status auditd | grep 'Main PID' | tr -cd "[0-9]")
    CHECK_RESULT $? 0 0 "Kill auditd.service server: failed!"
    SLEEP_WAIT 3
    systemctl status auditd | grep "active (running)"
    CHECK_RESULT $? 0 0 "Stop audit process and get audit status:  failed!"
    pid=$(systemctl status auditd | grep 'Main PID' | tr -cd "[0-9]")
    pid_1=$(cat /var/run/auditd.pid)
    test $pid == $pid_1
    CHECK_RESULT $? 0 0 "Check whether the two pid are the same:  failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    kill -9 $pid
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
