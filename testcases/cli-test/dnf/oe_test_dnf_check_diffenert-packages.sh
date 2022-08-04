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
#@Date          :   2020/5/13
#@License       :   Mulan PSL v2
#@Desc          :   Test "dnf check-update" & "dnf check" command, Install the different package by two dnf at the same time
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf check-update
    CHECK_RESULT $? 100 0
    dnf check
    CHECK_RESULT $?
    dnf check --dependencies
    CHECK_RESULT $?
    dnf check --duplicates
    CHECK_RESULT $?
    dnf check --obsoleted
    CHECK_RESULT $?
    dnf check --provides
    CHECK_RESULT $?
    dnf -y install vim &
    dnf -y install tree | grep "Complete!"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    rpm -q vim-enhanced | grep "vim-enhanced"
    CHECK_RESULT $?
    rpm -q tree | grep "tree"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start restore the test environment."
    clear_env
    DNF_REMOVE 1 "vim tree"
    LOG_INFO "End of restore the test environment."
}

main "$@"
