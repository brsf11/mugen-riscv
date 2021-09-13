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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-05-07
# @License   :   Mulan PSL v2
# @Desc      :   Test nmcli modify 802.3 link configuration
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth1=${LOCAL_ETH[0]}
    con_name='test_con1'
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    nmcli connection add type ethernet con-name ${con_name} ifname ${test_eth1} | grep successfully
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep interface-name | grep ${test_eth1}
    CHECK_RESULT $?
    nmcli connection modify ${con_name} 802-3-ethernet.auto-negotiate no 802-3-ethernet.speed 0 802-3-ethernet.duplex ""
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "802-3-ethernet.auto-negotiate" | grep "no"
    CHECK_RESULT $?
    nmcli connection modify ${con_name} 802-3-ethernet.auto-negotiate yes 802-3-ethernet.speed 0 802-3-ethernet.duplex ""
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "802-3-ethernet.auto-negotiate" | grep "yes"
    CHECK_RESULT $?
    nmcli connection modify ${con_name} 802-3-ethernet.auto-negotiate yes 802-3-ethernet.speed 1000 802-3-ethernet.duplex full
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "802-3-ethernet.speed" | grep "1000"
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "802-3-ethernet.duplex" | grep "full"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli con delete ${con_name}
    LOG_INFO "End to restore the test environment."
}

main "$@"
