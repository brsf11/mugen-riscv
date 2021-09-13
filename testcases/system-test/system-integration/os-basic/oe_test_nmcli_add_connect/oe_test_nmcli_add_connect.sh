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
# @Date      :   2020-06-06
# @License   :   Mulan PSL v2
# @Desc      :   Test nmcli connection
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth=${LOCAL_ETH[0]}
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    nmcli c show | grep NAME | grep UUID | grep TYPE
    CHECK_RESULT $?
    nmcli c show --active | grep "$(ip route | grep ${NODE1_IPV4} | awk '{print$3}')"
    CHECK_RESULT $?
    nmcli c add type ethernet ifname ${test_eth} con-name ${test_eth} ip4 192.168.2.100/24 gw4 192.168.2.1
    CHECK_RESULT $?
    echo -e "802-3-ethernet\\nquit\\nyes\\n" | nmcli c edit
    CHECK_RESULT $?
    nmcli c modify ${test_eth} ipv4.dhcp-timeout 10
    CHECK_RESULT $?
    nmcli c modify ${test_eth} ipv4.dhcp-timeout infinity
    CHECK_RESULT $?
    nmcli c modify ${test_eth} ipv4.address 192.0.1.100/24
    CHECK_RESULT $?
    nmcli c up id ${test_eth}
    CHECK_RESULT $?
    nmcli c down id ${test_eth}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli con delete ${test_eth}
    LOG_INFO "End to restore the test environment."
}

main "$@"
