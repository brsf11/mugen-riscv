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
    useradd testuser
    printf 'testuser\ntestuser\n' | passwd testuser
    systemctl restart dovecot

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    doveadm config >/dev/null
    CHECK_RESULT $? 0 0 "Check doveadm config failed."
    doveadm instance list
    CHECK_RESULT $? 0 0 "Check doveadm instance list failed."
    doveadm instance remove /var/run/dovecot
    CHECK_RESULT $? 0 0 "Check doveadm instance remove failed."
    doveadm penalty
    CHECK_RESULT $? 0 0 "Check doveadm penalty failed."
    doveadm proxy list
    CHECK_RESULT $? 0 0 "Check doveadm proxy list failed."
    doveadm proxy kick ${NODE1_IPV4}
    CHECK_RESULT $? 0 0 "Check doveadm proxy kick ${NODE1_IPV4} failed."
    doveadm auth cache flush
    CHECK_RESULT $? 0 0 "Check doveadm auth cache flush failed."
    doveadm auth login testuser testuser
    CHECK_RESULT $? 0 0 "Check doveadm auth login failed."
    doveadm auth test testuser testuser
    CHECK_RESULT $? 0 0 "Check doveadm auth test failed."
    dovecot-sysreport
    CHECK_RESULT $? 0 0 "Check doveadm-sysreport failed."
    ls dovecot-sysreport*
    CHECK_RESULT $? 0 0 "The report doesn't exist."
    doveadm reload
    CHECK_RESULT $? 0 0 "Check doveadm reload failed."
    doveadm stop
    CHECK_RESULT $? 0 0 "Check doveadm stop failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel testuser
    rm -rf dovecot-sysreport* 
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

