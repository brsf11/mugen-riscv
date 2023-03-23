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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/14
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of infocmp
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    echo '#!/usr/bin/expect
log_file testlog
spawn ssh -o StrictHostKeyChecking=no 127.0.0.1
expect {
    "*?assword:*" {send "openEuler12#\$\r";exp_continue}
    "Users" {send "\rexport TERM=vt100\r";exp_continue}
    "export" {send "\recho \$TERM\r"; exp_continue}
    "echo" {send "\rexit\n"}
}
expect eof
' >run-term
    chmod 777 run-term
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    [ $TERM ]
    CHECK_RESULT $? 0 0 "Failed to execute xterm"
    infocmp | grep terminfo
    CHECK_RESULT $? 0 0 "Failed to execute infocmp"
    infocmp >test.log
    infotocap test.log | grep capabilities
    CHECK_RESULT $? 0 0 "Failed to execute infotocap"
    ./run-term
    CHECK_RESULT $? 0 0 "Failed to execute run-term"
    grep "\$TERM" testlog
    CHECK_RESULT $? 0 0 "Failed to display term"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog run-term test.log
    LOG_INFO "End to restore the test environment."
}

main "$@"
