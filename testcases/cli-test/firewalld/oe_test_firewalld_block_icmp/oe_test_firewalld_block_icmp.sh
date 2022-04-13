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
# @Desc      :   Block or unblock ICMP requests
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    for line in $(sudo firewall-cmd --get-icmptypes); do
        if sudo firewall-cmd --query-icmp-block="$line" | grep no; then
            sudo firewall-cmd --add-icmp-block="$line"
            CHECK_RESULT $?
            sudo firewall-cmd --remove-icmp-block="$line"
            CHECK_RESULT $?
        fi
    done
    SSH_CMD "ping  $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    sudo firewall-cmd --add-icmp-block=echo-request
    SSH_CMD "ping  $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --remove-icmp-block=echo-request
    sudo firewall-cmd --reload
    sudo systemctl start firewalld   
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
