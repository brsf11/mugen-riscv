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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-09
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec algparse
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL libreswan
    ipsec restart

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    ipsec algparse ike >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse ike failed."
    ipsec algparse esp >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse esp failed."
    ipsec algparse ah >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse ah failed."
    ipsec algparse -tp >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -tp failed."
    ipsec algparse -ta >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -ta failed."
    ipsec algparse -v2 'ike=aes_gcm-none-sha2;modp2048' >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse  -v2 'ike=aes_gcm-none-sha2;modp2048' failed."
    ipsec algparse -v1 >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -v1 failed."
    ipsec algparse -pfs >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -pfs failed."
    ipsec algparse -P testpwd >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -P testpwd failed."
    ipsec algparse -v >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -v failed."
    ipsec algparse --verbose >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse --verbose failed."
    ipsec algparse --debug >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse --debug failed."
    ipsec algparse --impair >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse --impair failed."
    ipsec algparse --ignore >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse --ignore failed."
    ipsec algparse -p1 >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -p1 failed."
    ipsec algparse -p2 >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -p2 failed."
    ipsec algparse -h >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec algparse -h failed."

    # test for -d option deleted, the help message cannot grep directly, so output it into file
    ipsec algparse -h &> testlog && cat testlog | grep "\-d \-\-debug"
    CHECK_RESULT $? 1 0 "Check ipsec algparse -h -d deleted failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f testlog
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

