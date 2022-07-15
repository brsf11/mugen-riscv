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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Date command line test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    time=$(date "+%Y-%m-%d %H:%M:%S")

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    date01=$(date | awk '{print $1,$2,$3}')
    date -d 2020-01-01
    date02=$(date | awk '{print $1,$2,$3}')
    test "$date01"x = "$date02"x
    CHECK_RESULT $? 0 0 "check date fail"
    date -s "9:30:00" | grep "9:30:00"
    CHECK_RESULT $? 0 0 "set date 9:30:00 fail"
    date -s "2015-02-04 9:30:00" | grep "9:30:00" | grep 2015 | grep -i feb | grep -i wed
    CHECK_RESULT $? 0 0 "set date 2015-02-04 9:30:00 fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    date -s "$time"

    LOG_INFO "End to restore the test environment."
}

main "$@"
