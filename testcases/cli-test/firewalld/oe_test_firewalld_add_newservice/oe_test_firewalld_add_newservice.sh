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
# @Desc      :   Add new services to the firewall
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL nmap
    DNF_INSTALL nmap 2
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nc -l -p 5060 >/tmp/tmp_log 2>&1 &
    nc -l -p 5555 >/tmp/tmp_log_5555 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5060" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --new-service=example_service --permanent | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --permanent --service=example_service --add-port=5555/tcp
    sudo firewall-cmd --permanent --service=example_service --add-port=5555/udp
    sudo firewall-cmd --permanent --service=example_service --set-short=SIP
    sudo firewall-cmd --permanent --service=example_service --add-module=nf_conntrack_sip
    sudo firewall-cmd --reload
    sudo firewall-cmd --get-services | grep example_service
    CHECK_RESULT $?
    sudo firewall-cmd --add-service=example_service
    CHECK_RESULT $?
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5555" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    grep 'test' /tmp/tmp_log_5555
    CHECK_RESULT $?
    echo '<?xml version="1.0" encoding="utf-8"?>
<service>
    <short>SIP</short>
    <description>The Session Initiation Protocol (SIP) is a communications protocol for signaling and controlling multimedia communication sessions. The most common applications of SIP are in Internet telephony for voice and video calls, as well as instant messaging, over Internet Protocol (IP) networks.</description> 
    <port protocol="tcp" port="5060"/>
    <port protocol="udp" port="5060"/>
    <module name="nf_conntrack_sip"/>
</service>
' >addserver_file.xml
    sudo firewall-cmd --new-service-from-file=addserver_file.xml --permanent | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --reload
    sudo firewall-cmd --add-service=addserver_file
    CHECK_RESULT $?
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5060" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    grep 'test' /tmp/tmp_log
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --remove-service=addserver_file
    sudo firewall-cmd --remove-service=example_service
    sudo firewall-cmd --delete-service=example_service --permanent
    sudo firewall-cmd --delete-service=addserver_file --permanent
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    rm -rf addserver_file.xml /tmp/tmp_log /tmp/tmp_log_5555
    DNF_REMOVE
    DNF_REMOVE 2 nmap
    LOG_INFO "Finish environment cleanup!"
}
main "$@"