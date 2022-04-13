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
# @Desc      :   Add a rule to allow traffic on port 80 from host B
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl restart firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    flag=0
    if ! sudo firewall-cmd --direct --add-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp -s "${NODE2_IPV4}" --dport 80 -j ACCEPT; then
        sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address='${NODE2_IPV4}' port protocol="tcp" port="80" accept'
        CHECK_RESULT $?
        sudo firewall-cmd --zone=public --add-port=80/tcp
        flag=1
    fi
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    if [ $flag -ne 1 ]; then
        sudo firewall-cmd --direct --remove-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp -s "${NODE2_IPV4}" --dport 80 -j ACCEPT
    else
        sudo firewall-cmd --zone=public --remove-rich-rule='rule family="ipv4" source address='${NODE2_IPV4}' port protocol="tcp" port="80" accept'
        sudo firewall-cmd --zone=public --remove-port=80/tcp
    fi
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    sudo systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
