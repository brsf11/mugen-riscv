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
    podman pull busybox
    podman images --filter after=$(podman images -q) | grep $(podman images -q)
    CHECK_RESULT $? 0 1
    podman images -sort created | grep busybox
    CHECK_RESULT $?
    podman rmi busybox
    podman images | grep "alpine"
    CHECK_RESULT $?
    podman stop postgres
    podman commit postgres images1
    CHECK_RESULT $?
    podman images | grep images1
    CHECK_RESULT $?
    podman commit --change CMD=/bin/bash --change ENTRYPOINT=/bin/sh postgres images2
    CHECK_RESULT $?
    podman images | grep images2
    CHECK_RESULT $?
    podman commit -p postgres images3
    CHECK_RESULT $?
    podman images | grep images3
    CHECK_RESULT $?
    podman commit -q postgres images4
    CHECK_RESULT $?
    podman images | grep images4
    CHECK_RESULT $?
    podman commit -f docker -q --message "committing container to image" postgres images5
    CHECK_RESULT $?
    podman images | grep images5
    CHECK_RESULT $?
    podman image ls --quiet | grep "$(podman images -aq)"
    CHECK_RESULT $?
    podman image ls --sort size
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
