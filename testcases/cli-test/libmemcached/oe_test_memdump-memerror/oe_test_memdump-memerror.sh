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
# @Desc      :   verify the uasge of memdump and memerror command
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
        expect "" {send "quit\r"}
        expect eof
EOF
    memcat --servers=127.0.0.1 --file=testname1 testname1
    CHECK_RESULT $?
    test -f testname1 && grep "Jackson" testname1
    CHECK_RESULT $?
    memdump --help | grep "-"
    CHECK_RESULT $?
    memdump --version | grep "memdump"
    CHECK_RESULT $?
    memdump --quiet --servers=127.0.0.1
    CHECK_RESULT $?
    memdump --verbose --servers=127.0.0.1
    CHECK_RESULT $?
    memdump --debug --servers=127.0.0.1
    CHECK_RESULT $?
    memdump --servers=127.0.0.1
    CHECK_RESULT $?

    memerror --help | grep "-"
    CHECK_RESULT $?
    memerror --version | grep "memerror"
    CHECK_RESULT $?
    memerror "0xffffd3cdfdfdf123" | grep "SUCCESS"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
