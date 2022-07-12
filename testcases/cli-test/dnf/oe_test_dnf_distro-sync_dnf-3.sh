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
#@Desc          :   Test "dnf distro-sync" command, check ll /usr/bin/dnf & /usr/bin/yum, Test "--downloaddir=<path>, --destdir=<path" & "--downloadonly" option
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL tree
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf distro-sync tree | grep "Nothing to do"
    CHECK_RESULT $?
    dnf remove -y tree
    ls -al /usr/bin/dnf | grep dnf-3
    CHECK_RESULT $?
    ls -al /usr/bin/yum | grep dnf-3
    CHECK_RESULT $?
    dnf --downloadonly --downloaddir=/tmp -y install tree | grep "Downloading Packages"
    CHECK_RESULT $?
    find /tmp -name "tree*" | grep "tree"
    CHECK_RESULT $?
    rm -rf /tmp/tree*.rpm
    dnf --downloadonly -y install tree | grep "Downloading Packages"
    CHECK_RESULT $?
    find /var/cache/dnf/ -name "tree*" | grep "tree"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    dnf clean packages
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
