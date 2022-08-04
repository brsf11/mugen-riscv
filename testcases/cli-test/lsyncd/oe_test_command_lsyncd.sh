#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   zhaorunqi
# @Contact   :   runqi@isrc.iscas.ac.cn
# @Date      :   2022/1/20
# @License   :   Mulan PSL v2
# @Desc      :   verification lsyncd's command
# #############################################
source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL lsyncd
    cat >> /etc/lsyncd.conf << EOF
    sync{default.rsync, source="/var/www/html", target="/tmp/htmlcopy/"}
EOF
    mkdir -p /var/www/html /tmp/htmlcopy /var/log/lsyncd
    touch /var/log/lsyncd/lsyncd.{log,status}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lsyncd  /etc/lsyncd.conf -delay 25
    CHECK_RESULT $? 0 0 "Check dealy failed"
    lsyncd -insist /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check insist failed"
    lsyncd -pidfile /var/log/lsyncd/lsyncd.pid /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check pidfile failed"
    lsyncd -nodaemon  /etc/lsyncd.conf | sed '/.*Startup.*/q'
    CHECK_RESULT $? 0 0 "Check nodaemon failed"
    lsyncd -log all /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check log all failed"
    lsyncd -log Exec /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check log exec failed"
    lsyncd -logfile /var/log/lsyncd/lsyncd.log /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check logfile failed"
    lsyncd -log scarce /etc/lsyncd.conf
    CHECK_RESULT $? 0 0 "Check log scarce failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /var/www /tmp/htmlcopy /var/log/lsyncd /etc/lsyncd.conf
    kill -9 $(ps -ef | grep "lsyncd" | grep -Ev "grep|bash" | awk '{print $2}')
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
