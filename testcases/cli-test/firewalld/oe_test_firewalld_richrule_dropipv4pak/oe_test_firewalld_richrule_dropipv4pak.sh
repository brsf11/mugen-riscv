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
# @Desc      :   Reject all new ipv4 connections http from machine B for the ipv4 protocol, the log prefix is "http_test", the level is "info", and new ipv4 connections from other initiators are accepted
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
    sudo firewall-cmd --zone=public --add-service=http
    sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" service name="http" accept'
    CHECK_RESULT $?
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    CHECK_RESULT $?
    sudo firewall-cmd --zone=public --remove-rich-rule='rule family="ipv4" service name="http" accept'
    source_ip=$(echo "${NODE1_IPV4%\.*\.*}.0.0")
    sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address='$source_ip'/16 service name="http" log  prefix="http_test" level="info" limit value="3/m" reject'
    CHECK_RESULT $?
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    SLEEP_WAIT 1
    grep 'http_test' /var/log/messages
    CHECK_RESULT $?

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --zone=public --remove-service=http
    sudo firewall-cmd --zone=public --remove-rich-rule='rule family="ipv4" source address='$source_ip'/16 service name="http" log  prefix="http_test" level="info" limit value="3/m" reject'
    sudo systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
