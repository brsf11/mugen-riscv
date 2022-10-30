#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Systemctl initiates the service command and Rsyslogd is executing simultaneously
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    echo "local7.*  /var/log/test" >/etc/rsyslog.d/test.conf
    systemctl stop rsyslog
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl start rsyslog
    CHECK_RESULT $?
    pgrep -f rsyslogd
    CHECK_RESULT $?
    rsyslogd
    CHECK_RESULT $?
    CHECK_RESULT "$(pgrep -cf rsyslogd)" 2
    logger -p local7.error 'test' && sleep 1
    CHECK_RESULT "$(cat /var/log/test | wc -l)" 2
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    pgrep -f rsyslogd | xargs kill -9
    rm -rf /etc/rsyslog.d/test.conf /var/log/test
    systemctl start rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
