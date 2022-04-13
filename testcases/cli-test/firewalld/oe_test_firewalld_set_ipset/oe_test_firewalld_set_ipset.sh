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
# @Desc      :   Use firewalld to set and control IP set
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl start firewalld
    source_ip=$(echo "${NODE1_IPV4%\.*\.*}.0.0")
    set_name="testipset"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "ping  $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --new-ipset=${set_name} --type=hash:net
    sudo firewall-cmd --permanent --get-ipsets | grep ${set_name}
    CHECK_RESULT $?
    cat >iplist.txt <<EOL
192.168.0.2
192.168.0.3
192.168.1.0/24
192.168.2.254
EOL
    sudo firewall-cmd --permanent --ipset=${set_name} --add-entries-from-file=iplist.txt
    sudo firewall-cmd --permanent --ipset=${set_name} --get-entries | grep 192.168.0.3
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --ipset=${set_name} --remove-entries-from-file=iplist.txt
    sudo firewall-cmd --permanent --ipset=${set_name} --get-entries | grep 192.168.0.3
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --permanent --ipset=${set_name} --add-entry="$source_ip/16"
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --ipset=${set_name} --get-entries | grep "$source_ip/16"
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --zone=drop --add-source=ipset:${set_name}
    CHECK_RESULT $?
    sudo firewall-cmd --reload
    systemctl restart firewalld
    CHECK_RESULT $?
    SSH_CMD "ping  $NODE1_IPV4 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --permanent --zone=drop --remove-source=ipset:${set_name}
    sudo firewall-cmd --permanent --delete-ipset=${set_name}
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    rm -rf iplist.txt
    sudo systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
