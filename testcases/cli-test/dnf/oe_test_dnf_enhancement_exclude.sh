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
# @Desc      :   Test "--enhancement" & "-x <package-file-spec>, --exclude=<package-file-spec>" & "--forcearch=<arch>" option, Test gpgcheck
# ##################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf --enhancement repoquery
    CHECK_RESULT $?
    dnf --enhancement updateinfo
    CHECK_RESULT $?
    dnf install tree -x tree | grep "filtering for argument: tree"
    CHECK_RESULT $?
    dnf install tree --exclude=tree | grep "filtering for argument: tree"
    CHECK_RESULT $?
    dnf --forcearch=$(arch) repolist | grep "repo"
    CHECK_RESULT $?    
    if grep "gpgkey" /etc/yum.repos.d/*.repo; then
        sed -i '/^gpgcheck/c gpgcheck=1' /etc/yum.repos.d/*.repo
    else
        sed -i '/^gpgcheck/c gpgcheck=0' /etc/yum.repos.d/*.repo
    fi
    dnf -y install tree | grep "Complete"
    CHECK_RESULT $?
    rpm -q tree | grep "tree"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    DNF_REMOVE 1 tree
    LOG_INFO "End of restore the test environment."
}

main "$@"
