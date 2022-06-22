#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   zhangjujie2
#@Contact   	:   zhangjujie43@gmail.com
#@Date      	:   2022/08/04
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for nmon
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "nmon"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
    spawn nmon
    send "+\r"
    expect "4secs" {
        exec touch ./interactive_+
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_+
    CHECK_RESULT $? 0 0 "Failed option: +"
    expect <<EOF
    spawn nmon -s4
    send -- "-\r"
    expect "2secs" {
        exec touch ./interactive_-
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_-
    CHECK_RESULT $? 0 0 "Failed option: -"
    expect <<EOF
    spawn nmon
    send "l0\r"
    expect "%-| |" {
        exec touch ./interactive_0
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_0
    CHECK_RESULT $? 0 0 "Failed option: 0"
    expect <<EOF
    spawn nmon
    send "1\r"
    expect "mode=1" {
        exec touch ./interactive_1_1
    }
    expect "Nice" {
        exec touch ./interactive_1_2
    }
    expect "Prior" {
        exec touch ./interactive_1_3
    }
    expect "Status" {
        exec touch ./interactive_1_4
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_1_1 && test -f ./interactive_1_2 && \
    test -f ./interactive_1_3 && test -f ./interactive_1_4
    CHECK_RESULT $? 0 0 "Failed option: 1"
    expect <<EOF
    spawn nmon
    send "3\r"
    expect "mode=3" {
        exec touch ./interactive_3_1
    }
    expect "CPU" {
        exec touch ./interactive_3_2
    }
    expect "Size" {
        exec touch ./interactive_3_3
    }
    expect "Res" {
        exec touch ./interactive_3_4
    }
    expect "Faults" {
        exec touch ./interactive_3_5
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_3_1 && test -f ./interactive_3_2 && \
    test -f ./interactive_3_3 && test -f ./interactive_3_4 && \
    test -f ./interactive_3_5
    CHECK_RESULT $? 0 0 "Failed option: 3"
    expect <<EOF
    spawn nmon
    send "4\r"
    expect "mode=4" {
        exec touch ./interactive_4
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_4
    CHECK_RESULT $? 0 0 "Failed option: 4"
    expect <<EOF
    spawn sudo nmon
    expect "password" {
        send $NODE1_PASSWORD
    }
    send "5\r"
    expect "mode=5" {
        exec touch ./interactive_5
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_5
    CHECK_RESULT $? 0 0 "Failed option: 5"
    expect <<EOF
    spawn nmon
    send "l6\r"
    expect "60%-|+" {
        exec touch ./interactive_6
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_6
    CHECK_RESULT $? 0 0 "Failed option: 6"
    expect <<EOF
    spawn nmon
    send "l7\r"
    expect "70%-|+" {
        exec touch ./interactive_7
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_7
    CHECK_RESULT $? 0 0 "Failed option: 7"
    expect <<EOF
    spawn nmon
    send "l8\r"
    expect "80%-|+" {
        exec touch ./interactive_8
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_8
    CHECK_RESULT $? 0 0 "Failed option: 8"
    expect <<EOF
    spawn nmon
    send "l9\r"
    expect "90%-|+" {
        exec touch ./interactive_9
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_9
    CHECK_RESULT $? 0 0 "Failed option: 9"
    expect <<EOF
    spawn nmon
    send " \r"
    send "q"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Failed option: space"
    export NMON=cm
    expect <<EOF
    spawn nmon
    expect "CPU Utilisation" {
        exec touch ./interactive_startUpControl_1
    }
    expect "Memory and Swap" {
        exec touch ./interactive_startUpControl_2
    }
    send "q"
    expect eof
EOF
    test -f ./interactive_startUpControl_1 && test -f ./interactive_startUpControl_2
    CHECK_RESULT $? 0 0 "Failed option: start-up control"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start restore the test environment."
    DNF_REMOVE
    rm -rf ./interactive_*
    unset NMON
    LOG_INFO "End to restore the test environment."
}

main "$@"

