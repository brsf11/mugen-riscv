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
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification openjdk‘s command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL java-1.8.0-openjdk*
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    jjs -help 2>&1 | grep options
    CHECK_RESULT $?

    expect -c "
    log_file testlog1
    spawn jjs -strict
    expect \"jjs>\"
    send \"a=10\r\"
    expect \"jjs>\"
    send \"exit()\r\"
    expect eof
"
    grep "while executing" testlog1
    CHECK_RESULT $? 1
    grep "is not defined" testlog1
    CHECK_RESULT $?

    expect -c "
    log_file testlog2
    spawn jjs
    expect \"jjs>\"
    send \"a=10\r\"
    expect \"jjs>\"
    send \"exit()\r\"
    expect eof
"
    grep "while executing" testlog2
    CHECK_RESULT $? 1
    grep -v "a=10" testlog2 | grep 10
    CHECK_RESULT $?

    jmap -h 2>&1 | grep Usage
    CHECK_RESULT $?
    jps | grep '[0-9] Jps'
    CHECK_RESULT $?
    jps -help 2>&1 | grep usage
    CHECK_RESULT $?

    jrunscript -help 2>&1 | grep Usage
    CHECK_RESULT $?
    jrunscript -e "print('hello world')" | grep 'hello world'
    CHECK_RESULT $?
    echo "println(arguments[0]); 
println(arguments[1]); 
println(arguments[2]);" >run.js
    CHECK_RESULT $(jrunscript run.js arg1 arg2 arg3 | grep -icE 'arg1|arg2|arg3') 3

    expect -c "
    log_file testlog
    spawn jjs
    expect \"jjs>\"
    send \"20+40\r\"
    expect \"jjs>\"
    send \"exit()\r\"
    expect eof
"
    grep "while executing" testlog
    CHECK_RESULT $? 1
    grep "60" testlog
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf testlog* run.js
    LOG_INFO "End to restore the test environment."
}

main "$@"
