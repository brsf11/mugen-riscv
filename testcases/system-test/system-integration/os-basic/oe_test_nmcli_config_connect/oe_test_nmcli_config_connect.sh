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
# @Desc      :   Test nmcli configure Ethernet connection
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
    nmcli con add type ethernet ifname ${test_eth} | grep successfully
    CHECK_RESULT $?
    nmcli con mod ${con_name} ipv4.dns "8.8.8.8 8.8.4.4"
    CHECK_RESULT $?
    nmcli con mod ${con_name} ipv6.dns "2001:4860:4860::8888 2001:4860:4860::8844"
    CHECK_RESULT $?
    nmcli con mod ${con_name} +ipv4.dns "8.8.8.8 8.8.4.4"
    CHECK_RESULT $?
    nmcli con mod ${con_name} +ipv6.dns "2001:4860:4860::8888 2001:4860:4860::8844"
    CHECK_RESULT $?
    nmcli con up ${con_name} ifname ${test_eth}
    CHECK_RESULT $?
    nmcli device status | grep ${test_eth} | grep ${con_name}
    CHECK_RESULT $?
    nmcli -p con show ${con_name} | grep "8.8.8.8"
    CHECK_RESULT $?
    nmcli -p con show ${con_name} | grep "2001:4860:4860::8888"
    CHECK_RESULT $?
    echo -e "quit\\nyes\\n" | nmcli con edit type ethernet con-name ${test_eth}
    CHECK_RESULT $?
    nmcli con modify ${con_name} ipv4.dhcp-hostname host-name ipv6.dhcp-hostname host-name
    CHECK_RESULT $?
    nmcli con modify ${con_name} ipv4.dhcp-client-id client-ID-string
    CHECK_RESULT $?
    nmcli con modify ${con_name} ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes
    CHECK_RESULT $?
    echo -e "quit\\nyes\\n" | nmcli con edit type ethernet con-name ${test_eth}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli con delete ${con_name}
    LOG_INFO "End to restore the test environment."
}

main "$@"
