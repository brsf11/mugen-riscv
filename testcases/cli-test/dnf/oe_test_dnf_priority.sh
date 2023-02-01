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
# @Date      :   2020/5/15
# @License   :   Mulan PSL v2
# @Desc      :   Test priority option in configuration file
# ##################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    line1=$(grep -nA4 "name=mainline" /etc/yum.repos.d/*.repo | grep "gpgcheck" | awk -F "-" '{print $1}')
    line2=$(grep -nA4 "name=epol" /etc/yum.repos.d/*.repo | grep "gpgcheck" | awk -F "-" '{print $1}')
    dnf list --installed | grep "@mainline" | grep "arch\|" | grep -E "x86_64|riscv" | awk -F. 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}' >anaconda_list
    dnf list --available --repo=mainline | grep "arch\|" | grep -E "x86_64|riscv" | awk '{print $1}' | awk -F . 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}' >mainline_pkg_list
    epol_list=($(dnf list --available --repo=epol | grep "arch\|" | grep -E "x86_64|riscv" | awk '{print $1}' | awk -F . 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}'))
    for pkg in ${epol_list[@]};
    do
        if grep -q $pkg mainline_pkg_list ; then
            if ! grep -q $pkg anaconda_list ; then
                test_pkg=$pkg
                break
            fi
        fi
    done
    sed -i "${line1} apriority=2" /etc/yum.repos.d/*.repo
    sed -i "${line2} apriority=1" /etc/yum.repos.d/*.repo
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dnf -y install $test_pkg | grep "Complete!"
    CHECK_RESULT $?
    dnf list --installed | grep $test_pkg | grep "@epol"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    sed -ie '/priority=/d' /etc/yum.repos.d/*.repo
    DNF_REMOVE 1 $test_pkg
    rm -rf anaconda_list mainline_pkg_list
    LOG_INFO "End of restore the test environment."
}

main "$@"
