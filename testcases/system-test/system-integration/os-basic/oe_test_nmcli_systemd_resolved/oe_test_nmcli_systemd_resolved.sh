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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-05-07
# @License   :   Mulan PSL v2
# @Desc      :   Test nmcli configuration systemd-resolved
# ############################################

source ../common/net_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "net-tools systemd-resolved"
    cp -r /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf_bak
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SLEEP_WAIT 6
    systemctl --now enable systemd-resolved
    CHECK_RESULT $?
    sed -i /main]/a\dns=systemd-resolved /etc/NetworkManager/NetworkManager.conf
    CHECK_RESULT $?
    systemctl reload NetworkManager
    CHECK_RESULT $?
    netstat -tulpn | grep "127.0.0.53:53"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/NetworkManager/NetworkManager.conf_bak /etc/NetworkManager/NetworkManager.conf
    systemctl reload NetworkManager
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
