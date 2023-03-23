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
    old_id=$(pgrep rsyslog)
    old_timezone=$(date | awk '{print $6}')
    cp -f /etc/localtime /etc/localtime.bak
    cp -f /var/log/messages /var/log/messages.bak
    echo "" >/var/log/messages
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cp -f /usr/share/zoneinfo/NZ /etc/localtime
    CHECK_RESULT $? 0 0 "Failed to execute cp"
    date | grep $old_timezone
    CHECK_RESULT $? 0 1 "Time zone changed"
    SLEEP_WAIT 900
    pgrep rsyslog | grep $old_id
    CHECK_RESULT $? 0 1 "Pid not changed"
    date | grep -i NZ
    CHECK_RESULT $? 0 0 "Time zone not changed"
    grep "timezone changed" /var/log/messages
    CHECK_RESULT $? 0 0 "/var/log/messages not logged"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/localtime.bak /etc/localtime
    mv -f /var/log/messages.bak /var/log/messages
    LOG_INFO "End to restore the test environment."
}

main "$@"
