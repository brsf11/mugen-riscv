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
# @Desc      :   Use CLI to configure user lock list option
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    useradd whitetestuser
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sudo firewall-cmd --add-lockdown-whitelist-user=whitetestuser | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --list-lockdown-whitelist-user | grep whitetestuser
    CHECK_RESULT $?
    sudo firewall-cmd --remove-lockdown-whitelist-user=whitetestuser | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --query-lockdown-whitelist-user=whitetestuser | grep no
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf whitetestuser
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
