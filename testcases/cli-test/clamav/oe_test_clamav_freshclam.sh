#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test freshclam
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL "clamav clamav-update"
    cp /etc/clamd.conf /etc/clamd.conf.bak

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    freshclam
    CHECK_RESULT $? 0 0 "Execute freshclam failed."
    freshclam --debug
    CHECK_RESULT $? 0 0 "Execute freshclam --debug failed."
    freshclam --quiet
    CHECK_RESULT $? 0 0 "Execute freshclam --quiet failed."
    freshclam --no-warnings
    CHECK_RESULT $? 0 0 "Execute freshclam --no-warnings failed."
    freshclam --show-progress
    CHECK_RESULT $? 0 0 "Execute freshclam --show-progress failed."
    freshclam -d -p pid_log
    CHECK_RESULT $? 0 0 "Execute freshclam -d -p pid_log failed."
    freshclam -u root
    CHECK_RESULT $? 0 0 "Execute freshclam -u root failed."
    freshclam --no-dns
    CHECK_RESULT $? 0 0 "Execute freshclam --no-dns failed."
    freshclam -c 3
    CHECK_RESULT $? 0 0 "Execute freshclam -c 3 failed."
    freshclam --datadir /opt
    CHECK_RESULT $? 0 0 "Execute freshclam --datadir /opt failed."
    freshclam --daemon-notify=/etc/clamd.conf
    CHECK_RESULT $? 0 0 "Execute freshclam --daemon-notify failed."
    freshclam --update-db main -a localhost
    CHECK_RESULT $? 0 0 "Execute freshclam --update-db main -a localhost failed."

    # test execute cmd after update
    freshclam --on-update-execute ls
    CHECK_RESULT $? 0 0 "Check freshclam --on-update-execute failed."
    freshclam --on-error-execute ls
    CHECK_RESULT $? 0 0 "Check freshclam --on-error-execute failed."
    freshclam --on-outdated-execute ls
    CHECK_RESULT $? 0 0 "Check freshclam --on-outdated-execute failed."

    freshclam --version
    CHECK_RESULT $? 0 0 "Check freshclam version failed."
    freshclam --help
    CHECK_RESULT $? 0 0 "Check freshclam help message failed."
    freshclam --list-mirrors
    CHECK_RESULT $? 0 0 "Check freshclam list mirrors failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f pid_log /etc/clamd.conf 
    mv /etc/clamd.conf.bak /etc/clamd.conf
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
