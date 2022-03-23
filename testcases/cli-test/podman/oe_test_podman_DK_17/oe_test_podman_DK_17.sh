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
# @Desc      :   The usage of commands in docker package
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
    docker image history --format=json postgres:alpine | grep "comment"
    CHECK_RESULT $?
    docker image history --human postgres:alpine | grep "B"
    CHECK_RESULT $?
    docker image history --no-trunc postgres:alpine | grep "$(docker images -aq)"
    CHECK_RESULT $?
    docker image history -q postgres:alpine | grep "$(docker images -aq)"
    CHECK_RESULT $?
    docker image ls --filter after=postgres:alpine
    CHECK_RESULT $?
    docker image ls --all | grep "postgres"
    CHECK_RESULT $?
    docker image ls --digests | grep "DIGEST"
    CHECK_RESULT $?
    docker image ls --format json | grep "postgres:alpine"
    CHECK_RESULT $?
    docker image ls --no-trunc | grep "sha256"
    CHECK_RESULT $?
    docker image ls --noheading | grep "TAG"
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
