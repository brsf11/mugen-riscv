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
# @Desc      :   verify the uasge of memrm command
# ############################################

source "../common/common_libmemcached.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    memrm --help | grep "-"
    CHECK_RESULT $?
    memrm --version | grep "memrm"
    CHECK_RESULT $?
    expect <<EOF
        spawn telnet 127.0.0.1 11211
        expect "" {send "set age 2 0 2\r"}
        expect "" {send "23\r"}
        expect "" {send "set name 1 0 4\r"}
        expect "" {send "Demo\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcat --servers=127.0.0.1 --verbose age name | grep -E "key|value"
    CHECK_RESULT $?
    memrm --verbose --servers=127.0.0.1 age name | grep "Deleted key"
    CHECK_RESULT $?
    memcat --servers=127.0.0.1 --verbose age name | grep -E "key|value"
    CHECK_RESULT $? 1
    memrm --quiet --servers=127.0.0.1
    CHECK_RESULT $?
    memrm --debug --servers=127.0.0.1 age name
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
