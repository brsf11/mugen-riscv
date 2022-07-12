#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-27
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-free)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    system_query_b=$(free -b | grep 'Swap' | awk '{print $4}')
    system_query_k=$(free -k | grep 'Swap' | awk '{print $4}')
    system_query_m=$(free -m | grep 'Swap' | awk '{print $4}')
    system_query_g=$(free -g | grep 'Swap' | awk '{print $4}')
    system_query_l=$(free -l | grep 'Low' | awk '{print $2}')
    system_query_t=$(free -t | grep 'Total' | awk '{print $2}')
    OLD_PATH=$PATH
    export PATH=/usr/libexec/pcp/bin/:$PATH
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pcp-free --help 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    pcp-free --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pcp_query_b=$(pcp-free -b | grep 'Swap' | awk '{print $4}')
    CHECK_RESULT $?
    test $pcp_query_b -eq $system_query_b 
    CHECK_RESULT $?
    pcp_query_k=$(pcp-free -k | grep 'Swap' | awk '{print $4}')
    CHECK_RESULT $?
    test $pcp_query_k -eq $system_query_k
    CHECK_RESULT $?
    pcp_query_m=$(pcp-free -m | grep 'Swap' | awk '{print $4}')
    CHECK_RESULT $?
    test $pcp_query_m -eq $system_query_m
    CHECK_RESULT $?
    pcp_query_g=$(pcp-free -g | grep 'Swap' | awk '{print $4}')
    CHECK_RESULT $?
    test $pcp_query_g -eq $system_query_g
    CHECK_RESULT $?
    pcp-free -o | grep -v 'buffers/cache'
    CHECK_RESULT $?
    pcp_query_l=$(pcp-free -l | grep 'Low' | awk '{print $2}')
    CHECK_RESULT $?
    test $pcp_query_l -eq $system_query_l
    CHECK_RESULT $?
    pcp_query_t=$(pcp-free -t | grep 'Total' | awk '{print $2}')
    CHECK_RESULT $?
    test $pcp_query_t -eq $system_query_t
    CHECK_RESULT $?
    CHECK_RESULT $(pcp-free -s 2 -c 3 | grep -c 'Swap') 3
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    PATH=${OLD_PATH}
    LOG_INFO "End to restore the test environment."
}

main "$@"
