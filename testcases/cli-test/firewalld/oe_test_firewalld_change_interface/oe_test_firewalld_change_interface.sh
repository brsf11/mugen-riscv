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
# @Desc      :   The network interface is assigned to the designated firewall area
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    default_zone=$(sudo firewall-cmd --get-default-zone)
    if ! sudo firewall-cmd --get-active-zones | grep home; then
        sudo firewall-cmd --add-service=http --zone=home
        CHECK_RESULT $?
        sudo firewall-cmd --zone=home --change-interface="$NODE1_NIC"
        CHECK_RESULT $?
        sudo firewall-cmd --remove-service=http --zone=home
        CHECK_RESULT $?
    elif ! sudo firewall-cmd --get-active-zones | grep public; then
        sudo firewall-cmd --add-service=http --zone=public
        CHECK_RESULT $?
        sudo firewall-cmd --zone=public --change-interface="$NODE1_NIC"
        CHECK_RESULT $?
        sudo firewall-cmd --remove-service=http --zone=public
        CHECK_RESULT $?
    fi
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --zone="$default_zone" --change-interface="$NODE1_NIC"
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    sudo systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
