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
#@Desc      	:   Take the test clamav-milter
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL "clamav clamav-milter"
    mv /etc/mail/clamav-milter.conf /etc/mail/clamav-milter.conf.bak
    echo "  MilterSocket /run/clamav-milter/clamav-milter.socket
            User clamilt
            ClamdSocket unix:/var/run/clamd.scan/clamd.sock
            LogSyslog yes" >/etc/mail/clamav-milter.conf

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    systemctl start clamav-milter
    CHECK_RESULT $? 0 0 "Start clamav-milter.server failed."
    systemctl status clamav-milter | grep "active"
    CHECK_RESULT $? 0 0 "Check clamav-milter.server active failed."
    systemctl stop clamav-milter
    CHECK_RESULT $? 0 0 "Stop clamav-milter.server failed."
    systemctl status clamav-milter | grep "inactive"
    CHECK_RESULT $? 0 0 "Start clamav-milter.server inactive failed."
    clamav-milter --version
    CHECK_RESULT $? 0 0 "Check clamav-milter version failed."
    clamav-milter --help
    CHECK_RESULT $? 0 0 "Check clamav-milter help message failed."
    clamav-milter -c /etc/mail/clamav-milter.conf
    CHECK_RESULT $? 0 0 "Check /etc/mail/clamav-milter.conf config failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f /etc/mail/clamav-milter.conf
    mv /etc/mail/clamav-milter.conf.bak /etc/mail/clamav-milter.conf
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
