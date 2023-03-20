#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.


source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    ls test && rm -rf test
    for ((i=1;i<=5;i+=1))
    do
        echo $i >> test
    done
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    csplit test 3 | grep -E "[0-9]"
    CHECK_RESULT $?
    ls -l | grep 'xx'
    CHECK_RESULT $?
    csplit test 10
    CHECK_RESULT $? 0 1
    csplit -b num%d test 3 | grep -E "[0-9]"
    CHECK_RESULT $?
    ls -l | grep "num"
    CHECK_RESULT $?
    rm -rf xx*
    csplit -z test 1 | grep -E "[0-9]"
    CHECK_RESULT $?
    count=$(ls -l | grep -c 'xx')
    [ $count -eq 1 ]
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test xx*
    LOG_INFO "End to restore the test environment."
}

main "$@"