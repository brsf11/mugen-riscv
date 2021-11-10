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
# @Desc      :   Test nmcli cancel auto configuration /etc/resolv.conf
# ############################################

source ../common/net_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    rm /etc/resolv.conf
    systemctl reload NetworkManager
    grep "nameserver" /etc/resolv.conf
    CHECK_RESULT $?
    echo "[main]
dns=none" >/etc/NetworkManager/conf.d/90-dns-none.conf
    rm /etc/resolv.conf
    systemctl reload NetworkManager
    test -f /etc/resolv.conf
    CHECK_RESULT $? 0 1
    rm /etc/NetworkManager/conf.d/90-dns-none.conf
    systemctl reload NetworkManager
    grep "nameserver" /etc/resolv.conf
    CHECK_RESULT $?
    rm /etc/resolv.conf
    echo "## test" >/etc/resolv.conf.manually-configured
    ln -s /etc/resolv.conf.manually-configured /etc/resolv.conf
    systemctl reload NetworkManager
    grep "test" /etc/resolv.conf
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/resolv.conf.manually-configured
    rm -rf /etc/resolv.conf
    systemctl reload NetworkManager
    LOG_INFO "End to restore the test environment."
}

main "$@"
