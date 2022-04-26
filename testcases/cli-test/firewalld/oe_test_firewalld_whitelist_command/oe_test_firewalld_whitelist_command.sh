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
# @Desc      :   Use CLI configuration command to lock the list option
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sudo firewall-cmd --lockdown-on
    sudo firewall-cmd --list-lockdown-whitelist-commands | grep "/usr/bin/python3 -Es /usr/bin/firewall-cmd*"
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --add-lockdown-whitelist-command='/usr/bin/python3 -Es /usr/bin/firewall-cmd*' | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --remove-lockdown-whitelist-uid=0
    sudo /usr/bin/python3 -Es /usr/bin/firewall-cmd --add-service=dhcp | grep success
    CHECK_RESULT $?
    sudo /usr/bin/python3 -Es /usr/bin/firewall-cmd --remove-lockdown-whitelist-command='/usr/bin/python3 -Es /usr/bin/firewall-cmd*' | grep success
    CHECK_RESULT $?
    sudo /usr/bin/python3 -Es /usr/bin/firewall-cmd --remove-service=dhcp
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --query-lockdown-whitelist-command='/usr/bin/python3 -Es /usr/bin/firewall-cmd*' | grep no
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --reload
    sudo firewall-cmd --lockdown-off
    sudo firewall-cmd --remove-service=dhcp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
