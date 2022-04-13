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
# @Desc      :   Use area and source to only allow services from specific domains
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl start firewalld
    source_ip=$(echo "${NODE1_IPV4%\.*\.*}.0.0")
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --set-default-zone=drop | grep  success
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --change-interface="$NODE1_NIC" --zone=drop
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --add-source="$source_ip"/16 --zone=trusted
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --add-service=http --zone=trusted | grep  success
    CHECK_RESULT $?
    sudo firewall-cmd --reload
    CHECK_RESULT $?
    sudo firewall-cmd --get-active-zones | grep drop && sudo firewall-cmd --get-active-zones | grep trusted
    CHECK_RESULT $?
    SSH_CMD "ping $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    sudo firewall-cmd --zone=trusted --remove-source="$source_ip"/16
    CHECK_RESULT $?
    SSH_CMD "ping $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --permanent --remove-service=http --zone=trusted
    sudo firewall-cmd --permanent --remove-source="$source_ip"/16 --zone=trusted
    sudo firewall-cmd --permanent --change-interface="$NODE1_NIC" --zone=public
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    sudo firewall-cmd --set-default-zone=public
    sudo systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
