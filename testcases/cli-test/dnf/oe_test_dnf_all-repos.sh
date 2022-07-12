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
#@Desc          :   test all oe repos
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf -y --repo=OS install vim | grep "Complete!"
    CHECK_RESULT $?
    dnf list --installed | grep vim-enhanced | grep @OS
    CHECK_RESULT $?
    dnf -y --repo=everything install tree | grep "Complete!"
    CHECK_RESULT $?
    dnf list --installed | grep tree | grep @everything
    CHECK_RESULT $?
    dnf -y --repo=EPOL list | grep EPOL
    CHECK_RESULT $?
    dnf -y --repo=debuginfo list | grep debuginfo
    CHECK_RESULT $?
    dnf remove -y vim tree
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
