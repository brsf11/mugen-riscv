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
# @Desc      :   NAT forwarding
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL net-tools
    SSH_CMD "sudo dnf install -y net-tools" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    test $? -ne 0 && exit 1
    sudo systemctl start firewalld
    net_cards=$(TEST_NIC 1)
    net_card2=$(echo "$net_cards" | awk -F ' ' '{print $1}')
    remote_net_cards=$(TEST_NIC 2)
    remote_net_card2=$(echo "$remote_net_cards" | awk -F ' ' '{print $1}')
    zone1=$(sudo firewall-cmd --get-zone-of-interface="$NODE1_NIC")
    zone2=$(sudo firewall-cmd --get-zone-of-interface="$net_card2")
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    firewall-cmd --reload
    systemctl restart firewalld
    SLEEP_WAIT 2
    sudo ifconfig "$net_card2" 192.168.100.1/24
    sudo ifconfig "$net_card2" up
    SSH_CMD "sudo ifconfig $remote_net_card2 192.168.100.2/24;sudo ifconfig $remote_net_card2 up;sudo route add default  gw 192.168.100.1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SLEEP_WAIT 2
    SSH_CMD "ping baidu.com -I $remote_net_card2 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    echo net.ipv4.ip_forward=1 >>/etc/sysctl.conf
    sysctl -p
    CHECK_RESULT $?
    SLEEP_WAIT 2
    sudo firewall-cmd --zone=external --change-interface="$NODE1_NIC"
    CHECK_RESULT $?
    sudo firewall-cmd --zone=internal --change-interface="$net_card2"
    CHECK_RESULT $?

    sudo firewall-cmd --zone=external --add-masquerade
    CHECK_RESULT $?
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -A POSTROUTING -o "$NODE1_NIC" -j MASQUERADE -s 192.168.100.0/24
    CHECK_RESULT $?

    SLEEP_WAIT 2
    SSH_CMD "ping baidu.com -I $remote_net_card2 -c 1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --direct --passthrough ipv4 -t nat -D POSTROUTING -o"$NODE1_NIC" -j MASQUERADE -s 192.168.100.0/24
    sudo firewall-cmd --zone=external --remove-masquerade
    if [ ! -z "$zone1" ]; then
        sudo firewall-cmd --zone="$zone1" --change-interface="$NODE1_NIC"
    fi
    if [ ! -z "$zone2" ]; then
        sudo firewall-cmd --zone="$zone2" --change-interface="$net_card2"
    else
        sudo firewall-cmd --zone=internal --remove-interface="$net_card2"
    fi
    sudo ip addr del 192.168.100.1 dev "$net_card2"
    DNF_REMOVE 
    SSH_CMD "sudo ip addr del 192.168.100.2 dev $remote_net_card2;sudo route del default  gw 192.168.100.1;sleep 2;sudo dnf remove -y net-tools" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    mv /etc/sysctl.conf.bak /etc/sysctl.conf
    sudo firewall-cmd --reload
    systemctl restart firewalld
    SLEEP_WAIT 2
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
