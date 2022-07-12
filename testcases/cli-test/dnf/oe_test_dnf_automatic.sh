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
#@Desc          :   Test dnf-automatic services
###################################

source "common/common_dnf.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL dnf-automatic
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl enable dnf-automatic-notifyonly.timer 2>&1 | grep "Created symlink"
    CHECK_RESULT $?
    systemctl start dnf-automatic-notifyonly.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-notifyonly.timer | grep "active"
    CHECK_RESULT $?
    systemctl enable dnf-automatic-download.timer 2>&1 | grep "Created symlink"
    CHECK_RESULT $?
    systemctl start dnf-automatic-download.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-download.timer | grep "active"
    CHECK_RESULT $?
    systemctl enable dnf-automatic-install.timer 2>&1 | grep "Created symlink"
    CHECK_RESULT $?
    systemctl start dnf-automatic-install.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-install.timer | grep "active"
    CHECK_RESULT $?
    systemctl disable dnf-automatic-notifyonly.timer 2>&1 | grep "Removed"
    CHECK_RESULT $?
    systemctl stop dnf-automatic-notifyonly.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-notifyonly.timer | grep "inactive"
    CHECK_RESULT $?
    systemctl disable dnf-automatic-download.timer 2>&1 | grep "Removed"
    CHECK_RESULT $?
    systemctl stop dnf-automatic-download.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-download.timer | grep "inactive"
    CHECK_RESULT $?
    systemctl disable dnf-automatic-install.timer 2>&1 | grep "Removed"
    CHECK_RESULT $?
    systemctl stop dnf-automatic-install.timer
    CHECK_RESULT $?
    systemctl status dnf-automatic-install.timer | grep "inactive"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
