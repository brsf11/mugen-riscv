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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/12
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of ifconfig
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL net-tools
    old_mtu=$(ip a | grep ${NODE1_NIC} | grep mtu | awk '{print $5}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ifconfig ${NODE1_NIC} mtu 1279
    CHECK_RESULT $? 0 0 "Failed to add mtu 1279"
    ip a | grep 1279
    CHECK_RESULT $? 0 0 "Failed to check mtu 1279"
    ifconfig ${NODE1_NIC} add 2001::1/64 2>&1 | grep "SIOCSIFADDR:"
    CHECK_RESULT $? 0 0 "Successfully add ipv6"
    ifconfig ${NODE1_NIC} mtu 1280
    CHECK_RESULT $? 0 0 "Failed to add mtu 1280"
    ip a | grep 1280
    CHECK_RESULT $? 0 0 "Failed to check mtu 1280"
    ifconfig ${NODE1_NIC} add 2002::1/64
    CHECK_RESULT $? 0 0 "Failed to add ipv6"
    ip a | grep "2002::1/64"
    CHECK_RESULT $? 0 0 "Failed to check ipv6"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ifconfig ${NODE1_NIC} mtu $old_mtu
    systemctl restart NetworkManager
    ifup ${NODE1_NIC}
    DNF_REMOVE
    export LANG=${OLD_LANG}
    LOG_INFO "End to restore the test environment."
}

main "$@"
