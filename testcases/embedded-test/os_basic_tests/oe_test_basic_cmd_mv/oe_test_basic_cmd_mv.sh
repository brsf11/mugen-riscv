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
# @Desc      :   File system common command test-mv
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    ls /tmp/test1 && rm -rf /tmp/test1
    ls /tmp/test2 && rm -rf /tmp/test2

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mkdir test1
    mv test1 /tmp
    ls /tmp/test1
    CHECK_RESULT $? 0 0 "check mv test1 fail"

    mv /tmp/test1 /tmp/test2 && ls /tmp/test2
    CHECK_RESULT $? 0 0 "mv test1 to test2 fail"
    rm -rf /tmp/test2

    mkdir test2 && mv -f test2 /tmp
    ls /tmp/test2
    CHECK_RESULT $? 0 0 "check mv -f fail"

    mkdir /tmp/name1
    ls /tmp/name1
    CHECK_RESULT $? 0 0 "check dir name1 fail"
    mv /tmp/name1 /tmp/name2
    ls /tmp/name2
    CHECK_RESULT $? 0 0 "check dir name2 fail"
    ls /tmp/name1
    CHECK_RESULT $? 0 1 "check no name1 fail"

    mv /tmp/name2 /tmp/name3
    ls /tmp/name3
    CHECK_RESULT $? 0 0 "check dir name3 fail"
    ls /tmp/name2
    CHECK_RESULT $? 0 1 "check no name2 fail"

    mv /tmp/name3 /tmp/name1
    ls /tmp/name1
    CHECK_RESULT $? 0 0 "check dir name1 fail"
    ls /tmp/name3
    CHECK_RESULT $? 0 1 "check no name3 fail"

    mv --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check mv help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test* /tmp/name*

    LOG_INFO "End to restore the test environment."
}

main $@
