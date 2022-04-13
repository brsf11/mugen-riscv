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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Log configuration for rejected packets
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL nmap
    DNF_INSTALL nmap 2
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nc -l -p 5060 2>&1 &
    SLEEP_WAIT 1
    sudo firewall-cmd --get-log-denied | grep 'off'
    CHECK_RESULT $?
    sudo firewall-cmd --set-log-denied=all | grep success
    sudo firewall-cmd --get-log-denied | grep 'all'
    CHECK_RESULT $?
    SLEEP_WAIT 1
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5060" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    SLEEP_WAIT 3
    grep "DST=${NODE1_IPV4}" /var/log/messages | grep "DPT=5060" >/dev/null
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --set-log-denied=off
    kill -9 $(pgrep -f 'nc -l -p 5060')
    DNF_REMOVE
    DNF_REMOVE 2 nmap
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
