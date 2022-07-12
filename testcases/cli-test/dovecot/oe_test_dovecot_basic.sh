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
#@Desc      	:   Take the test dovecot execution
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL dovecot
    systemctl restart dovecot

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    dovecot --version
    CHECK_RESULT $? 0 0 "Check dovecot version failed."
    dovecot --help
    CHECK_RESULT $? 0 0 "Check dovecot help failed."
    dovecot -n | grep $(uname -r)
    CHECK_RESULT $? 0 0 "Check dovecot non default config failed."
    doveconf -n | grep $(uname -r)
    CHECK_RESULT $? 0 0 "Check doveconf non default config failed."
    dovecot -a | grep -q "service"
    CHECK_RESULT $? 0 0 "Check dovecot all config failed."
    doveconf | grep -q "service"
    CHECK_RESULT $? 0 0 "Check doveconf failed."
    dovecot --hostdomain | grep -q "localhost"
    CHECK_RESULT $? 0 0 "Check dovecot hostdomain failed."
    grep -q "dovecot" /etc/passwd
    CHECK_RESULT $? 0 0 "Check dovecot user created failed."
    CHECK_RESULT $? 0 0 "Set dovecot build options failed."
    dovecot reload
    CHECK_RESULT $? 0 0 "Reload dovecot failed."
    dovecot stop
    CHECK_RESULT $? 0 0 "Stop dovecot failed."
    dovecot -c /etc/dovecot/dovecot.conf
    CHECK_RESULT $? 0 0 "Set dovecot config file failed."
    dovecot --build-options /etc/dovecot/dovecot.conf
    CHECK_RESULT $? 0 0 "Build dovecot failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    kill -9 $(ps -ef | grep dovecot | grep -v grep | grep -v ".sh\|.py" | awk '{print $2}')
    LOG_INFO "End to restore the test environment."
}

main "$@"

