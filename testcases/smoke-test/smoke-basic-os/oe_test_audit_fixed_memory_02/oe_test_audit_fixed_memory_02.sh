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
#@Desc      	:   Kill -19 audit process, execute C script and check the status of auditd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "audit-devel"
    auditctl rate_limit=0
    auditctl backlog_wait_time=0
    echo "
    #include<stdio.h>
#include<libaudit.h>

int main(int argc, char** atgv) {
        int ret;
        int fd = audit_open();
        while(1) {
                audit_log_user_command(fd, AUDIT_USYS_CONFIG, \"command\", \"tty\", 1);
        }
        return 0;

}" >test.c
    chmod +777 ./test.c
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    gcc -laudit test.c
    [ -e a.out ]
    CHECK_RESULT $? 0 0 "Get a.out: failed!"
    ./a.out &
    auditctl -s | grep -w "backlog"
    CHECK_RESULT $? 0 0 "Get backlog: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test.c  a.out
    kill -9 $(ps -ef | grep ./a.out | grep -v grep | awk '{print $2}')
    LOG_INFO "End to restore the test environment."
}

main "$@"
