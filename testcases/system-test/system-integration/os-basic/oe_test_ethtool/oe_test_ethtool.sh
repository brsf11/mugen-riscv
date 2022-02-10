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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Verify support for hardware timestamps
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    get_free_eth 1
    local_eth1=${LOCAL_ETH[0]}
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "chrony ntpstat"
    systemctl start chronyd
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl status chronyd | grep running
    CHECK_RESULT $?
    CHECK_RESULT "$(ethtool -T ${local_eth1} | grep -iE "Capabilities|PTP|Hardware" | wc -l)" 4
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop chronyd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
