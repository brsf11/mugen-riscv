#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Open the firewall, support TCP protocol
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "net-tools"
    sed -i '/22/i\-A INPUT -p tcp -m state --state NEW -m tcp --dport 514 -j ACCEPT' /etc/sysconfig/iptables
    systemctl restart iptables
    SSH_CMD "systemctl start iptables" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cat >/etc/rsyslog.d/server.conf <<EOF
    \$ModLoad imtcp
    \$InputTCPServerRun 514
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    netstat -anpt | grep 514 | grep rsyslogd
    CHECK_RESULT $?
    time=$(date +%s%N | cut -c 9-13)
    SSH_CMD "
    echo  'local6.* @@${NODE1_IPV4}' > /etc/rsyslog.d/client.conf
    systemctl restart rsyslog
    logger -t tcp -p local6.err "tcptest$time"
    " ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SLEEP_WAIT 20
    grep "tcptest$time" /var/log/messages
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    sed -i "/-A INPUT -p tcp -m state --state NEW -m tcp --dport 514 -j ACCEPT/d" /etc/sysconfig/iptables
    CHECK_RESULT $?
    systemctl restart iptables
    SSH_CMD "rm -rf /etc/rsyslog.d/client.conf && systemctl restart rsyslog" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /etc/rsyslog.d/server.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
