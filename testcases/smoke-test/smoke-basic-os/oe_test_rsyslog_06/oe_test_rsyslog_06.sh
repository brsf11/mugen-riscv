#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/30
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rsyslog
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -f /etc/rsyslog.conf /etc/rsyslog.conf.bak
    echo "local0.info /tmp/testlog/test.log" >>/etc/rsyslog.conf
    getenforce | grep -i Enforcing && setenforce 0
    systemctl restart rsyslog
    SLEEP_WAIT 3
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    logger -p local0.info "hello world"
    CHECK_RESULT $? 0 0 "Failed to execute logger -p"
    logger -t "This is Test" -p local0.info "hello world"
    CHECK_RESULT $? 0 0 "Failed to execute add local0.info"
    logger -t "This is Test" -p local0.warning "hello world"
    CHECK_RESULT $? 0 0 "Failed to execute add local0.warning"
    logger -t "This is Test" -p local0.debug "hello world"
    CHECK_RESULT $? 0 0 "Failed to execute add local0.debug"
    SLEEP_WAIT 3
    tail -n 5 /tmp/testlog/test.log | grep -c "hello world" | grep 3
    CHECK_RESULT $? 0 0 "No 3 keywords"
    tail -n 5 /tmp/testlog/test.log | grep -c "This is Test: hello world" | grep 2
    CHECK_RESULT $? 0 0 "No 2 keywords"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/rsyslog.conf.bak /etc/rsyslog.conf
    getenforce | grep -i Permissive && setenforce 1
    systemctl restart rsyslog
    rm -rf /tmp//testlog/test.log
    LOG_INFO "End to restore the test environment."
}

main "$@"
