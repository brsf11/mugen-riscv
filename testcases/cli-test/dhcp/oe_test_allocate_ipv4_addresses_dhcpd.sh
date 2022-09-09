#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   kouhuiying
# @Contact   :   kouhuiying@uniontech.com
# @Date      :   2022/09/08
# @License   :   Mulan PSL v2
# @Desc      :   Test dhcp allocate ipv4 addresses
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL dhcp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    cat > dhcpd.conf << EOF
subnet 99.99.0.0 netmask 255.255.0.0 {
range 99.99.10.1 99.99.10.9;
option domain-name-servers ns1.internal.example.org;
option routers 99.99.0.1;
option broadcast-address 99.99.10.255;
default-lease-time 600;
max-lease-time 7200;
}
EOF
    ip netns add netns0
    CHECK_RESULT $? 0 0 "add netns0 fail"
    ip netns add netns1
    CHECK_RESULT $? 0 0 "add netns1 fail"
    ip netns list | grep -w netns0
    CHECK_RESULT $? 0 0 "netns0 is not exist"
    ip netns list | grep -w netns1
    CHECK_RESULT $? 0 0 "netns1 is not exist"
    ip link add name vnet0 type veth peer name vnet1
    ip link set vnet0 netns netns0
    ip link set vnet1 netns netns1
    ip netns exec netns0 ip link set vnet0 up
    ip netns exec netns1 ip link set vnet1 up
    ip netns exec netns0 ip a add 99.99.10.100/16 dev vnet0
    CHECK_RESULT $? 0 0 "vnet0 add ip fail"
    sleep 2
    ip netns exec netns0 ip a | grep "99.99.10.100"
    CHECK_RESULT $? 0 0 "vnet0 add ip fail"
    ip netns exec netns0 dhcpd -4 -cf dhcpd.conf -pf /var/run/dhcpd.pid
    CHECK_RESULT $? 0 0 "start dhcpd fail"
    ip netns exec netns1 dhclient
    sleep 2
    ip netns exec netns1 ip a | grep -w 99.99.10.[0-9]
    CHECK_RESULT $? 0 0 "allocate ipv4 addr fail"
    LOG_INFO "Finish testing!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    ip netns exec netns0 ip link del vnet0
    ip netns exec netns1 ip link del vnet1
    ip netns del netns0
    ip netns del netns1
    ip netns list
    pkill dhcpd
    ps -aux | grep dhclient | grep -v grep | awk '{print $2}' | xargs kill -9
    rm -fr dhcpd.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
