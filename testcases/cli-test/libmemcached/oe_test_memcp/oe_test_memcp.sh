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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/27
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of memcp command
# ############################################

source "../common/common_libmemcached.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        spawn telnet 127.0.0.1 11211
        expect "" {send "set testname1 2 0 7\r"}
        expect "" {send "Jackson\r"}
        expect "" {send "set testname2 2 0 4\r"}
        expect "" {send "Lisa\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcat --servers=127.0.0.1 --file=testname1 testname1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --file=testname2 testname2
    CHECK_RESULT $?
    test -f testname1 && grep "Jackson" testname1
    CHECK_RESULT $?
    test -f testname2 && grep "Lisa" testname2
    CHECK_RESULT $?
    expect <<EOF
        spawn telnet 127.0.0.1 11211
        expect "" {send "delete testname1\r"}
        expect "" {send "delete testname2\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcp --help | grep "-"
    CHECK_RESULT $?
    memcp --version | grep "memcp"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 testname1
    CHECK_RESULT $? 1
    memcp --set testname1 --servers=127.0.0.1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 testname1 | grep "Jackson"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose testname1 | grep "flags: 0"
    CHECK_RESULT $?
    memcp --verbose --flag=2 --expire=15 testname1 --servers=127.0.0.1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose testname1 | grep "flags: 2"
    CHECK_RESULT $?
    SLEEP_WAIT 15
    memcat --servers=127.0.0.1 testname1
    CHECK_RESULT $? 1
    memcp --add testname1 --servers=127.0.0.1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 testname1 | grep "Jackson"
    CHECK_RESULT $?
    memcp --debug testname1 --servers=127.0.0.1
    CHECK_RESULT $?
    expect <<EOF
        spawn telnet 127.0.0.1 11211
        expect "" {send "set testname2 4 0 4\r"}
        expect "" {send "Rose\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcat --servers=127.0.0.1 --verbose testname2 | grep -E "flags: 4|value: Rose"
    CHECK_RESULT $?
    memcp --replace testname2 --flag=3 --expire=0 --servers=127.0.0.1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose testname2 | grep -E "flags: 3|value: Lisa"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
