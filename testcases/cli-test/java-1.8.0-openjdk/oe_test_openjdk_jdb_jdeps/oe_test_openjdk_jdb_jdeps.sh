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
    cp ../common/Hello.java .
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    jdb -help | grep Usage
    CHECK_RESULT $?
    javac Hello.java
    CHECK_RESULT $?
    expect -c "
    log_file testlog
    spawn jdb
    expect \">\"
    send \"help\r\"
    expect \">\"
    send \"run Hello\r\"
    expect eof
"
    grep "while executing" testlog
    CHECK_RESULT $? 1
    grep "command list" testlog
    CHECK_RESULT $?
    grep "VM Started" testlog | grep 'Hello,world!'
    CHECK_RESULT $?

    jdeps -help | grep Usage
    CHECK_RESULT $?
    jdeps -version | grep '[0-9]'
    CHECK_RESULT $?

    jfr help | grep 'jfr print'
    CHECK_RESULT $?
    jfr version | grep '[0-9]'
    CHECK_RESULT $?

    jhat -h 2>&1 | grep Usage
    CHECK_RESULT $?
    jhat -version | grep 'jhat version'
    CHECK_RESULT $?

    jinfo -h 2>&1 | grep Usage
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf Hello.* testlog*
    LOG_INFO "End to restore the test environment."
}

main "$@"
