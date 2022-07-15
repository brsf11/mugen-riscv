#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
###################################
#@Author        :   zengcongwei
#@Contact       :   735811396@qq.com
#@Date          :   2020/5/12
#@License       :   Mulan PSL v2
#@Desc          :   Test "dnf alias" command
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL tree
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf alias add rm=remove | grep "Aliases added: rm"
    CHECK_RESULT $?
    dnf alias list | grep rm
    CHECK_RESULT $?
    dnf -y rm tree | grep "Removing:"
    CHECK_RESULT $?
    rpm -q tree | grep "package tree is not installed"
    CHECK_RESULT $?
    dnf alias delete rm | grep "Aliases deleted: rm"
    CHECK_RESULT $?
    dnf alias list | grep rm
    CHECK_RESULT $? 1 0
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
