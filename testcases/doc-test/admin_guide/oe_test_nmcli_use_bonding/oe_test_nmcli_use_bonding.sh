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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-05-09
# @License   :   Mulan PSL v2
# @Desc      :   Use command line bonding test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    test_eth1=$(ls /sys/class/net/ | grep -Ewv 'lo.*|docker.*|bond.*|vlan.*|virbr.*|br.*' | grep -v $(ip route | grep ${NODE1_IPV4} | awk '{print$3}') | sed -n 1p)
    test_eth2=$(ls /sys/class/net/ | grep -Ewv 'lo.*|docker.*|bond.*|vlan.*|virbr.*|br.*' | grep -v $(ip route | grep ${NODE1_IPV4} | awk '{print$3}') | sed -n 2p)
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    nmcli c add type ethernet ifname ${test_eth1} con-name ${test_eth1} ip4 192.0.2.100/24 | grep successfully
    CHECK_RESULT $?
    nmcli c add type ethernet ifname ${test_eth2} con-name ${test_eth2} ip4 192.0.3.100/24 | grep successfully
    CHECK_RESULT $?
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    modprobe --first-time bonding
    modinfo bonding
    CHECK_RESULT $?
    modprobe --help
    CHECK_RESULT $?
    ifdown ${test_eth1}
    ifdown ${test_eth2}
    cp -r ifcfg-bond0 /etc/sysconfig/network-scripts/
    cp -r ifcfg-bond0-slave-port1 /etc/sysconfig/network-scripts/
    cp -r ifcfg-bond0-slave-port2 /etc/sysconfig/network-scripts/
    sed -i "s/test_eth1/${test_eth1}/g" /etc/sysconfig/network-scripts/ifcfg-bond0-slave-port1
    sed -i "s/test_eth2/${test_eth2}/g" /etc/sysconfig/network-scripts/ifcfg-bond0-slave-port2
    CHECK_RESULT $?
    ifup ${test_eth1} | grep successfully
    CHECK_RESULT $?
    ifup ${test_eth2} | grep successfully
    CHECK_RESULT $?
    nmcli con load /etc/sysconfig/network-scripts/ifcfg-bond0
    nmcli con load /etc/sysconfig/network-scripts/ifcfg-bond0-slave-port1
    nmcli con load /etc/sysconfig/network-scripts/ifcfg-bond0-slave-port2
    CHECK_RESULT $?
    ip link show | grep bond0
    CHECK_RESULT $?
    nmcli con show --active | grep bond0
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /sys/class/net/bonding_masters
    nmcli con delete bond0
    nmcli con delete bond0-slave-port1
    nmcli con delete bond0-slave-port2
    nmcli con delete ${test_eth1}
    nmcli con delete ${test_eth2}
    LOG_INFO "Finish environment cleanup."
}

main $@
