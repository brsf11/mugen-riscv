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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in ndisc6 package
# ############################################

source "../common/common_ndisc6.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rdisc6 -q ${NODE2_IPV6} ${NODE2_NIC[0]} | grep "Soliciting"
    CHECK_RESULT $? 0 1
    rdisc6 -r 5 ${NODE2_IPV6} ${NODE2_NIC[0]} | tail -n +2 | head -n -1 | wc -l | grep 5
    CHECK_RESULT $?
    /usr/bin/time -o runtime rdisc6 -r 1 -w 2000 ${NODE2_IPV6} ${NODE2_NIC[0]}
    CHECK_RESULT $? 0 1
    grep "0:02.00" runtime
    CHECK_RESULT $?
    ndisc6_version=$(rpm -qa ndisc6 | awk -F '-' '{print $2}')
    rdisc6 -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    rdisc6 -h | grep "rdisc6"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
