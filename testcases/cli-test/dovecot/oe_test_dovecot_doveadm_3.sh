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
#@Date      	:   2021-09-15
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test doveadm execution
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL dovecot
    systemctl restart dovecot
    touch a.sh
    useradd testuser

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    doveadm process status
    CHECK_RESULT $? 0 0 "Check doveadm process status failed."
    doveadm user -u testuser
    CHECK_RESULT $? 0 0 "Check doveadm user failed."
    doveadm stats dump
    CHECK_RESULT $? 0 0 "Check doveadm stats dump failed."
    expect <<EOF
        spawn doveadm zlibconnect ${NODE1_IPV4} 110
        expect "OK+" {send "user testuser\r"}
EOF
    CHECK_RESULT $? 0 0 "Check doveadm zlibconnect failed."
    doveadm service status
    CHECK_RESULT $? 0 0 "Check doveadm service status failed."
    doveadm service stop doveadm
    CHECK_RESULT $? 0 0 "Check doveadm service stop doveadm failed."
    doveadm oldstats reset
    CHECK_RESULT $? 0 0 "Check doveadm oldstats reset failed."
    doveadm penalty
    CHECK_RESULT $? 0 0 "Check doveadm penalty failed."

    sievec -c /etc/dovecot/dovecot.conf a.sh
    CHECK_RESULT $? 0 0 "Check doveadm sievec -c failed."
    sievec -d -D a.sh testfile
    CHECK_RESULT $? 0 0 "Check doveadm sievec -d -D failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -f testuser
    rm -rf a.sh* testfile
    systemctl stop doveadm
    systemctl stop dovecot.service
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

