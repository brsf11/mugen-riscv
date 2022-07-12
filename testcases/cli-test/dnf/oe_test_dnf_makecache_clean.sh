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
#@Desc          :   Test "dnf makecache" & "dnf clean" command
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf makecache | grep "Metadata cache created"
    CHECK_RESULT $?
    ls /var/cache/dnf/*.solv | grep "OS\|everything"
    CHECK_RESULT $?
    dnf clean dbcache | grep "files removed"
    CHECK_RESULT $?
    ls /var/cache/dnf/*.solv 2>&1 | grep "No such file or directory"
    CHECK_RESULT $?
    dnf makecache | grep "Metadata cache created"
    dnf clean expire-cache | grep "Cache was expired"
    CHECK_RESULT $?
    dnf makecache | grep "Metadata cache created"
    dnf clean metadata | grep "Cache was expired"
    CHECK_RESULT $?
    ls /var/cache/dnf/*.solv 2>&1 | grep "No such file or directory"
    CHECK_RESULT $?
    dnf --downloadonly install -y tree | grep "Downloading Packages"
    CHECK_RESULT $?
    find /var/cache/dnf -name 'tree*' | grep tree
    CHECK_RESULT $?
    dnf clean packages | grep "file removed"
    CHECK_RESULT $?
    find /var/cache/dnf -name 'tree*' | grep tree
    CHECK_RESULT $? 1 0
    dnf --downloadonly install -y tree | grep "Downloading Packages"
    find /var/cache/dnf -name 'tree*' | grep tree
    dnf makecache | grep "Metadata cache created"
    ls /var/cache/dnf/*.solv | grep "OS\|everything"
    CHECK_RESULT $?
    dnf clean all | grep "files removed"
    CHECK_RESULT $?
    find /var/cache/dnf -name 'tree*' | grep tree
    CHECK_RESULT $? 1 0
    ls /var/cache/dnf/*.solv 2>&1 | grep "No such file or directory"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to prepare the test environment."
    clear_env
    LOG_INFO "Finish preparing the test environment."
}

main "$@"
