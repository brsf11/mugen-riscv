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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Log View
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    rmMessage=1
    if [ -e /var/log/messages ]; then
        rmMessage=0
    fi
    /etc/init.d/syslog restart

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ls /var/log
    CHECK_RESULT $? 0 0 "check /vat/log dir fail"
    tail -f /var/log/messages >log 2>&1 &
    row01=$(cat log | wc -l)
    SLEEP_WAIT 5
    row02=$(cat log | wc -l)
    [ ${row01} -le ${row02} ]
    CHECK_RESULT $? 0 0 "check log message file line fail"

    cat /var/log/messages
    CHECK_RESULT $? 0 0 "check log message file fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    pid=$(ps -ef | grep "tail" | grep -v grep | awk '{print $2}')
    kill -9 ${pid}
    rm -rf log
    if [ ${rmMessage} -eq 1 ]; then
        rm -rf /var/log/messages
    fi

    LOG_INFO "End to restore the test environment."
}

main $@
