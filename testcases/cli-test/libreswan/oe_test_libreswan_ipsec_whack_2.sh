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
#@Desc      	:   Check ipsec whack status
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

    ipsec whack --status >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --status failed."
    ipsec whack --trafficstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --trafficstatus failed."
    ipsec whack --globalstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --globalstatus failed."
    ipsec whack --clearstats >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --clearstats failed."
    ipsec whack --shuntstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --shuntstatus failed."
    ipsec whack --fipsstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --fipsstatus failed."
    ipsec whack --briefstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --briefstatus failed."
    ipsec whack --showstates >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --showstates failed."
    ipsec whack --addresspoolstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --addresspoolstatus failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

