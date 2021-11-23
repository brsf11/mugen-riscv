#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2021-4-27
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-isnsd、isnsdd
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "open-isns open-iscsi"
    mkdir -p /tmp/openisns
    cp -rf /etc/isns/isnsd.conf /tmp/openisns/server.conf
    cat>>/tmp/openisns/server.conf<<EOF
SourceName      = iqn.2006-01.com.example.host1
Security       = 1
AuthKeyFile = /etc/isns/auth_key
ServerKeyFile = /etc/isns/server_key.pub
EOF
    cp -rf /etc/isns/isnsdd.conf /tmp/openisns/client.conf
    cat>>/tmp/openisns/client.conf<<EOF
SourceName = iqn.2006-01.com.example.host1:monitor
ServerAddress  = 127.0.0.1:3205
AuthKeyFile = /etc/isns/auth_key
ServerKeyFile = /etc/isns/server_key.pub
EOF
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    isnsd --help 2>&1 | grep -i usage
    CHECK_RESULT $?
    isnsdd --help 2>&1 | grep -i usage
    CHECK_RESULT $?
    systemctl start isnsd
    CHECK_RESULT $?
    isnsadm --help 2>&1 | grep -i usage
    CHECK_RESULT $?
    systemctl status isnsd | grep -i running || exit 1
    isnsd --dump-db | grep '/var/lib/isns'
    CHECK_RESULT $?
    openssl dsaparam -out /etc/isns/dsa.params 1024
    openssl gendsa -out /etc/isns/auth_key /etc/isns/dsa.params
    openssl dsa -pubout -in /etc/isns/auth_key -out /etc/isns/server_key.pub
    chmod 644 /etc/isns/server_key.pub
    mv /etc/isns/auth_key /etc/isns/bak_auth_key
    CHECK_RESULT $?
    isnsd --init 2>&1 | grep /etc/isns/auth_key.pub
    CHECK_RESULT $?
    kill -9 $(pgrep -f "isnsd")
    isnsd --config /tmp/openisns/server.conf --foreground --debug all > server.log 2>&1 &
    grep -i "Creating file DB backend" server.log
    CHECK_RESULT $?
    isnsdd --role initiator --config /tmp/openisns/client.conf --foreground --debug state --no-esi > client.log 2>&1 &
    grep -i "Reading list of exported objects" client.log
    CHECK_RESULT $?
    isnsadm --local --keyfile=/tmp/openisns/control.key \
    --enroll isns.control node-type=ALL functions=ALL object-type=ALL \
    && test -f /tmp/openisns/control.key
    CHECK_RESULT $?
    cp -rf /tmp/openisns/control.key /etc/isns/
    isnsadm --local --register control
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "dnf remove targetcli net-tools -y;sleep 1;
    dd if=/dev/zero of=/dev/${unused_disk} bs=2G count=1;
    rm -rf /tmp/disk_info.sh;
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    DNF_REMOVE
    rm -rf /etc/iscsi/*
    LOG_INFO "Finish restoring the test environment."
}

main "$@"

