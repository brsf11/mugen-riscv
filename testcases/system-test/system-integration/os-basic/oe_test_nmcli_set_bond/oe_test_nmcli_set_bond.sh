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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Command test-who -b/-s
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    nmcli connection add type bond con-name bond0 ifname bond0 bond.options "mode=active-backup" | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection add type bond con-name bond0 ifname bond0 bond.options "mode=active-backup,miimon=1000" | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv4.address '192.0.2.1/24'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv4.gateway '192.0.2.254'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv4.dns '192.0.2.253'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv4.dns-search 'example.com'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv4.method manual
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv6.address '2001:db8::1/32'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv6.gateway '2001:db8::fffe'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv6.dns '2001:db8::fffd'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv6.dns-search 'example.com'
    CHECK_RESULT $?
    nmcli connection modify bond0 ipv6.method manual
    CHECK_RESULT $?
    nmcli device | grep "bond0"
    CHECK_RESULT $?
    nmcli connection add type ethernet slave-type bond con-name bond0-port1 ifname enp4s0 master bond0 | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection add type ethernet slave-type bond con-name bond0-port2 ifname enp5s0 master bond0 | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection up bond0 | grep "Connection successfully"
    CHECK_RESULT $?
    nmcli device | grep "bond0" | grep "connected"
    CHECK_RESULT $?
    nmcli con
    CHECK_RESULT $?
    nmcli connection modify bond0 connection.autoconnect-slaves 1
    CHECK_RESULT $?
    nmcli connection up bond0 | grep "Connection successfully"
    CHECK_RESULT $?
    grep "active-backup" /proc/net/bonding/bond0
    CHECK_RESULT $?
    nmcli con del bond0-port1 bond0-port2 bond0 | grep "successfully deleted"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
