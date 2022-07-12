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
# @Desc      :   Test "--nobest" & "--nodocs" & "--nogpgcheck" option
# ##################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL tree
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rpm -q tree | grep tree
    CHECK_RESULT $?
    dnf --nobest -y install tree | grep "already installed"
    CHECK_RESULT $?
    dnf -y remove tree
    dnf --nodocs -y install tree | grep "Complete!"
    CHECK_RESULT $?
    test -f /usr/share/doc/tree
    CHECK_RESULT $? 1 0
    dnf -y remove tree
    dnf --nogpgcheck -y install tree | grep "Complete!"
    CHECK_RESULT $?
    rpm -q tree | grep tree
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    DNF_REMOVE
    LOG_INFO "End of restore the test environment."
}

main "$@"
