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
# @Date      :   2022/06/27
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rsyslog
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    systemctl start rsyslog
    cp -f /var/log/messages /var/log/messages.bak
    echo "" >/var/log/messages
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl status rsyslog | grep running
    CHECK_RESULT $? 0 0 "Service not started"
    old_pid=$(systemctl status rsyslog | grep "Main PID" | awk '{print $3}')
    echo "num=0
    while ((num<200));do
        dnf install -y vi
        let num+=1
    done
    " >test.sh
    sh test.sh &
    kill -9 $old_pid
    SLEEP_WAIT 3
    systemctl status rsyslog | grep running
    CHECK_RESULT $? 0 0 "The service was not pulled up again"
    kill -9 $(jobs -l | grep test.sh | awk '{print $2}')
    CHECK_RESULT $? 0 0 "Service not started"
    test $(grep -c ldapdb /var/log/messages) -lt 100
    CHECK_RESULT $? 0 0 "Quantity is greater than 100"
    test $old_pid -ne $(systemctl status rsyslog | grep "Main PID" | awk '{print $3}')
    CHECK_RESULT $? 0 0 "Pid unchanged"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /var/log/messages.bak /var/log/messages
    rm -rf test.sh
    LOG_INFO "End to restore the test environment."
}

main "$@"
