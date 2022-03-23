#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2021/01/11
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in podman package
# ############################################

source "../common/common_podman.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    podman pull postgres:alpine
    podman run --name postgres -e POSTGRES_PASSWORD=secret -d postgres:alpine
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    podman ps --filter name=postgres
    CHECK_RESULT $?
    podman ps -q
    CHECK_RESULT $?
    podman ps -s | grep SIZE
    CHECK_RESULT $?
    podman run --name postgres2 -e POSTGRES_PASSWORD=secret -d postgres:alpine
    CHECK_RESULT $?
    podman ps --sort names | awk '{print $11}' | grep -wA 1 "postgres" | grep -w "postgres2"
    CHECK_RESULT $?
    podman ps | grep "postgres"
    CHECK_RESULT $?
    podman ps --all | awk '{print $11}' | grep -wA 1 "postgres2" | grep -w "postgres"
    CHECK_RESULT $?
    podman stop postgres2
    CHECK_RESULT $?
    podman rm postgres2
    CHECK_RESULT $?
    podman ps -aq | grep "$(ls /run/runc/ | cut -b 1-12)"
    CHECK_RESULT $?
    podman ps --no-trunc | grep "$(ls /run/runc/)"
    CHECK_RESULT $?
    podman ps --pod | grep "POD"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
