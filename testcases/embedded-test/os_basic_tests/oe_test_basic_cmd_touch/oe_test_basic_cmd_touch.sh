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
# @Desc      :   File system common command test-touch
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    ls test1 && rm -rf test1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    touch test1
    ls | grep "test1"
    CHECK_RESULT $? 0 0 "check touch test1 fail"

    touch -c test2
    ls | grep "test2"
    CHECK_RESULT $? 0 1 "check touch -c test2 fail"

    time01=$(ls -l test1 | awk '{print $8}')
    SLEEP_WAIT 60
    touch -c test1
    time02=$(ls -l test1 | awk '{print $8}')
    [ "$time01" != "$time02" ]
    CHECK_RESULT $? 0 0 "check touch -c fail"

    touch --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check touch help fail"

    LOG_INFO "End to run test."

}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf test1

    LOG_INFO "End to restore the test environment."
}

main $@
