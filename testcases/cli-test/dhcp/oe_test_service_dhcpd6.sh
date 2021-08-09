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
# @Desc      :   Test dhcpd6.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/dhcp/dhcpd6.conf /etc/dhcp/dhcpd6.bak
    echo 'default-lease-time 2592000;
preferred-lifetime 604800;
option dhcp-renewal-time 3600;
option dhcp-rebinding-time 7200;
allow leasequery;
option dhcp6.info-refresh-time 21600;
subnet6 2001:db8::0/64 {
    range6 2001:db8::50 2001:db8::100;
}' >>/etc/dhcp/dhcpd6.conf
    ip addr add 2001:db8::1 dev "${NODE1_NIC}"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution dhcpd6.service
    test_reload dhcpd6.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop dhcpd6.service
    mv -f /etc/dhcp/dhcpd6.bak /etc/dhcp/dhcpd6.conf
    ip addr del 2001:db8::1 dev "${NODE1_NIC}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
