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
# @Date      :   2020/5/12
# @License   :   Mulan PSL v2
# @Desc      :   Test "dnf list" & "dnf mark" command
# ##################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    dnf list --all | grep "oe1"
    CHECK_RESULT $?
    dnf list --installed | grep "@anaconda"
    CHECK_RESULT $?
    dnf list --available | grep "oe1"
    CHECK_RESULT $?
    dnf list --extras
    CHECK_RESULT $?
    dnf list --obsoletes
    CHECK_RESULT $?
    dnf list --recent | grep "Recently Added Packages"
    CHECK_RESULT $?
    dnf list --updates | grep "Available Upgrades"
    CHECK_RESULT $?
    dnf list --upgrades | grep "Available Upgrades"
    CHECK_RESULT $?
    dnf list --autoremove
    CHECK_RESULT $?
    dnf -y install vim | grep "vim-common"
    CHECK_RESULT $?
    dnf mark install vim-common | grep "marked as user installed"
    CHECK_RESULT $?
    dnf -y remove vim | grep -v "vim-common"
    CHECK_RESULT $?
    dnf list installed | grep vim-common
    CHECK_RESULT $?
    dnf mark remove vim-common | grep "unmarked as user installed"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    dnf -y remove vim-common
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
