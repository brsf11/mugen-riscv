#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-11-10 09:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification pwgen's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL pwgen
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pwgen --help >usage.txt 2>&1
    grep "Usage: pwgen" usage.txt
    CHECK_RESULT $? 0 0 "check pwgen --help failed"
    pwgen -0 | grep "[0-9]"
    CHECK_RESULT $? 0 1 "check pwgen -0 don't include numbers "
    pwgen -0 | grep "[a-zA-Z]"
    CHECK_RESULT $? 0 0 "check pwgen -0 don't include numbers "
    pwgen -n | grep "[0-9]"
    CHECK_RESULT $? 0 0 "check pwgen -n include at least one number in the password"
    pwgen -c | grep "[A-Z]"
    CHECK_RESULT $? 0 0 "Include at least one capital letter in the password"
    CHECK_RESULT "$(pwgen 50 | wc -L)" 50
    CHECK_RESULT "$(pwgen 10 1 | wc -L)" 10
    pwgen -1 -s -y
    CHECK_RESULT $? 0 0 "check pwgen -1 -s -y failed"
    pwgen -1 -s
    CHECK_RESULT $? 0 0 "check pwgen -1 -s failed"
    pwgen -1
    CHECK_RESULT $? 0 0 "check pwgen -1 failed"
    CHECK_RESULT "$(pwgen -ncy1 16 8 | wc -l)" 8
    CHECK_RESULT "$(pwgen -ncy1 16 8 | wc -L)" 16
    CHECK_RESULT "$(pwgen -nABC 8 4 | wc -l)" 1
    CHECK_RESULT "$(pwgen -nABC 8 4 | wc -L)" 35
    pwgen -nc1 8 4 | grep -E "[0-9a-zA-Z]"
    CHECK_RESULT $? 0 0 "check pwgen -nc1 failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
