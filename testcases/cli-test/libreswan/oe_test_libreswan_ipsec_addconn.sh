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
#@Desc      	:   Check ipsec addconn
#####################################

source ./common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    SET_CONF
    ADD_CONN

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    ipsec addconn --config /etc/ipsec.d/test-vm.secrets --varprefix /etc/ipsec.d/test-vm.secrets --noexport --verbose test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --config --varprefix --noexport --verbose failed."
    ipsec addconn --autoall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --autoall failed."
    ipsec addconn --listall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --listall failed."
    ipsec addconn --listroute >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --listroute failed."
    ipsec addconn --liststart >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --liststart failed."
    ipsec addconn --liststack >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --liststack failed."
    ipsec addconn --listignore >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --listignore failed."
    ipsec addconn --configsetup test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec addconn --configsetup failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    REVERT_CONF

    LOG_INFO "End to restore the test environment."
}

main "$@"

