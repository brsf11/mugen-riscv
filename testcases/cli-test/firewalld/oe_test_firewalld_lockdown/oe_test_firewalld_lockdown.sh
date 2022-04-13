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
# @Desc      :   Configure firewall lockout
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    
    sudo systemctl start firewalld
    lock_flag=$(firewall-cmd --query-lockdown)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    if [ "$lock_flag" = "no" ]; then
        sudo firewall-cmd --lockdown-on | grep success
        CHECK_RESULT $?
        firewall-cmd --query-lockdown | grep yes
        CHECK_RESULT $?
        sudo firewall-cmd --lockdown-off | grep success
        CHECK_RESULT $?
        firewall-cmd --query-lockdown | grep no
        CHECK_RESULT $?
    else
        sudo firewall-cmd --lockdown-off | grep success
        CHECK_RESULT $?
        firewall-cmd --query-lockdown | grep no
        CHECK_RESULT $?
        sudo firewall-cmd --lockdown-on | grep success
        CHECK_RESULT $?
        firewall-cmd --query-lockdown | grep yes
    fi

    LOG_INFO "Finish testcase execution."
}
main "$@"
