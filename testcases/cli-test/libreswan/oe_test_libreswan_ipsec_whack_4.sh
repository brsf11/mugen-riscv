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
#@Date      	:   2021-08-10
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec whack
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

    # test ipsec whack --test
    ipsec whack --seccomp-crashtest
    CHECK_RESULT $? 0 0 "Check ipsec whack --seccomp-crashtest failed."

    # test ipsec whack --listen
    ipsec whack --listen
    CHECK_RESULT $? 0 0 "Check ipsec whack --listen failed."
    ipsec whack --unlisten
    CHECK_RESULT $? 0 0 "Check ipsec whack --unlisten failed."
    
    # test ipsec whack --ddns
    ipsec whack --ddns
    CHECK_RESULT $? 0 0 "Check ipsec whack --ddns failed."
    
    # test ipsec whack --reread
    ipsec whack --rereadsecrets
    CHECK_RESULT $? 0 0 "Check ipsec whack --rereadsecrets failed."
    ipsec whack --fetchcrls
    CHECK_RESULT $? 0 0 "Check ipsec whack --fetchcrls failed."
    ipsec whack --rereadall
    CHECK_RESULT $? 0 0 "Check ipsec whack --rereadall failed."
    
    # test ipsec whack --shutdown
    ipsec whack --shutdown
    CHECK_RESULT $? 0 0 "Check ipsec whack --shutdown failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

