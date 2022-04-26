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
# @Desc      :   Starting and stopping the firewall
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    firewalld_status_1=$(sudo firewall-cmd --state)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    if [ "${firewalld_status_1}"x == "runningx" ]; then
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl status firewalld | grep disabled
        CHECK_RESULT $? 0
        sudo systemctl mask firewalld
        sudo systemctl status firewalld | grep masked
        CHECK_RESULT $? 0
        sudo firewall-cmd --state | grep "running"
        CHECK_RESULT $? 0 1
        sudo systemctl unmask firewalld
        sudo systemctl status firewalld | grep masked
        CHECK_RESULT $? 0 1
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        sudo systemctl status firewalld | grep enabled
        sudo firewall-cmd --state | grep running
        CHECK_RESULT $?
    else
        sudo systemctl unmask firewalld
        sudo systemctl status firewalld | grep masked
        CHECK_RESULT $? 0 1
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        sudo systemctl status firewalld | grep enabled
        CHECK_RESULT $?
        sudo firewall-cmd --state | grep running
        CHECK_RESULT $?
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl status firewalld | grep disabled
        CHECK_RESULT $? 0
        sudo systemctl mask firewalld
        sudo systemctl status firewalld | grep masked
        CHECK_RESULT $? 0
        sudo firewall-cmd --state | grep "running"
        CHECK_RESULT $? 0 1
    fi
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo systemctl unmask firewalld
    sudo systemctl restart firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
