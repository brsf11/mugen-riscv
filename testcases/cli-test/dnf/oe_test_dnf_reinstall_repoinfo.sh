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
# @Desc      :   Test "dnf reinstall" & "dnf repoinfo" & "dnf repolist" & "dnf repoquery" & "dnf search" & "dnf upgrade-minimal" command, Test "--repo=<repoid>, --repoid=<repoid>" & "--version" option, Install the same package by two dnf at the same time
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
    dnf -y reinstall tree | grep "Reinstalled"
    CHECK_RESULT $?
    rpm -q tree | grep tree
    CHECK_RESULT $?
    dnf remove -y tree | grep "Removed"
    CHECK_RESULT $?
    dnf reinstall -y tree 2>&1 | grep "Package tree available, but not installed"
    CHECK_RESULT $?
    dnf --repo=everything repolist | grep "everything"
    CHECK_RESULT $?
    ret=$(dnf --repo=everything repolist | wc -l)
    CHECK_RESULT "$ret" 2 0
    dnf --repoid=everything repolist | grep "everything"
    CHECK_RESULT $?
    dnf repoinfo | grep "Repo-id"
    CHECK_RESULT $?
    dnf repolist | grep "repo id"
    CHECK_RESULT $?
    dnf repoquery tree | grep "tree"
    CHECK_RESULT $?
    dnf repoquery -all | grep "/usr/bin/tree"
    CHECK_RESULT $?
    dnf -y install sysstat &
    rpm -q sysstat | grep "sysstat"
    CHECK_RESULT $?
    dnf search vim | grep vim-enhanced
    CHECK_RESULT $?
    dnf update-minimal --assumeno 2>&1 | grep "Upgrading:"
    CHECK_RESULT $?
    dnf --version | grep -B 1 dnf
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    DNF_REMOVE 1 "tree sysstat"
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
