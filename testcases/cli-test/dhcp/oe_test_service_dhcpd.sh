#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test dhcpd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.bak
    echo 'ddns-update-style none;
ignore client-updates;
subnet 192.168.0.0 netmask 255.255.255.0 {
range 192.168.0.200 192.168.0.230;
    option domain-name-servers 192.168.0.1;
    option domain-name "test.local";
    option routers 192.168.0.1;
    option subnet-mask 255.255.255.0;
    default-lease-time 43200;
    max-lease-time 86400;
}' >>/etc/dhcp/dhcpd.conf
    ip addr add 192.168.0.1 dev "${NODE1_NIC}"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution dhcpd.service
    test_reload dhcpd.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop dhcpd.service
    mv -f /etc/dhcp/dhcpd.bak /etc/dhcp/dhcpd.conf
    ip addr del 192.168.0.1 dev "${NODE1_NIC}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
