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
# @Desc      :   -N/-D command parameters used
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
    rsyslogd -f /etc/rsyslog.d/test.conf -N1 2>&1 | grep 'End of config validation run.'
    CHECK_RESULT $?
    rsyslogd -f /etc/rsyslog.d/test.conf -D 2>&1 | grep 'Starting parse'
    CHECK_RESULT $?
    pgrep -f 'rsyslogd'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    pgrep -f rsyslogd | xargs kill -9
    rm -rf /etc/rsyslog.d/test.conf
    systemctl start rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
