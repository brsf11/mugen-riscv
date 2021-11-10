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
# @Desc      :   Test nmcli configure static routing
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth=${LOCAL_ETH[0]}
    con_name="ethernet-${test_eth}"
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    nmcli c add type ethernet ifname ${test_eth} con-name ${con_name} ip4 192.0.2.100/24 | grep successfully
    CHECK_RESULT $?
    nmcli connection modify ethernet-${test_eth} +ipv4.routes "192.0.2.0/24 198.51.100.1"
    CHECK_RESULT $?
    num=$(nmcli connection show ${con_name} | grep "ipv4.routes" | grep "198.51.100.1" -o | wc -l)
    CHECK_RESULT $num 1
    nmcli connection modify ${con_name} +ipv4.routes "192.0.2.0/24 198.51.100.1,203.0.113.0/24 198.51.100.1"
    CHECK_RESULT $?
    num=$(nmcli connection show ${con_name} | grep "ipv4.routes" | grep "198.51.100.1" -o | wc -l)
    CHECK_RESULT $num 2
    nmcli connection up ${con_name}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli connection up ${test_eth}
    nmcli con delete ${con_name}
    LOG_INFO "End to restore the test environment."
}

main "$@"
