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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Start process / kill process
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL psmisc
    echo "#!/bin/bash
while true
do
sleep 1
done" >mykilltest
    chmod u+x mykilltest
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ./mykilltest &
    CHECK_RESULT $?
    sp_pid=$(pgrep -f "mykilltest")
    kill -9 "$sp_pid"
    CHECK_RESULT $?
    pgrep -f "mykilltest"
    CHECK_RESULT $? 0 1

    ./mykilltest &
    CHECK_RESULT $?
    pgrep -f "mykilltest"
    CHECK_RESULT $?
    pkill mykilltest
    CHECK_RESULT $?
    pgrep -f "mykilltest"
    CHECK_RESULT $? 0 1

    ./mykilltest &
    CHECK_RESULT $?
    pgrep -f "mykilltest"
    CHECK_RESULT $?
    killall mykilltest
    CHECK_RESULT $?
    pgrep -f "mykilltest"
    CHECK_RESULT $? 0 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf mykilltest
    LOG_INFO "End to restore the test environment."
}

main "$@"
