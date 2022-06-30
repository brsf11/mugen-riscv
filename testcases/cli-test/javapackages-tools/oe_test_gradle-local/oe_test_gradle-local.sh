#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of gradle-local command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL gradle-local
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    gradle-local --help | grep "-"
    CHECK_RESULT $?
    gradle-local -v | grep -i "Gradle"
    CHECK_RESULT $?
    gradle-local
    CHECK_RESULT $?
    gradle-local extend | grep -E "BUILD SUCCESSFUL|extend"
    CHECK_RESULT $?
    gradle-local base | grep -E "BUILD SUCCESSFUL|base"
    CHECK_RESULT $?
    gradle-local base dolast | grep -E "base|dolast|BUILD SUCCESSFUL"
    CHECK_RESULT $?
    gradle-local base dolast -x dolast | grep "dolast"
    CHECK_RESULT $? 1
    gradle-local base --rerun-tasks
    CHECK_RESULT $?
    gradle-local base --continue
    CHECK_RESULT $?
    gradle-local -q base | grep "I am base!"
    CHECK_RESULT $?
    gradle-local -w base
    CHECK_RESULT $?
    gradle-local -i base | grep -E "Starting Build|All projects evaluated|Tasks to be executed: \[task ':base'\]"
    CHECK_RESULT $?
    gradle-local base --console plain
    CHECK_RESULT $?
    gradle-local base --console rich
    CHECK_RESULT $?
    gradle-local base --status | grep -E "PID|STATUS|INFO|$(gradle-local -v | grep "Gradle" | awk '{print $2}')"
    CHECK_RESULT $?
    expect <<EOF
        spawn gradle-local base --scan
        expect "" {send "yes\r"}
        expect eof
EOF
    gradle-local base extend dolast --parallel
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf .gradle
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
