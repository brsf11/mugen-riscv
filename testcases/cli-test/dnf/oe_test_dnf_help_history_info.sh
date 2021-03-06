#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/5/13
# @License   :   Mulan PSL v2
# @Desc      :   Test "-h, --help, --help-cmd" option, Test "dnf help" & "dnf history" & "dnf info" command
# ##################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    dnf --help install | grep usage
    CHECK_RESULT $?
    dnf -h install | grep usage
    CHECK_RESULT $?
    dnf --help-install | grep "display a helpful usage message"
    CHECK_RESULT $?
    dnf help | grep usage
    CHECK_RESULT $?
    dnf -y install tree
    dnf history | grep "install tree"
    CHECK_RESULT $?
    dnf info kernel | grep "Name" | grep "kernel"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    dnf -y remove tree
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
