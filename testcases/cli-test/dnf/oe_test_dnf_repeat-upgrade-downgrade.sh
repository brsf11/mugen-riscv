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
# @Desc      :   repeat upgrade and downgrade packages
# ##################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    dnf list --installed | grep "@anaconda" | grep "arch\|x86_64" | awk '{print $1}' | awk -F. 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}' >anaconda_list
    if dnf repolist | grep update; then
        dnf list --available --repo=update | grep "arch\|x86_64" | awk '{print $1}' | awk -F . 'OFS="."{$NF="";print}' | awk '{print substr($0, 1, length($0)-1)}' >update_pkg_list
        update_pkg_name=$(shuf -n1 update_pkg_list)
        if ! dnf list installed | grep $update_pkg_name; then
            dnf install -y $update_pkg_name | tee install_log
            update_pkg_name=$(grep update install_log | awk '{print $1}')
            dnf -y downgrade $update_pkg_name
        fi
    fi
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    if dnf repolist | grep update; then
        for ((i = 0; i < 50; i++)); do
            dnf -y upgrade $update_pkg_name | grep "Upgraded\|Nothing to do"
            CHECK_RESULT $?
            dnf -y downgrade $update_pkg_name | grep "Downgraded"
            CHECK_RESULT $?
        done
    fi
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    if ! grep $update_pkg_name anaconda_list; then
        dnf remove $update_pkg_name -y
    fi
    rm -f anaconda_list update_pkg_list install_log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
