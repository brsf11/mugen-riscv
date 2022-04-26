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
# @Desc      :   Use the CLI to configure the contexts lock list option
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    context="system_u:system_r:NetworkManager_t:s0"
    if ! sudo firewall-cmd --list-lockdown-whitelist-contexts | grep NetworkManager_t; then
        sudo firewall-cmd --add-lockdown-whitelist-context=$context
        sudo firewall-cmd --list-lockdown-whitelist-contexts | grep NetworkManager_t
        CHECK_RESULT $?
        sudo firewall-cmd --remove-lockdown-whitelist-context=$context
        sudo firewall-cmd --query-lockdown-whitelist-context=$context | grep yes
        CHECK_RESULT $? 0 1
    else
        sudo firewall-cmd --remove-lockdown-whitelist-context=$context
        sudo firewall-cmd --list-lockdown-whitelist-contexts | grep NetworkManager_t
        CHECK_RESULT $? 0 1
        sudo firewall-cmd --add-lockdown-whitelist-context=$context
        sudo firewall-cmd --query-lockdown-whitelist-context=$context | grep yes
        CHECK_RESULT $?
    fi
    LOG_INFO "Finish testcase execution."
}

main "$@"
