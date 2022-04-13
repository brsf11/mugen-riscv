#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   DNAT forwarding
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL net-tools
    SSH_CMD "sudo dnf install -y httpd net-tools
        sudo systemctl start httpd
        sudo systemctl stop firewalld" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    sudo systemctl start firewalld
    net_cards=$(TEST_NIC 1)
    net_card2=$(echo "$net_cards" | awk -F ' ' '{print $1}')
    remote_net_cards=$(TEST_NIC 2)
    remote_net_card2=$(echo "$remote_net_cards" | awk -F ' ' '{print $1}')
    zone1=$(sudo firewall-cmd --get-zone-of-interface="$NODE1_NIC")
    zone2=$(sudo firewall-cmd --get-zone-of-interface="$net_card2")
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sudo ifconfig "$net_card2" 192.168.100.1/24
    sudo ifconfig "$net_card2" up
    SSH_CMD "sudo ifconfig $remote_net_card2 192.168.100.2/24;sudo ifconfig $remote_net_card2 up;sudo route add -net 192.168.100.0 netmask 255.255.255.0 gw 192.168.100.1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SLEEP_WAIT 1
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    CHECK_RESULT $? 0 1
    echo net.ipv4.ip_forward=1 >>/etc/sysctl.conf
    sysctl -p
    CHECK_RESULT $?
    sudo firewall-cmd --zone=external --change-interface="$NODE1_NIC"
    CHECK_RESULT $?
    sudo firewall-cmd --zone=internal --change-interface="$net_card2"
    CHECK_RESULT $?
    sudo firewall-cmd --zone=external --add-masquerade
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -F | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -F | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t mangle -F | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -X | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -X | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t mangle -X | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -A INPUT -i lo -j ACCEPT | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -A OUTPUT -o lo -j ACCEPT | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -P INPUT ACCEPT | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -P OUTPUT ACCEPT | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -P FORWARD ACCEPT | grep success
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -A PREROUTING -d "$NODE1_IPV4" -p tcp --dport 80 -j DNAT --to-destination 192.168.100.2:80
    CHECK_RESULT $?

    sudo firewall-cmd --direct --passthrough ipv4 -t nat -A POSTROUTING -d 192.168.100.2 -p tcp --dport 80 -j SNAT --to 192.168.100.1
    CHECK_RESULT $?
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -D POSTROUTING -d 192.168.100.2 -p tcp --dport 80 -j SNAT --to 192.168.100.1
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -D PREROUTING -d "$NODE1_IPV4" -p tcp --dport 80 -j DNAT --to-destination 192.168.100.2:80
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -F
    sudo firewall-cmd --zone=external --remove-masquerade
    if [ ! -z "$zone1" ]; then
        sudo firewall-cmd --zone="$zone1" --change-interface="$NODE1_NIC"
    fi
    if [ ! -z "$zone2" ]; then
        sudo firewall-cmd --zone="$zone2" --change-interface="$net_card2"
    else
        sudo firewall-cmd --zone=internal --remove-interface="$net_card2"
    fi
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    sudo ip addr del 192.168.100.1 dev "$net_card2"
    sudo systemctl stop httpd
    DNF_REMOVE
    rm -rf /tmp/ip_remote
    SSH_CMD "sudo systemctl stop httpd;sudo ip addr del 192.168.100.2 dev $remote_net_card2;sudo route del -net 192.168.100.0 netmask 255.255.255.0 gw 192.168.100.1;sudo yum remove -y net-tools httpd;rm -rf /root/ip_remote" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
