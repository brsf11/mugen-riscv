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
#@Desc      	:   Take the test clamdscan service
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL "clamav clamav-server"
    mv /etc/clamd.d/scan.conf /etc/clamd.d/scan.conf.bak
    echo "LogFile /var/log/clamd.scan
        LogFileMaxSize 2M
        LogTime yes
        PidFile /run/clamd.scan/clamd.pid
        DatabaseDirectory /var/lib/clamav
        TCPAddr 0.0.0.0
        TCPSocket 3310" >/etc/clamd.d/scan.conf

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    systemctl start clamd@scan.service
    CHECK_RESULT $? 0 0 "Start clamd@scan.service failed."
    systemctl status clamd@scan.service | grep "active"
    CHECK_RESULT $? 0 0 "Check clamd@scan.service status failed."

    systemctl stop clamd@scan.service
    CHECK_RESULT $? 0 0 "Stop clamd@scan.service failed."
    systemctl status clamd@scan.service | grep "inactive"
    CHECK_RESULT $? 0 0 "Check clamd@scan.service status failed."

    clamdscan --version
    CHECK_RESULT $? 0 0 "Check clamdscan version failed."
    clamdscan --help
    CHECK_RESULT $? 0 0 "Check clamdscan help message failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f /etc/clamd.d/scan.conf
    mv /etc/clamd.d/scan.conf.bak /etc/clamd.d/scan.conf
    systemctl restart clamd@scan.service
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
