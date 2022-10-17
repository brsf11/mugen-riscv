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
# @Desc      :   Test nmcli configure MACsec
# ############################################

source ../common/net_lib.sh
function pre_test() {
    LOG_INFO "start to pre the test env"
    DNF_INSTALL "NetworkManager-wifi"
    LOG_INFO "end to pre the test"
}

function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth1=${LOCAL_ETH[0]}
    con_name='test-macsec+'
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    nmcli connection add type macsec \
        con-name ${con_name} ifname macsec0 \
        connection.autoconnect no \
        macsec.parent ${test_eth1} macsec.mode psk \
        macsec.mka-cak 12345678901234567890123456789012 \
        macsec.mka-ckn 1234567890123456789012345678901234567890123456789012345678901234 \
        ip4 192.0.2.100/24
    CHECK_RESULT $?
    nmcli connection up ${con_name}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli con delete ${con_name}
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
