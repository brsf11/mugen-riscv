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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-29
# @License   :   Mulan PSL v2
# @Desc      :   User creates another cron file
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    current_time=$(date "+%Y-%m-%d %H:%M:%S")
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    crontab -l 2>&1 | grep 'no crontab' || crontab -r
    touch ~/globus.cron
    crontab ~/globus.cron
    CHECK_RESULT $?
    echo "0 0 * * * echo 'hello world' >> /tmp/test.txt">>~/globus.cron
    CHECK_RESULT $?
    crontab ~/globus.cron
    ret=$(crontab -l | wc -l)
    CHECK_RESULT "$ret" 1
    date -s "23:59:50"
    rm -rf /tmp/test.txt
    SLEEP_WAIT 60
    grep "hello world" /tmp/test.txt
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    date -s "$current_time 1 minute"
    crontab -r
    rm -rf /tmp/test.txt ~/globus.cron
    LOG_INFO "End to restore the test environment."
}

main "$@"
