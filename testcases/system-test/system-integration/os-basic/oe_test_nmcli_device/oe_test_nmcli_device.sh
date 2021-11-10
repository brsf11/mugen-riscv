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
# @Desc      :   Test nmcli device
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
    nmcli device help 2>&1 | grep Usage
    CHECK_RESULT $?
    nmcli dev status | grep ${test_eth}
    CHECK_RESULT $?
    nmcli d show | grep ${test_eth}
    CHECK_RESULT $?
    nmcli d show ${test_eth} | grep ${test_eth}
    CHECK_RESULT $?
    nmcli -f DEVICE,TYPE device | grep ${test_eth} | grep ethernet
    CHECK_RESULT $?
    nmcli -t d show ${test_eth} | grep ${test_eth}
    CHECK_RESULT $?
    nmcli -p d show ${test_eth} | grep "Device details"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
