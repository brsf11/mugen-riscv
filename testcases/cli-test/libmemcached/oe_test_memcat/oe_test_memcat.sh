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
# @Desc      :   verify the uasge of memcat command
# ############################################

source "../common/common_libmemcached.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    memcat --help | grep "-"
    CHECK_RESULT $?
    memcat --version | grep "memcat"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose user_id
    CHECK_RESULT $? 1
    expect <<EOF
        spawn telnet 127.0.0.1 11211
        expect "" {send "set user_id 2 0 5\r"}
        expect "" {send "12345\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcat --servers=127.0.0.1 --verbose user_id | grep -E "user_id|2|5|12345"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --quiet user_id
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --debug user_id | grep -E "key|flags|length|value"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 user_id | grep "12345"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --flag user_id
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --binary user_id
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --file=userID user_id
    CHECK_RESULT $?
    test -f userID && grep "12345" userID
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
