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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/5/21
# @License   :   Mulan PSL v2
# @Desc      :   Test OVS
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL openvswitch
    if getenforce | grep -i Enforcing; then
        setenforce 0
        result_flag=1
    fi
    systemctl start openvswitch
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    ip netns add ns_1
    CHECK_RESULT $?
    ip netns list | grep ns_1
    CHECK_RESULT $?
    ip netns add ns_2
    CHECK_RESULT $?
    ip netns list | grep ns_2
    CHECK_RESULT $?
    ovs-vsctl add-br br0
    CHECK_RESULT $?
    ip a | grep br0
    CHECK_RESULT $?
    ovs-vsctl add-port br0 tap1 -- set Interface tap1 type=internal
    CHECK_RESULT $?
    ip a | grep tap1
    CHECK_RESULT $?
    ip link set tap1 netns ns_1
    CHECK_RESULT $?
    ip a | grep tap1
    CHECK_RESULT $? 1
    ip netns exec ns_1 ip link set dev tap1 up
    CHECK_RESULT $?
    ip netns list | grep ns_1 | grep "id: 0"
    CHECK_RESULT $?
    ovs-vsctl add-port br0 tap2 -- set Interface tap2 type=internal
    CHECK_RESULT $?
    ip a | grep tap2
    CHECK_RESULT $?
    ip link set tap2 netns ns_2
    CHECK_RESULT $?
    ip a | grep tap2
    CHECK_RESULT $? 1
    ip netns exec ns_2 ip link set dev tap2 up
    CHECK_RESULT $?
    ip netns list | grep ns_2 | grep "id: 1"
    CHECK_RESULT $?
    ip netns exec ns_1 ip addr add 10.1.1.1/24 dev tap1
    CHECK_RESULT $?
    ip --all netns exec echo hello | grep -A 1 "netns: ns_1" | grep hello
    CHECK_RESULT $?
    ip netns exec ns_2 ip addr add 10.1.1.2/24 dev tap2
    CHECK_RESULT $?
    ip --all netns exec echo hello | grep -A 1 "netns: ns_2" | grep hello
    CHECK_RESULT $?
    ip netns exec ns_1 ip link set lo up
    CHECK_RESULT $?
    ip netns exec ns_2 ip link set lo up
    CHECK_RESULT $?
    ip netns exec ns_2 ping -c 3 10.1.1.1
    CHECK_RESULT $?
    ovs-vsctl del-br br0
    CHECK_RESULT $?
    ip a | grep br0
    CHECK_RESULT $? 1
    ip netns delete ns_1
    CHECK_RESULT $?
    ip netns list | grep ns_1
    CHECK_RESULT $? 1
    ip netns delete ns_2
    CHECK_RESULT $?
    ip netns list | grep ns_2
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environmental cleanup"
    systemctl stop openvswitch
    if [ $result_flag -eq 1 ]; then
        setenforce 1
    fi
    DNF_REMOVE
    LOG_INFO "End of environmental cleanup"
}
main "$@"
