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
#@Desc      	:   Kill -19 audit process, execute audit log script and check the status of auditd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    auditctl rate_limit=0
    auditctl backlog_wait_time=0
    echo "
    #!/bin/bash
while true
do
   sudo ls /root/ > /dev/null
done" >audit_shell
    chmod +777 ./audit_shell
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ./audit_shell &
    auditctl -s >audit_log 2>&1
    CHECK_RESULT $? 0 0 "Check auditctl -s: failed!"
    backlog=$(grep -w "backlog" audit_log | awk '{print $2}')
    backlog_limit=$(grep -w "backlog_limit" audit_log | awk '{print $2}')
    [ $backlog -lt $backlog_limit ]
    CHECK_RESULT $? 0 0 "Backlog not increase indefinitely: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf audit_shell audit_log
    kill -9 $(ps -ef | grep ./audit_shell | grep -v grep | awk '{print $2}')
    LOG_INFO "End to restore the test environment."
}

main "$@"
