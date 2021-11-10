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
# @Desc      :   Test nmcli configure default gateway
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
    nmcli c add type ethernet ifname ${test_eth} con-name ${con_name} ip4 192.0.2.100/24 ip6 2001:db8::100/64 | grep successfully
    CHECK_RESULT $?
    nmcli connection modify ${con_name} ipv4.gateway "192.0.2.1"
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "ipv4.gateway" | grep "192.0.2.1"
    CHECK_RESULT $?
    nmcli connection modify ${con_name} ipv6.gateway "2001:db8::1"
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "ipv6.gateway" | grep "2001:db8::1"
    CHECK_RESULT $?
    nmcli connection up ${con_name}
    CHECK_RESULT $?
    nmcli connection edit ${con_name} <<EOF
set ipv4.gateway 192.0.3.1
set ipv6.gateway 2001:db9::1
print
save persistent
active ${con_name}
quit
EOF
    nmcli connection show ${con_name} | grep "ipv4.gateway" | grep "192.0.3.1"
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep "ipv6.gateway" | grep "2001:db9::1"
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
