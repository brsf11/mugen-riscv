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
# @Desc      :   verify the uasge of memcapable command
# ############################################

source "../common/common_libmemcached.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    memcapable -p 11211 -c | grep -E "ascii verbosity"
    CHECK_RESULT $?
    memcapable -p 11211 -v | grep -E "ascii|binary|pass"
    CHECK_RESULT $?
    memcapable -p 11211 -t 5 | grep "pass"
    CHECK_RESULT $?
    expect <<EOF
        spawn memcapable -p 11211 -P
        expect "" {send "\r"}
        expect "" {send "\r"}
        expect "" {send "skip\r"}
        expect "" {send "skip\r"}
        expect "" {send "\r"}
        expect "" {send "quit\r"}
        expect eof
EOF
    memcapable -p 11211 -T 1 | grep "All tests passed"
    CHECK_RESULT $?
    memcapable -p 11211 -a | grep -E "ascii|pass"
    CHECK_RESULT $?
    memcapable -p 11211 -b | grep -E "binary|pass"
    CHECK_RESULT $?
    memcapable -h 127.0.0.1 -p 11211
    CHECK_RESULT $? 1
    memcapable -p 11211 | grep "pass"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
