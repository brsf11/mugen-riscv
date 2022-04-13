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
# @Desc      :   Check whether the firewall is turned on after the system is started
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    sudo systemctl status firewalld | grep running
    case $? in
    0)
        sudo systemctl stop firewalld
        sudo systemctl status firewalld | grep dead
        CHECK_RESULT $?
        sudo systemctl restart firewalld
        sudo systemctl status firewalld | grep running
        CHECK_RESULT $?
        ;;
    1)
        sudo systemctl start firewalld
        sudo systemctl status firewalld | grep running
        CHECK_RESULT $?
        ;;
    esac
    LOG_INFO "Finish testcase execution."
}

main "$@"
