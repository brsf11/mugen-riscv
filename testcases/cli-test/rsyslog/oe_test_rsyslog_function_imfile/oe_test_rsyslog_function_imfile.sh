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
# @Desc      :   Support for local file write
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rsyslog
    echo "temp" >/etc/rsyslog.d/test || exit 1
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cat >/etc/rsyslog.d/test.conf <<EOF
    module(load="imfile" PollingInterval="1")
    input(type="imfile"
      file="/etc/rsyslog.d/test"
      tag="tag1"
      severity="error"
      facility="local7")
    local7.*  /var/log/test
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    echo "testmessage" >>/etc/rsyslog.d/test
    CHECK_RESULT $?
    SLEEP_WAIT 5
    grep testmessage /var/log/test
    CHECK_RESULT $?
    CHECK_RESULT "$(cat /var/log/test | wc -l)" 2
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/rsyslog.d/test /var/log/test /etc/rsyslog.d/test.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
