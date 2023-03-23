#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Brazil daylight time rules are normal
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL sysstat
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    sar -u 60 5 >sar.log
    CHECK_RESULT $? 0 0 "Using ‘sar’ to check CPU information: failed!"
    grep -E "user|nice|system|iowait|steal|idle" sar.log
    CHECK_RESULT $? 0 0 "Check CPU information: failed!"
    test $(grep -v "Average" sar.log| sed -n '4,$p' | wc -l) == 5
    CHECK_RESULT $? 0 0 "Check 5 times : failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF REMOVE
    rm -rf sar.log
    export LANG=${OLD_LANG}
    LOG_INFO "End to restore the test environment."
}

main "$@"
