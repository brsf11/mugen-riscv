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
# @Desc      :   verify the uasge of memflush command
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
        expect "" {send "set user_id 1 0 3\r"}
        expect "" {send "001\r"}
        expect "" {send "set user_name 2 0 4\r"}
        expect "" {send "Lily\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memexist --verbose --servers=127.0.0.1 user_id user_name | grep -E "Found key user_id|Found key user_name"
    CHECK_RESULT $?
    memflush --help | grep "-"
    CHECK_RESULT $?
    memflush --version | grep "memflush"
    CHECK_RESULT $?
    memflush --quiet --servers=127.0.0.1
    CHECK_RESULT $?
    memflush --verbose --servers=127.0.0.1 user_id user_name
    CHECK_RESULT $?
    memflush --debug --servers=127.0.0.1 user_id user_name
    CHECK_RESULT $?
    memflush --servers=127.0.0.1
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose user_id user_name
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
