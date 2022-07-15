#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-mkdir
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    test -d /tmp/test1 && rm -rf /tmp/test1
    test -d /tmp/test2 && rm -rf /tmp/test2
    test -d /tmp/test3 && rm -rf /tmp/test3
    test -d /tmp/test5 && rm -rf /tmp/test5

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mkdir /tmp/test1 /tmp/test2
    test -d /tmp/test1 && test -d /tmp/test2
    CHECK_RESULT $? 0 0 "check mkdir test1 test2 fail"

    mkdir -p /tmp/test3/test4
    test -d /tmp/test3/test4
    CHECK_RESULT $? 0 0 "check mkdir -p fail"

    mkdir -m 777 /tmp/test5
    ls -l /tmp | grep test5 | grep "drwxrwxrwx"
    CHECK_RESULT $? 0 0 "check mkdir -m fail"

    mkdir --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check mkdir help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test*

    LOG_INFO "End to restore the test environment."
}

main $@
