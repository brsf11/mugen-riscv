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
# @Date      :   2020-04-09 10:52:41
# @License   :   Mulan PSL v2
# @Desc      :   Add/remove virtual network card
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    ip_set=$(Randomly_generate_ip)
    vir_eth=${NODE2_NIC}
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    SSH_CMD "yum install -y net-tools" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SSH_CMD "ifconfig ${vir_eth}:1 ${ip_set}/24 broadcast 255.255.255.0 up" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    ping -c 3 ${ip_set}
    CHECK_RESULT $?
    SSH_CMD "ifconfig ${vir_eth}:1 down" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    ping -c 3 ${ip_set}
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "yum remove -y net-tools" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
