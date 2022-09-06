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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Implement some settings previously supported by ntp in NTP
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "chrony ntpstat ntp"
    systemctl start ntpd
    systemctl start chronyd
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl status chronyd | grep running
    CHECK_RESULT $?
    CHECK_RESULT $(chronyc -n tracking | grep -icE 'utc|RMS offset|Last offset') 3
    cp /etc/ntp.conf /etc/ntp.conf_bak
    echo "server 127.127.1.0 iburst prefer minpoll 3 maxpoll 3" >> /etc/ntp.conf
    CHECK_RESULT $?
    systemctl restart ntpd
    SLEEP_WAIT 3
    ntpstat | grep "polling server"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/ntp.conf_bak /etc/ntp.conf
    systemctl stop chronyd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
