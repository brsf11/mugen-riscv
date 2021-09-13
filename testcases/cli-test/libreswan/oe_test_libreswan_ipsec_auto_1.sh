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

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    SSH_CMD "ipsec auto --config /etc/ipsec.d/test-vm.secrets --add test-vm-test" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    ipsec auto --config /etc/ipsec.d/test-vm.secrets --add test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --add failed."
    # Execute twice up cmd to get connection
    ipsec auto --up test-vm-test >/dev/null
    ipsec auto --up test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --up failed."
    ipsec auto --status | grep "test-vm-test" >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --status failed."
    ipsec auto --showonly --replace test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --replace failed."
    ipsec auto --showonly --ready >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --ready failed."
    ipsec auto --down test-vm-test
    CHECK_RESULT $? 0 0 "Check ipsec auto --down failed."
    ipsec auto --delete test-vm-test >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --delete failed."

    # test to check detail messages
    ipsec auto --listall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listall failed."
    ipsec auto --showonly --status --verbose >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --showonly --status --verbose failed."
    ipsec auto --status --config /etc/ipsec.conf >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --status --config failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    REVERT_CONF

    LOG_INFO "End to restore the test environment."
}

main "$@"

