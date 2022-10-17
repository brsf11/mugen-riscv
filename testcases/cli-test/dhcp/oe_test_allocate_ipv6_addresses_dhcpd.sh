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
# @Desc      :   Test dhcp allocate ipv6 addresses
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL dhcp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    cat > dhcpd6.conf << EOF
subnet6 3ffe:501:ffff:100::/64 {
# Two addresses available to clients
#  (the third client should get NoAddrsAvail)
range6 3ffe:501:ffff:100::1 3ffe:501:ffff:100::9;
# Use the whole /64 prefix for temporary addresses
#  (i.e., direct application of RFC 4941)
range6 3ffe:501:ffff:100:: temporary;
# Some /64 prefixes available for Prefix Delegation (RFC 3633)
prefix6 3ffe:501:ffff:100:: 3ffe:501:ffff:111:: /64;
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
    ip netns exec netns0 ip a add 3ffe:501:ffff:100::11/64 dev vnet0
    CHECK_RESULT $? 0 0 "vnet0 add ip fail"
    sleep 2
    ip netns exec netns0 ip a | grep "3ffe:501:ffff:100::11"
    CHECK_RESULT $? 0 0 "vnet0 add ip fail"
    ip netns exec netns0 dhcpd -6 -cf dhcpd6.conf
    CHECK_RESULT $? 0 0 "start dhcpd fail"
    ip netns exec netns1 dhclient -6 --address-prefix-len 64
    sleep 2
    ip netns exec netns1 ip a | grep -w 3ffe:501:ffff:100::[1-9]
    CHECK_RESULT $? 0 0 "allocate ipv6 addr fail"
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
    rm -fr dhcpd6.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
