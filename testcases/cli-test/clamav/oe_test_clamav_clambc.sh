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
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test clambc execution
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav
    mkdir /opt/test_clambc
    cd /opt/test_clambc
    sigtool -u /var/lib/clamav/bytecode.cvd

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    clambc -f 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -f failed."
    clambc -t 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -t failed."
    clambc -i 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -i failed."
    clambc -p 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -p failed."
    clambc -c 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -c failed."
    clambc -T 7 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -T failed."
    clambc -s 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc -s failed."
    clambc 3986187.cbc --statistics=bytecode
    CHECK_RESULT $? 0 0 "Check clambc --statistics failed."
    clambc 3986187.cbc
    CHECK_RESULT $? 0 0 "Check clambc failed."
    clambc -f 3986187.cbc --debug
    CHECK_RESULT $? 0 0 "Check clambc --debug failed."

    clambc --version | grep "Clam AntiVirus Bytecode Testing Tool"
    CHECK_RESULT $? 0 0 "Check clambc version failed."
    clambc -h
    CHECK_RESULT $? 0 0 "Check clambc help message failed."
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    cd - && rm -rf /opt/test_clambc
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
