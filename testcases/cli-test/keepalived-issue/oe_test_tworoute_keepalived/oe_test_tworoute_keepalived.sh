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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   Processing VRRP instances with unicast multiple interfaces
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL keepalived
    which firewalld && systemctl stop firewalld
    getenforce | grep Enforcing && setenforce 0
    node1_net_cards=$(TEST_NIC 1)
    node2_net_cards=$(TEST_NIC 2)
    node3_net_cards=$(TEST_NIC 3)
    node2_net_card2=$(echo $node2_net_cards | awk -F ' ' '{print $1}')
    node2_net_card3=$(echo $node2_net_cards | awk -F ' ' '{print $2}')
    node2_net_card4=$(echo $node2_net_cards | awk -F ' ' '{print $3}')
    node2_net_card5=$(echo $node2_net_cards | awk -F ' ' '{print $4}')
    node1_net_card2=$(echo $node1_net_cards | awk -F ' ' '{print $1}')
    node1_net_card3=$(echo $node1_net_cards | awk -F ' ' '{print $2}')
    node3_net_card2=$(echo $node3_net_cards | awk -F ' ' '{print $1}')
    node3_net_card3=$(echo $node3_net_cards | awk -F ' ' '{print $2}')
    SSH_CMD "systemctl stop firewalld
    getenforce | grep Enforcing && setenforce 0
    ip addr add 203.0.113.1/26 dev ${node2_net_card2}
    ip addr add 203.0.113.65/26 dev ${node2_net_card3}
    ip addr add 203.0.113.129/26 dev ${node2_net_card4}
    ip addr add 203.0.113.193/26 dev ${node2_net_card5}" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" || exit 1
    SSH_CMD "ip addr add 2001:db8:1::1/64 dev ${node2_net_card2}
    ip addr add 2001:db8:2::1/64 dev ${node2_net_card3}
    ip addr add 2001:db8:3::1/64 dev ${node2_net_card4}
    ip addr add 2001:db8:4::1/64 dev ${node2_net_card5}" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" || exit 1
    SSH_CMD "sysctl -qw net/ipv4/ip_forward=1
    sysctl -qw net.ipv6.conf.all.forwarding=1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" || exit 1

    ip addr add 203.0.113.10/26 dev "${node1_net_card2}"
    ip addr add 203.0.113.70/26 dev "${node1_net_card3}"
    ip addr add 192.0.2.1/32 dev lo
    ip addr add 2001:db8:1::10/64 dev "${node1_net_card2}"
    ip addr add 2001:db8:2::10/64 dev "${node1_net_card3}"
    ip addr add 2001:db8::1/128 lo
    ip -6 route add default nexthop via 2001:db8:1::1 nexthop via 2001:db8:2::1

    SSH_CMD "dnf -y install keepalived
    systemctl stop firewalld
    getenforce | grep Enforcing && setenforce 0
    ip addr add 203.0.113.140/26 dev ${node3_net_card2}
    ip addr add 203.0.113.200/26 dev ${node3_net_card3}
    ip addr add 192.0.2.2/32 dev lo" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    SSH_CMD "ip addr add 2001:db8:3::10/64 dev ${node3_net_card2}
    ip addr add 2001:db8:4::10/64 dev ${node3_net_card3}
    ip addr add 2001:db8::2/128 dev lo
    ip -6 route add default nexthop via 2001:db8:3::1 nexthop via 2001:db8:4::1" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    DNF_INSTALL "keepalived tcpdump"
    rm -rf /etc/keepalived/keepalived.conf
    cp keepalived_backup1.conf /etc/keepalived/keepalived.conf
    sed -i "s/node1_net_card2/${node1_net_card2}/g" /etc/keepalived/keepalived.conf
    SSH_SCP keepalived_backup2.conf "${NODE3_USER}"@"${NODE3_IPV4}":/etc/keepalived/keepalived.conf "${NODE3_PASSWORD}"
    SSH_CMD "sed -i 's/node3_net_card2/${node3_net_card2}/g' /etc/keepalived/keepalived.conf" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    keepalived -P -f /etc/keepalived/keepalived.conf
    CHECK_RESULT $?
    SSH_CMD "keepalived -P -f /etc/keepalived/keepalived.conf" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    CHECK_RESULT $?
    sleep 1
    tcpdump -nne -i "${node1_net_card2}" host 192.0.2.2 | grep VRRP >tcpdump_pack &
    tcpdump -nne -i "${node1_net_card3}" host 192.0.2.2 | grep VRRP >tcpdump_pack2 &
    SLEEP_WAIT 30
    kill -9 $(pgrep -f 'tcpdump -nne -i')
    (grep "192.0.2.2 > 192.0.2.1: VRRPv2" tcpdump_pack >/dev/null && grep "192.0.2.1 > 192.0.2.2: VRRPv2" tcpdump_pack >/dev/null) ||
        (grep "192.0.2.2 > 192.0.2.1: VRRPv2" tcpdump_pack2 >/dev/null && grep "192.0.2.1 > 192.0.2.2: VRRPv2" tcpdump_pack2 >/dev/null)
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    kill -9 $(pgrep -f keepalived.conf)
    rm -rf /run/keepalived.pid tcpdump_pack2 tcpdump_pack
    DNF_REMOVE 1
    rm -rf /etc/keepalived/
    ip -6 route del default nexthop via 2001:db8:1::1 nexthop via 2001:db8:2::1
    ip addr del 2001:db8::1/128 dev lo
    ip addr del 2001:db8:1::10/64 dev "${node1_net_card2}"
    ip addr del 2001:db8:2::10/64 dev "${node1_net_card3}"
    ip addr del 203.0.113.10/26 dev "${node1_net_card2}"
    ip addr del 203.0.113.70/26 dev "${node1_net_card3}"
    ip addr del 192.0.2.1/32 dev lo
    ip addr del 2001:db8::ff/128 dev lo
    ip addr del 192.0.2.255/32 dev lo
    SSH_CMD "kill -9 \$(pgrep -f keepalived.conf);" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    SSH_CMD "rm -rf /run/keepalived.pid;
    dnf -y remove keepalived;
    rm -rf /etc/keepalived/;
    ip addr del 203.0.113.140/26 dev ${node3_net_card2};
    ip addr del 203.0.113.200/26 dev ${node3_net_card3};
    ip addr del 192.0.2.2/32 dev lo;
    ip -6 route del default nexthop via 2001:db8:3::1 nexthop via 2001:db8:4::1;
    ip addr del 2001:db8:3::10/64 dev ${node3_net_card2};
    ip addr del 2001:db8:4::10/64 dev ${node3_net_card3};
    ip addr del 2001:db8::2/128 dev lo;
    ip addr del 2001:db8::ff/128 dev lo;
    ip addr del 192.0.2.255/32 dev lo;" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    SSH_CMD "ip addr del 203.0.113.1/26 dev ${node2_net_card2}
    ip addr del 203.0.113.65/26 dev ${node2_net_card3}
    ip addr del 203.0.113.129/26 dev ${node2_net_card4}
    ip addr del 203.0.113.193/26 dev ${node2_net_card5}
    ip addr del 2001:db8:1::1/64 dev ${node2_net_card2}
    ip addr del 2001:db8:2::1/64 dev ${node2_net_card3}
    ip addr del 2001:db8:3::1/64 dev ${node2_net_card4}
    ip addr del 2001:db8:4::1/64 dev ${node2_net_card5}" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"

    LOG_INFO "Finish environment cleanup!"
}
main "$@"
