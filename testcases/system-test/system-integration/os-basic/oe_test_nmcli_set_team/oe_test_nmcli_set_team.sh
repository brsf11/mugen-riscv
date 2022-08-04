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
    nmcli connection add type team con-name team0 ifname team0 config '{"runner":{"name":"activebackup"}}' | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection modify team0 team.link-watchers "name=ethtool"
    CHECK_RESULT $?
    nmcli connection modify team0 team.link-watchers "name=ethtool delay-up=2500"
    CHECK_RESULT $?
    nmcli connection modify team0 team.link-watchers "name=ethtool delay-up=2,name=arp_ping source-host=192.0.2.1 target-host=192.0.2.2"
    CHECK_RESULT $?
    nmcli connection modify team0 ipv4.address '192.0.2.1/24'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv4.gateway '192.0.2.254'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv4.dns '192.0.2.253'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv4.dns-search 'example.com'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv4.method manual
    CHECK_RESULT $?
    nmcli connection modify team0 ipv6.address '2001:db8::1/32'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv6.gateway '2001:db8::fffe'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv6.dns '2001:db8::fffd'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv6.dns-search 'example.com'
    CHECK_RESULT $?
    nmcli connection modify team0 ipv6.method manual
    CHECK_RESULT $?
    nmcli device | grep "team0"
    CHECK_RESULT $?
    nmcli connection add type ethernet slave-type team con-name team0-port1 ifname enp4s0 master team0 | grep "successfully added"
    CHECK_RESULT $?
    nmcli connection add type ethernet slave-type team con-name team0-port2 ifname enp5s0 master team0
    CHECK_RESULT $?
    nmcli connection up team0 | grep "Connection successfully"
    CHECK_RESULT $?
    teamdctl team0 stat | grep "active port"
    CHECK_RESULT $?
    nmcli con del team0-port1 team0-port2 team0 | grep "successfully deleted"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
