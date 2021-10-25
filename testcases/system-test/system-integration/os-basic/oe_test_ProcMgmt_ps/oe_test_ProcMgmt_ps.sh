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
# @Desc      :   View process status-ps
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    echo "#!/bin/bash
while true
do
sleep 1
done" >mypstest
    chmod u+x mypstest
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ./mypstest &
    testpid=$(ps -aux | grep mypstest | grep -v grep | awk '{print$2}')
    CHECK_RESULT $?
    kill -9 ${testpid}
    CHECK_RESULT $?
    ps -ef | grep -v grep | grep ${testpid}
    CHECK_RESULT $? 0 1
    ps -ef | grep UID | grep PID | grep PPID
    CHECK_RESULT $?
    ps --help | grep Usage
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf myptest
    LOG_INFO "End to restore the test environment."
}
main "$@"
