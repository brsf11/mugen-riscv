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
# @Date      :   2020/11/16
# @License   :   Mulan PSL v2
# @Desc      :   verify the bcrypt command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL bcrypt
    touch test{1..8}
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file logpd
        spawn bcrypt -o test1
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    grep -avE "spawn bcrypt -o test|Encryption key:|Again:" logpd
    CHECK_RESULT $?
    expect <<EOF
        spawn bcrypt -c test2
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test2.bfe
    CHECK_RESULT $?
    grep -a ".*" test2.bfe
    CHECK_RESULT $?
    test -f test2
    CHECK_RESULT $? 1
    expect <<EOF
        spawn bcrypt -r test3
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test3.bfe
    CHECK_RESULT $?
    grep -a ".*" test3.bfe
    CHECK_RESULT $?
    test -f test3
    CHECK_RESULT $?
    expect <<EOF
        spawn bcrypt -r test4 test5
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test4.bfe -a -f test5.bfe
    CHECK_RESULT $?
    grep -a ".*" test4.bfe
    CHECK_RESULT $?
    grep -a ".*" test5.bfe
    CHECK_RESULT $?
    test -f test4 -a -f test5
    CHECK_RESULT $?
    expect <<EOF
        spawn bcrypt -s3 test6
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test6.bfe
    CHECK_RESULT $?
    grep -a ".*" test6.bfe
    CHECK_RESULT $?
    test -f test6
    CHECK_RESULT $? 1
    expect <<EOF
        spawn bcrypt -s0 test7
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test7.bfe
    CHECK_RESULT $?
    grep -a ".*" test7.bfe
    CHECK_RESULT $?
    test -f test7
    CHECK_RESULT $? 1
    expect <<EOF
        spawn bcrypt -s0 -r test8
        expect "Encryption key:" {send "123456789\r"}
        expect "Again:" { send "123456789\r"}
        expect eof
EOF
    test -f test8.bfe
    CHECK_RESULT $?
    grep -a ".*" test8.bfe
    CHECK_RESULT $?
    test -f test8
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
