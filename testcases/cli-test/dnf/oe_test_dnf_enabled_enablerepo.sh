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
#@Desc          :   Test enabled=0 & enabled=1, Test "--enablerepo=<repoid>" option
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    line1=$(grep -nA4 "name=OS" /etc/yum.repos.d/*.repo | grep "enabled=" | awk -F "-" '{print $1}')
    line2=$(grep -nA4 "name=everything" /etc/yum.repos.d/*.repo | grep "enabled=" | awk -F "-" '{print $1}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    grep -B3 "enabled=1" /etc/yum.repos.d/*.repo | grep "name=OS"
    CHECK_RESULT $?
    dnf repolist | grep OS
    CHECK_RESULT $?
    grep -B3 "enabled=1" /etc/yum.repos.d/*.repo | grep "name=everything"
    CHECK_RESULT $?
    dnf repolist | grep everything
    CHECK_RESULT $?
    sed -i "${line1}c enabled=0" /etc/yum.repos.d/*.repo
    sed -i "${line2}c enabled=0" /etc/yum.repos.d/*.repo
    dnf repolist | grep "OS\|everything"
    CHECK_RESULT $? 1 0
    dnf install -y sysstat 2>&1 | grep "No match for argument: sysstat"
    CHECK_RESULT $?
    dnf --enablerepo=EPOL repolist | grep EPOL
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    sed -i "${line1}c enabled=1" /etc/yum.repos.d/*.repo
    sed -i "${line2}c enabled=1" /etc/yum.repos.d/*.repo
    LOG_INFO "End of restore the test environment."
}

main "$@"
