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
#@Desc      	:   Take the test clamdtop info
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
        TCPSocket 3310
        LocalSocket /run/clamd.scan/clamd.sock
" >/etc/clamd.d/scan.conf
    systemctl restart clamd@scan.service

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    echo q | clamdtop localhost | grep "Connecting to: localhost"
    CHECK_RESULT $? 0 0 "Connecting to localhost failed."
    echo q | clamdtop /run/clamd.scan/clamd.sock | grep "Connecting to: /run/clamd.scan/clamd.sock"
    CHECK_RESULT $? 0 0 "Connecting /run/clamd.scan/clamd.sock failed."
    clamdtop --version
    CHECK_RESULT $? 0 0 "Check clamdtop version failed."
    clamdtop --help
    CHECK_RESULT $? 0 0 "Check clamdtop help message failed."
    echo q | clamdtop -c /etc/clamd.d/scan.conf | grep "Connecting"
    CHECK_RESULT $? 0 0 "Check clamdtop -c message failed."
    echo q | clamdtop -d
    CHECK_RESULT $? 0 0 "Execute clamdtop -d failed."

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

