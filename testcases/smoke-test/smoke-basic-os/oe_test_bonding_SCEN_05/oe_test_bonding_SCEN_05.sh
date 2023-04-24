#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Add the macvlan device created on bond to the network namespace verification
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    gateway=$(ip route show | grep "default" | awk -F' ' 'NR==1{print $3}')
    cp /etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC} /etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC}.bak
    sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=none/" /etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC}
    echo -e 'MASTER=bond0 \nSLAVE=yes \nUSERCTL=no' >>/etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC}
    echo -e "DEVICE=bond0 \nTYPE=Ethernet \nONBOOT=yes \nBOOTPROTO=static \nIPADDR=${NODE1_IPV4} \nGATEWAY=$gateway \nNAME=bond0 \nBONDING_OPTS='miimon=100 mode=1 fail_over_mac=1'" >/etc/sysconfig/network-scripts/ifcfg-bond0
    echo -e 'alias bond0 bonding \noptions bond0 miimon=100 mode=1 fail_over_mac=1' >/etc/modprobe.d/modprobe.conf
    cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak
    echo -e "ifenslave bond0 ${NODE1_NIC}" >>/etc/rc.d/rc.local
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    modprobe bonding
    CHECK_RESULT $? 0 0 "Load bond module: failed!"
    nmcli c reload
    CHECK_RESULT $? 0 0 "Restart net: failed!"
    ip a | grep "bond0"
    CHECK_RESULT $? 0 0 "Set bond0: failed!"
    ip netns add name1
    CHECK_RESULT $? 0 0 "Add the macvlan device name1: failed!"
    ip link add link bond0 name bond0_local type macvlan
    CHECK_RESULT $? 0 0 "Add the macvlan device bond0_local: failed!"
    ip link set bond0_local up
    CHECK_RESULT $? 0 0 "Set bond0_local up : failed!"
    ip link set bond0_local netns name1
    CHECK_RESULT $? 0 0 "Set bond0_local netns name1: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f  /etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC}.bak /etc/sysconfig/network-scripts/ifcfg-${NODE1_NIC}
    mv -f /etc/rc.d/rc.local.bak /etc/rc.d/rc.local
    rm -rf ifcfg-bond0 /etc/modprobe.d/modprobe.conf
    ip netns delete name1
    nmcli c reload
    LOG_INFO "End to restore the test environment."
}

main "$@"
