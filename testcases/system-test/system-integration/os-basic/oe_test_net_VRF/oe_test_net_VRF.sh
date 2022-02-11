#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-05-09
# @License   :   Mulan PSL v2
# @Desc      :   Create vrf test
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 2
    test_eth1=${LOCAL_ETH[0]}
    test_eth2=${LOCAL_ETH[1]}
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    ip link add dev blue type vrf table 1001
    CHECK_RESULT $?
    find /sys/class/net/ | grep blue
    CHECK_RESULT $?
    ip link set dev blue up
    CHECK_RESULT $?
    ip link set dev ${test_eth1} master blue
    ip link set dev ${test_eth1} up
    CHECK_RESULT $?
    ip addr add dev ${test_eth1} 192.0.2.1/24
    ip addr show | grep blue
    CHECK_RESULT $?

    ip link add dev red type vrf table 1002
    CHECK_RESULT $?
    ip link set dev red up
    CHECK_RESULT $?
    ip link set dev ${test_eth2} master red
    ip link set dev ${test_eth2} up
    CHECK_RESULT $?
    ip addr add dev ${test_eth2} 192.0.2.1/24
    ip addr show | grep " red"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip link del blue
    ip link del red
    nmcli con delete ${test_eth1} ${test_eth2}
    LOG_INFO "End to restore the test environment."
}

main "$@"
