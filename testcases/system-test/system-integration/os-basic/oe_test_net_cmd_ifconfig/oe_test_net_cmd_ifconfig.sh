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
# @Date      :   2020-04-29
# @License   :   Mulan PSL v2
# @Desc      :   Network commonly used command test-ifconfig
# #############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    eth_name=${LOCAL_ETH[0]}
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL net-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ifconfig "${eth_name}" down
    CHECK_RESULT $?
    ifconfig "${eth_name}" | grep "${eth_name}" | grep "UP"
    CHECK_RESULT $? 1
    ifconfig "${eth_name}" up
    CHECK_RESULT $?
    ifconfig "${eth_name}" | grep "${eth_name}" | grep "UP"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
