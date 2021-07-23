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
    addr2name -4 ${NODE1_IPV4} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -6 ${NODE1_IPV6} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -c ${NODE1_IPV4} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -c ${NODE1_IPV6} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -m ${NODE1_IPV4} ${NODE1_IPV6} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -n ${NODE1_IPV4} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -n ${NODE1_IPV6} | grep "newlocalhost"
    CHECK_RESULT $?
    addr2name -r newlocalhost | grep "newlocalhost"
    CHECK_RESULT $?
    ndisc6_version=$(rpm -qa ndisc6 | awk -F '-' '{print $2}')
    addr2name -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    addr2name -h | grep "help"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
