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
# @Desc      :   Instance 20 vrrps to 20 VLAN subnets of bond, enable use vmac
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    which firewalld && systemctl stop firewalld
    getenforce | grep Enforcing && setenforce 0
    DNF_INSTALL "keepalived vconfig net-tools"
    net_cards=$(TEST_NIC 1)
    net_card2=$(echo $net_cards | awk -F ' ' '{print $1}')
    net_card3=$(echo $net_cards | awk -F ' ' '{print $2}')
    nmcli connection add con-name bond0 ifname bond0 type bond mode active-backup
    nmcli connection add con-name slave-38 ifname "${net_card2}" type ethernet master bond0
    nmcli connection add con-name slave-39 ifname "${net_card3}" type ethernet master bond0
    nmcli connection modify bond0 ipv4.method manual connection.autoconnect yes ipv4.addresses 20.20.20.20/24 ipv4.dns 8.8.8.8 ipv4.gateway 20.20.20.1
    nmcli connection up slave-38
    nmcli connection up slave-39
    nmcli connection up bond0
    modprobe bonding
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    for ((i = 10; i < 30; i++)); do
        vconfig add bond0 "${i}"
    done
    for ((i = 10; i < 30; i++)); do
        ifconfig bond0."${i}" up
        CHECK_RESULT $?
    done
    echo "! Configuration File for keepalived
global_defs {
   notification_email {
    root@localhost
   }
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id n1
     vrrp_mcast_group4 224.1.101.18
}" >/etc/keepalived/keepalived.conf
    for ((NUM = 10; NUM < 30; NUM++)); do
        echo "vrrp_instance 4${NUM} {
    state MASTER
    use_vmac vrrp4.${NUM}.1
    interface bond0.${NUM}
    virtual_router_id 1
    priority 115
    advert_int 1
    preempt_delay 60
    authentication {
        auth_type PASS
        auth_pass a3dswd3410
    }
    virtual_ipaddress {
        192.168.111.${NUM}/24
    }
    mcast_src_ip 192.168.111.${NUM}
}" >>/etc/keepalived/keepalived.conf
    done
    systemctl start keepalived
    CHECK_RESULT $?
    SLEEP_WAIT 5
    test $(ip a | grep vrrp4 | grep 192 | wc -l) -eq 20
    CHECK_RESULT $?
    nmcli connection down bond0
    CHECK_RESULT $?
    SLEEP_WAIT 3
    test $(ip a | grep vrrp4 | grep 192 | wc -l) -eq 0
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    nmcli connection del slave-38
    nmcli connection del slave-39
    nmcli connection del bond0
    DNF_REMOVE 1 "keepalived vconfig net-tools"
    rm -rf /etc/keepalived/
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
