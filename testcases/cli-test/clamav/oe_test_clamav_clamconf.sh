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
#@Desc      	:   Take the test clamconf generate config
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    clamconf -g clamd.d/scan.conf
    CHECK_RESULT $? 0 0 "Execute clamconf -g clamd.d/scan.conf failed."
    clamconf -g freshclam.conf
    CHECK_RESULT $? 0 0 "Execute clamconf -g freshclam.conf failed."
    clamconf -g mail/clamav-milter.conf
    CHECK_RESULT $? 0 0 "Execute clamconf -g mail/clamav-milter.conf failed."

    clamconf -c /etc/clamd.d/scan.conf | grep -i "Build information"
    CHECK_RESULT $? 0 0 "Execute clamconf -g clamd.d/scan.conf failed."
    clamconf -c /etc/freshclam.conf | grep -i "Build information"
    CHECK_RESULT $? 0 0 "Execute clamconf -g freshclam.conf failed."
    clamconf -c /etc/mail/clamav-milter.conf | grep -i "Build information"
    CHECK_RESULT $? 0 0 "Execute clamconf -g mail/clamav-milter.conf failed."

    clamconf -V | grep "Clam AntiVirus Configuration Tool"
    CHECK_RESULT $? 0 0 "Check clamconf version failed."
    clamconf -h
    CHECK_RESULT $? 0 0 "Check clamconf help message failed."
    clamconf -n | grep -i "CFLAGS"
    CHECK_RESULT $? 0 0 "Check clamconf non-default config failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
