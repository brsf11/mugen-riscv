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
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Hwclock command line test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to pre test."
    time=$(date "+%Y-%m-%d %H:%M:%S")
    time_D=$(date +"%y-%m-%d")
    time_HMS=$(date +"%H:")
    LOG_INFO "End to pre test."
}

function run_test() {
    LOG_INFO "Start to run test."
    hwclock --systohc
    CHECK_RESULT $?
    hwclock | grep "${time_D}" | grep "${time_HMS}"
    CHECK_RESULT $?
    hwclock --set --date "21 Oct 2019 21:17" --utc
    SLEEP_WAIT 1
    hwclock | grep "2019-10-21" | grep "21:17"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    hwclock --systohc
    date -s "$time"
    hwclock -w
    LOG_INFO "End to restore the test environment."
}

main "$@"
