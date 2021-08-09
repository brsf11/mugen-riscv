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
# @Desc      :   Forward HTTPD logs to other virtual machines
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "httpd"
    setenforce 0
    systemctl stop iptables
    systemctl restart httpd
    SSH_CMD "
    systemctl stop iptables
    sed -i '/apache-error/d' /var/log/messages
    sed -i '/apache-access/d' /var/log/messages
    " ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cat >/etc/rsyslog.d/client.conf <<EOF
    \$ModLoad imfile
    \$InputFilePollInterval 10
    \$InputFileName /var/log/httpd/access_log
    \$InputFileTag apache-access
    \$InputFileStateFile stat-apache-access
    \$InputFileSeverity info
    \$InputFilePersistStateInterval 25000
    \$InputRunFileMonitor
    \$InputFileName /var/log/httpd/error_log
    \$InputFileTag apache-error
    \$InputFileStateFile stat-apache-error
    \$InputFileSeverity error
    \$InputFilePersistStateInterval 25000
    \$InputRunFileMonitor
    if $programname == 'apache-access' then @@${NODE2_IPV4}
    if $programname == 'apache-access' then ~
    if $programname == 'apache-error' then @@${NODE2_IPV4}
    if $programname == 'apache-error' then ~
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    SSH_CMD "
    echo  '\$ModLoad imtcp\n\$InputTCPServerRun 514\n*.* /var/log/test' > /etc/rsyslog.d/server.conf
    systemctl restart rsyslog
    " ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SLEEP_WAIT 20
    SSH_CMD "grep "apache-access" /var/log/test" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "grep "apache-error" /var/log/test" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    SSH_CMD "rm -rf /etc/rsyslog.d/server.conf && systemctl restart rsyslog" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /etc/rsyslog.d/client.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}

main "$@"
