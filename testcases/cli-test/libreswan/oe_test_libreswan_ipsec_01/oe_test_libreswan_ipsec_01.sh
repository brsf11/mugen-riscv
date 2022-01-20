#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/21
# @License   :   Mulan PSL v2
# @Desc      :   Test ipsec command
# ##################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libreswan
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ipsec --help 2>&1 | grep "man ipsec <command> or ipsec <command>"
    CHECK_RESULT $?
    ipsec --version | grep "$(rpm -q libreswan | awk -F '-' '{print $2}')"
    CHECK_RESULT $?
    ipsec --directory | grep "/usr/libexec/ipsec"
    CHECK_RESULT $?
    ipsec stop && ipsec start
    SLEEP_WAIT 15
    systemctl status ipsec | grep "active (running)"
    CHECK_RESULT $?
    ipsec status | grep 0
    CHECK_RESULT $?
    ipsec restart | grep restart
    CHECK_RESULT $?
    ipsec stop | grep stop
    CHECK_RESULT $?
    ipsec barf | grep pluto
    CHECK_RESULT $?
    ipsec auto 2>&1 | grep "ipsec auto"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/lib/ipsec/nss/*.db
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
