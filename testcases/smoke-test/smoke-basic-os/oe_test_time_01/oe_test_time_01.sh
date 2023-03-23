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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/20
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of time
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL time
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    time (dd if=/dev/zero of=/dev/null count=1 ibs=50M) >testlog 2>&1
    CHECK_RESULT $? 0 0 "Failed to execute time"
    grep 0m0 testlog
    CHECK_RESULT $? 0 0 "Failed to find time record"
    time -p (dd if=/dev/zero of=/dev/null count=1 ibs=50M) >testlog 2>&1
    CHECK_RESULT $? 0 0 "Failed to execute time -p"
    grep 0m0 testlog
    CHECK_RESULT $? 0 1 "Succeed to find time record"
    /usr/bin/time --portability dd if=/dev/zero of=/dev/null count=1 ibs=50M 2>&1 | grep 0m0
    CHECK_RESULT $? 0 1 "Failed to execute /usr/bin/time"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
