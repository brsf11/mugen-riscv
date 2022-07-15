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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-cp
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    test -f test1 || touch test1
    test -d test2/test3 || mkdir -p test2/test3

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    cp test1 /home
    CHECK_RESULT $? 0 0 "run cp test1 /home fail"
    test -f /home/test1
    CHECK_RESULT $? 0 0 "check test1 fail"

    cp -r test2 /home
    CHECK_RESULT $? 0 0 "run cp -r test2 /home fail"
    test -d /home/test2/test3
    CHECK_RESULT $? 0 0 "check /home/test2/test3 fail"

    cp -s test1 test4
    CHECK_RESULT $? 0 0 "run cp -s test1 test4 fail"
    ls -l test4 | grep "test4 -> test1"
    CHECK_RESULT $? 0 0 "check test4 fail"

    cp --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check cp help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf test1* /home/test* test2* test4*

    LOG_INFO "End to restore the test environment."
}

main $@
